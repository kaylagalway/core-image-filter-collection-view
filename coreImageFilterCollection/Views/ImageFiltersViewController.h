//
//  ImageFiltersViewController.h
//  coreImageFilterCollection
//
//  Created by Kayla Galway on 4/12/17.
//  Copyright © 2017 Kayla Galway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageFiltersViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionView *collectionView;

@end
