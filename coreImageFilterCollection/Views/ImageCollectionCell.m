//
//  ImageCollectionCell.m
//  coreImageFilterCollection
//
//  Created by Kayla Galway on 4/12/17.
//  Copyright © 2017 Kayla Galway. All rights reserved.
//

#import "ImageCollectionCell.h"


@implementation ImageCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
   self = [super initWithFrame:frame];
   if (self) {
      _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
      [self.contentView addSubview:_imageView];
      _imageView.contentMode = UIViewContentModeScaleAspectFill;
      _imageView.layer.masksToBounds = YES;
      
      _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:self.contentView.bounds];
      _activityIndicator.hidesWhenStopped = YES;
      _activityIndicator.color = [UIColor darkGrayColor];
//      [_activityIndicator startAnimating];
      [self.contentView addSubview:_activityIndicator];
      [self.contentView bringSubviewToFront:_activityIndicator];
   }
   return self;
}

- (void)prepareForReuse {
   self.imageView.image = nil;
   [_activityIndicator startAnimating];
}

@end
