//
//  ImagePlugin.h
//  Runner
//
//  Created by Masanao Imai on 2020/04/23.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#ifndef ImagePlugin_h
#define ImagePlugin_h

@interface ImagePlugin : NSObject
+ (NSDictionary *)getImageProperties:(NSString *)filePath;
+ (NSString *)cropImage:(NSString *)filePath originX:(int)originX originY:(int)originY width:(int)width height:(int)height;
@end

#endif /* ImagePlugin_h */
