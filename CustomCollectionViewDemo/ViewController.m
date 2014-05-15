//
//  ViewController.m
//  CustomCollectionViewDemo
//
//  Created by Ash on 2014/5/15.
//  Copyright (c) 2014年 nobody. All rights reserved.
//

#import "ViewController.h"
#import "CustomCollectionViewLayout.h"

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
{
    UICollectionView *customCollectionView;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self initializeCollectionView];
}

- (void)initializeCollectionView
{
    float StatusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    float preNavigationBarHeight = 44;
    customCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,
                                                                             StatusBarHeight + preNavigationBarHeight,
                                                                             self.view.frame.size.width,
                                                                             self.view.frame.size.height/2)
                                             collectionViewLayout:[CustomCollectionViewLayout new]];
    [customCollectionView setBackgroundColor:[UIColor lightGrayColor]];
    [customCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [customCollectionView setPagingEnabled:YES];
    [customCollectionView setDelegate:self];
    [customCollectionView setDataSource:self];
    [self.view addSubview:customCollectionView];
}

#pragma mark - UICollectionViewDelegate/DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 36;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    [cell setBackgroundColor:[UIColor colorWithRed:(146+arc4random()%130)/255.0 green:(146+arc4random()%130)/255.0 blue:1 alpha:1]];
    
    for (UIView *subview in cell.subviews) {
        if(subview.tag == 10)[subview removeFromSuperview];
    }
    
    UILabel *numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    [numberLabel setText:[NSString stringWithFormat:@"%d", indexPath.row + 1]];
    [numberLabel setTextAlignment:NSTextAlignmentCenter];
    [numberLabel setTag:10];
    [cell addSubview:numberLabel];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected: %d", indexPath.row + 1);
}
@end
