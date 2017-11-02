//
//  SDWebImageAPNGCoder.h
//  SDWebImageAPNGCoder
//
//  Created by DreamPiggy on 2017/11/2.
//

#import <Foundation/Foundation.h>
#import <SDWebImage/SDWebImageCoder.h>

@interface SDWebImageAPNGCoder : NSObject <SDWebImageCoder>

+ (nonnull instancetype)sharedCoder;

@end
