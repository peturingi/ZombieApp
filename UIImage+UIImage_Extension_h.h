//
//  UIImage+UIImage_Extension_h.h
//  Zombie App
//
//  Created by Pétur Ingi Egilsson on 12/12/13.
//  Copyright (c) 2013 Aalborg Universitet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UIImage_Extension_h)

- (UIImage *)imageAtRect:(CGRect)rect;
- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

@end;

