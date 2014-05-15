//
//  CustomCollectionViewLayout.m
//  stackOverflowCustomLayout
//
//  Created by Ash on 2014/2/21.
//  Copyright (c) 2014年 nexiles. All rights reserved.
//

#import "CustomCollectionViewLayout.h"

#define Items_In_One_Row 3
#define Items_In_One_Column 2

@interface CustomCollectionViewLayout ()

-(id)initWithItemsInOneRow:(NSInteger)itemsInOneRow andItemsInOneColumn:(NSInteger)itemsInOneColumn;
-(void)calculateLayoutProperties;
-(int)pagesInSection:(NSInteger)section;

@property (nonatomic, assign) NSInteger itemsInOneRow;
@property (nonatomic, assign) NSInteger itemsInOneColumn;

@property (nonatomic, strong) NSMutableArray *frames;
@property (nonatomic, assign) CGFloat topBorderSize;
@property (nonatomic, assign) CGFloat bottomBorderSize;
@property (nonatomic, assign) CGFloat lineSpacing;
@property (nonatomic, assign) CGFloat interitemSpacing;

@property (nonatomic, assign) CGSize pageSize;
@property (nonatomic, assign) CGSize itemSize;

@end

@implementation CustomCollectionViewLayout

-(id)init{
    return [self initWithItemsInOneRow:Items_In_One_Row andItemsInOneColumn:Items_In_One_Column];
}

-(id)initWithItemsInOneRow:(NSInteger)itemsInOneRow andItemsInOneColumn:(NSInteger)itemsInOneColumn
{
    if(self  =[super init]){
        self.itemsInOneRow = itemsInOneRow;
        self.itemsInOneColumn = itemsInOneColumn;
        self.frames = [NSMutableArray array];
    }
    
    return self;
}

-(void)calculateLayoutProperties
{
    self.pageSize = self.collectionView.frame.size;
    
    CGFloat itemWidth = self.pageSize.width / (self.itemsInOneRow + 1);
    CGFloat itemHeight = self.pageSize.height*2 / (self.itemsInOneColumn + self.itemsInOneColumn-1 + 2);
    self.itemSize = CGSizeMake(itemWidth, itemHeight);
    
    self.lineSpacing = (self.pageSize.width - (self.itemsInOneRow * self.itemSize.width)) / (self.itemsInOneRow + 1);
    self.interitemSpacing = (self.pageSize.height - (self.itemsInOneColumn * self.itemSize.height)) / (self.itemsInOneColumn + 1 + 2);
    
    self.topBorderSize = self.interitemSpacing*2;
    self.bottomBorderSize = self.interitemSpacing*2;
}

-(int)pagesInSection:(NSInteger)section
{
    return (int)(([self.collectionView numberOfItemsInSection:section] - 1) / (self.itemsInOneRow * self.itemsInOneColumn)  + 1);
}

-(CGSize)collectionViewContentSize
{
    NSInteger sections = 0;
    if([self.collectionView respondsToSelector:@selector(numberOfSections)]){
        sections = [self.collectionView numberOfSections];
    }
    int pages = 0;
    for (int section = 0; section < sections; section++) {
        pages += [self pagesInSection:section];
    }
    return CGSizeMake(pages * self.pageSize.width, self.pageSize.height);
}

-(void)prepareLayout
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self calculateLayoutProperties];
    });
    
    [self.frames removeAllObjects];
    
    NSInteger sections = 0;
    if ([self.collectionView respondsToSelector:@selector(numberOfSections)]) {
        sections = [self.collectionView numberOfSections];
    }
    int pagesOffset = 0; // Pages that are used by prevoius sections
    int itemsInPage = (int)self.itemsInOneRow * (int)self.itemsInOneColumn;
    for (int section = 0; section < sections; section++) {
        NSMutableArray *framesInSection = [NSMutableArray array];
        int pagesInSection = [self pagesInSection:section];
        NSInteger itemsInSection = [self.collectionView numberOfItemsInSection:section];
        for (int page = 0; page < pagesInSection; page++) {
            NSInteger itemsToAddToArray = itemsInSection - framesInSection.count;
            NSInteger itemsInCurrentPage = itemsInPage;
            if (itemsToAddToArray < itemsInPage) { // If there are less cells than expected (typically last page of section), we go only through existing cells.
                itemsInCurrentPage = itemsToAddToArray;
            }
            for (int itemInPage = 0; itemInPage < itemsInCurrentPage; itemInPage++) {
                CGFloat originX = (pagesOffset + page) * self.pageSize.width + self.lineSpacing + (itemInPage % self.itemsInOneRow) * (self.itemSize.width + self.lineSpacing);
                CGFloat originY = self.topBorderSize + (itemInPage / self.itemsInOneRow) * (self.itemSize.height + self.interitemSpacing);
                CGRect itemFrame = CGRectMake(originX, originY, self.itemSize.width, self.itemSize.height);
                [framesInSection addObject:NSStringFromCGRect(itemFrame)];
            }
        }
        [self.frames addObject:framesInSection];
        
        pagesOffset += pagesInSection;
    }
    
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attributes = [NSMutableArray array];
    NSInteger sections = 0;
    if ([self.collectionView respondsToSelector:@selector(numberOfSections)]) {
        sections = [self.collectionView numberOfSections];
    }
    
    int pagesOffset = 0;
    int itemsInPage = (int)self.itemsInOneRow * (int)self.itemsInOneColumn;
    for (int section = 0; section < sections; section++) {
        int pagesInSection = [self pagesInSection:section];
        NSInteger itemsInSection = [self.collectionView numberOfItemsInSection:section];
        for (int page = 0; page < pagesInSection; page++) {
            CGRect pageFrame = CGRectMake((pagesOffset + page) * self.pageSize.width, 0, self.pageSize.width, self.pageSize.height);
            
            if (CGRectIntersectsRect(rect, pageFrame)) {
                int startItemIndex = page * itemsInPage;
                NSInteger itemsInCurrentPage = itemsInPage;
                if (itemsInSection - startItemIndex < itemsInPage) {
                    itemsInCurrentPage = itemsInSection - startItemIndex;
                }
                for (int itemInPage = 0; itemInPage < itemsInCurrentPage; itemInPage++) {
                    UICollectionViewLayoutAttributes *itemAttributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:startItemIndex + itemInPage inSection:section]];
                    if (CGRectIntersectsRect(itemAttributes.frame, rect)) {
                        [attributes addObject:itemAttributes];
                    }
                }
            }
        }
        
        pagesOffset += pagesInSection;
    }
    return attributes;
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = CGRectFromString(self.frames[indexPath.section][indexPath.item]);
    return attributes;
}
@end
