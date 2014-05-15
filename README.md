CustomUICollectionViewLayout
============================

A custom layout for UICollectionView

The cell's index of UICollectionView in horizontal scroll is
+---+---+---+
| 1 | 3 | 5 |
+---+---+---+
| 2 | 4 | 6 |
+---+---+---+
but I want it to be
+---+---+---+
| 1 | 2 | 3 |
+---+---+---+
| 4 | 5 | 6 |
+---+---+---+.


So, I refer some data from Internet and write a layout to reorder cell's index;


Usage
============================

Import CustomCollectionViewLayout.h/.m file to project, and init UICollectionView with it.
ex:
UICollectionView *collectionView = [UICollectionView alloc]initWithFrame:CGRectMake(x, y, width, height)
                                                    collectionViewLayout:[CustomCollectionViewLayout new]];
