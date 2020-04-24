//
//  ImagePlugin.m
//  Runner
//
//  Created by Masanao Imai on 2020/04/23.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@implementation ImagePlugin : NSObject

+ (NSDictionary *)getImageProperties:(NSString *)filePath {
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
    UIImage *img = [[UIImage alloc] initWithData:data];
    int orientation = 0; // undefined orientation
    NSDictionary *dict = @{ @"width" : @(lroundf(img.size.width)),
                            @"height" : @(lroundf(img.size.height)),
                            @"orientation": @((NSInteger)orientation)};
    return dict;
}

+ (NSString *)cropImage:(NSString *)filePath originX:(int)originX originY:(int)originY width:(int)width height:(int)height {
    NSString *fileExtension = @"_cropped.jpg";
    NSString *fileName = [[filePath lastPathComponent] stringByDeletingPathExtension];
    NSString *tempFileName =  [NSString stringWithFormat:@"%@%@", fileName, fileExtension];
    NSString *finalFileName = [NSTemporaryDirectory() stringByAppendingPathComponent:tempFileName];

    NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
    
    UIImage *img = [[UIImage alloc] initWithData:data];
    img = [self normalizedImage:img];
    
    if(originX<0 || originY<0
       || originX>img.size.width || originY>img.size.height
       || originX+width>img.size.width || originY+height>img.size.height) {
        NSLog(@"Bounds are outside of the dimensions of the source image");
    }
    
    CGRect cropRect = CGRectMake(originX, originY, width, height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([img CGImage], cropRect);
    UIImage *croppedImg = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    NSData *imageData = UIImageJPEGRepresentation(croppedImg, 1.0);
    
    if ([[NSFileManager defaultManager] createFileAtPath:finalFileName contents:imageData attributes:nil]) {
        return finalFileName;
    } else {
        NSLog(@"Temporary file could not be created");
    }

    return finalFileName;
}


+ (UIImage *)normalizedImage:(UIImage *)image {
  if (image.imageOrientation == UIImageOrientationUp) return image;

  UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
  [image drawInRect:(CGRect){0, 0, image.size}];
  UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return normalizedImage;
}

@end

