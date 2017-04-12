//
//  ImageFiltersViewController.m
//  coreImageFilterCollection
//
//  Created by Kayla Galway on 4/12/17.
//  Copyright © 2017 Kayla Galway. All rights reserved.
//

#import "ImageFiltersViewController.h"
#import <Photos/Photos.h>
#import "ImageCollectionCell.h"

@interface ImageFiltersViewController ()

@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) PHFetchResult *fetchResult;
@property (strong, nonatomic) PHAssetCollection *assetCollection;
@property (strong, nonatomic) PHCachingImageManager *imageManager;
@property (nonatomic) CGSize thumbnailSize;
@property (nonatomic) CGRect previousRect;


@end

@implementation ImageFiltersViewController

- (void)viewDidLoad {
   [super viewDidLoad];
   [self.navigationController setTitle:@"Hello"];
   [self setUpCollectionView];
   [self getAllPhotos];
}

- (void)viewWillAppear:(BOOL)animated {
   CGFloat screenScale = UIScreen.mainScreen.scale;
   CGSize cellSize = self.flowLayout.itemSize;
   self.thumbnailSize = CGSizeMake(cellSize.width * screenScale, cellSize.height * screenScale);
}

//add change observers?

- (void)getAllPhotos {
   if (self.fetchResult == nil) {
      PHFetchOptions *photosOptions = [[PHFetchOptions alloc] init];
      NSSortDescriptor *photosSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:false];
      photosOptions.sortDescriptors = @[photosSortDescriptor];
      self.fetchResult = [PHAsset fetchAssetsWithOptions:photosOptions];
   }
}

- (void)setUpCollectionView {
   self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
   self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:self.flowLayout];
   [self.collectionView setDataSource:self];
   [self.collectionView setDelegate:self];
   [self.collectionView registerClass:[ImageCollectionCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
   [self.collectionView setBackgroundColor:[UIColor redColor]];
   [self.view addSubview:self.collectionView];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
   ImageCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
   PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.row];
   cell.assetIdentifier = asset.localIdentifier;
   self.imageManager = [[PHCachingImageManager alloc] init];
   [self.imageManager requestImageForAsset:asset targetSize:self.thumbnailSize contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//      if (cell.assetIdentifier == asset.localIdentifier) {
         cell.imageView.image = result;
//      }
   }];
   return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
   return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
   return self.fetchResult.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
   return CGSizeMake(100, 100);
}

@end
