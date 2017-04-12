//
//  ImageCollectionCell.m
//  coreImageFilterCollection
//
//  Created by Kayla Galway on 4/12/17.
//  Copyright © 2017 Kayla Galway. All rights reserved.
//

#import "ImageCollectionCell.h"


@implementation ImageCollectionCell

- (UIImageView *)imageView {
   if (!_imageView) {
      _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
      [self.contentView addSubview:_imageView];
      _imageView.backgroundColor = [UIColor blackColor];
      _imageView.contentMode = UIViewContentModeScaleAspectFill;
      _imageView.layer.masksToBounds = true;
   }
   return _imageView;
}

- (void)prepareForReuse {
   [super prepareForReuse];
   [self.imageView removeFromSuperview];
   self.imageView = nil;
}

@end
