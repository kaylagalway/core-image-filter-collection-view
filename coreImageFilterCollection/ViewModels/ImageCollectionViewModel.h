//
//  ImageCollectionViewModel.h
//  coreImageFilterCollection
//
//  Created by Kayla Galway on 4/12/17.
//  Copyright © 2017 Kayla Galway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <CoreImage/CoreImage.h>
#import "ImageCollectionCell.h"

@protocol ImageCollectionViewModelDelegate <NSObject>

@required
- (void)didFetchPhotoAssets;
- (void)didFetchImage:(UIImage *)image atIndexPath:(NSIndexPath *)indexPath;

@end

enum FilterOptions {
   noFilter,
   monochrome,
   invert,
   noir,
   sepia,
   fade
};

@interface ImageCollectionViewModel : NSObject

@property (nonatomic) CGSize thumbnailSize;
@property (weak, nonatomic) id <ImageCollectionViewModelDelegate> delegate;
@property (nonatomic) enum FilterOptions selectedFilter;

- (void)fetchAllImageAssets;
- (void)imageForIndexPath:(NSIndexPath *)indexPath;
- (void)cancelFilterApplicationToImageAtIndexPath: (NSIndexPath *)indexPath;
- (void)didSelectFilterAtIndex: (NSInteger)index;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;

@end
