//
//  ImageFiltersViewController.h
//  coreImageFilterCollection
//
//  Created by Kayla Galway on 4/12/17.
//  Copyright © 2017 Kayla Galway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageCollectionViewModel.h"

@interface ImageFiltersViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIPopoverPresentationControllerDelegate, ImageCollectionViewModelDelegate, PHPhotoLibraryChangeObserver>

@end
