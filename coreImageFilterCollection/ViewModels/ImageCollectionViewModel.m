//
//  ImageCollectionViewModel.m
//  coreImageFilterCollection
//
//  Created by Kayla Galway on 4/12/17.
//  Copyright © 2017 Kayla Galway. All rights reserved.
//

#import "ImageCollectionViewModel.h"

@interface ImageCollectionViewModel()

@property (strong, nonatomic) NSMutableDictionary *filteredImageDictionary;
@property (strong, nonatomic) PHFetchResult *fetchResult;
@property (strong, nonatomic) PHAssetCollection *assetCollection;
@property (strong, nonatomic) NSOperationQueue *imageFilterQueue;
@property (strong, nonatomic) NSMutableDictionary *pendingImageOperations;

@end

@implementation ImageCollectionViewModel

//MARK: Lifecycle

- (instancetype)init {
   self = [super init];
   if (self) {
      _imageFilterQueue = [[NSOperationQueue alloc] init];
      _imageFilterQueue.maxConcurrentOperationCount = 3;
      _pendingImageOperations = [[NSMutableDictionary alloc] init];
      _selectedFilter = noFilter;
   }
   return self;
}

//MARK: Imperatives

- (void)fetchAllImageAssets {
   if (self.fetchResult == nil) {
      PHFetchOptions *photosOptions = [[PHFetchOptions alloc] init];
      NSSortDescriptor *photosSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:false];
      photosOptions.sortDescriptors = @[photosSortDescriptor];
      self.fetchResult = [PHAsset fetchAssetsWithOptions:photosOptions];
      dispatch_async(dispatch_get_main_queue(), ^{
         [self.delegate didFetchPhotoAssets];
      });
   }
}


- (void)populateImageAssetForIndexPath:(NSIndexPath *)indexPath completion: (void(^)(UIImage *))completion {
   PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
   options.networkAccessAllowed = NO;
   PHAsset *asset = [self.fetchResult objectAtIndex:indexPath.row];
   __weak typeof(self)weakSelf = self;
   [[PHImageManager defaultManager] requestImageForAsset: asset
                                              targetSize: weakSelf.thumbnailSize
                                             contentMode: PHImageContentModeDefault
                                                 options: options
                                           resultHandler: ^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                              completion(result);
                                           }];
}

- (void)imageForIndexPath:(NSIndexPath *)indexPath {
   __weak typeof(self)weakSelf = self;
   [self populateImageAssetForIndexPath:indexPath completion:^(UIImage *image) {
      if (weakSelf.selectedFilter == noFilter) {
         dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.delegate didFetchImage:image atIndexPath: indexPath];
         });
      } else {
         NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            CIFilter *filter = [weakSelf currentFilter];
            UIImage *filteredImage = [weakSelf addFilter: filter toImage: image];
            weakSelf.pendingImageOperations[indexPath] = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
               [weakSelf.delegate didFetchImage: filteredImage atIndexPath:indexPath];
            });
         }];
         self.pendingImageOperations[indexPath] = operation;
         [self.imageFilterQueue addOperation: operation];
      }
   }];
}

- (void)cancelFilterApplicationToImageAtIndexPath: (NSIndexPath *)indexPath {
   [self.pendingImageOperations[indexPath] cancel];
}

- (UIImage *)addFilter: (CIFilter *)filter toImage: (UIImage *)image {
   EAGLContext *openGLContext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
   [openGLContext isMultiThreaded];
   CIContext *coreImageContext = [CIContext contextWithEAGLContext:openGLContext];
   CGImageRef imageReference = image.CGImage;
   CIImage *coreImage = [CIImage imageWithCGImage: imageReference];
   [filter setValue:coreImage forKey:kCIInputImageKey];
   CIImage *output = [filter valueForKey:kCIOutputImageKey];
   CGImageRef outputImage = [coreImageContext createCGImage:output fromRect:output.extent];
   UIImage *filteredImage = [[UIImage imageWithCGImage:outputImage] copy];
   CGImageRelease(outputImage);
   return filteredImage;
}

- (void)didSelectFilterAtIndex: (NSInteger)index {
   switch (index) {
      case 0:
         self.selectedFilter = monochrome;
         break;
      case 1:
         self.selectedFilter = invert;
         break;
      case 2:
         self.selectedFilter = noir;
         break;
      case 3:
         self.selectedFilter = sepia;
         break;
      case 4:
         self.selectedFilter = fade;
         break;
      default:
         break;
   }
}

//MARK: Factories

- (nullable CIFilter *)currentFilter {
   switch (self.selectedFilter) {
      case monochrome:
         return [CIFilter filterWithName: @"CIPhotoEffectMono"];
         break;
      case invert:
         return [CIFilter filterWithName: @"CIColorInvert"];
         break;
      case noir:
         return [CIFilter filterWithName: @"CIPhotoEffectNoir"];
         break;
      case sepia:
         return [CIFilter filterWithName: @"CISepiaTone"];
         break;
      case fade:
         return [CIFilter filterWithName: @"CIPhotoEffectFade"];
         break;
      default:
         return nil;
         break;
   }
}


- (NSInteger)numberOfItemsInSection:(NSInteger)section {
   return self.fetchResult.count;
}

@end
