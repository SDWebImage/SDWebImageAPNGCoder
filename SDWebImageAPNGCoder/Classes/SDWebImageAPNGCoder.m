//
//  SDWebImageAPNGCoder.m
//  SDWebImageAPNGCoder
//
//  Created by DreamPiggy on 2017/11/2.
//

#import "SDWebImageAPNGCoder.h"
#import <SDWebImage/NSData+ImageContentType.h>
#import <SDWebImage/UIImage+MultiFormat.h>
#import <SDWebImage/SDWebImageFrame.h>
#import <SDWebImage/SDWebImageCoderHelper.h>
#import <SDWebImage/NSImage+WebCache.h>
#import <ImageIO/ImageIO.h>

// iOS 8 Image/IO framework binary does not contains these APNG contants, so we define them. Thanks Apple
#if (__IPHONE_OS_VERSION_MIN_REQUIRED && __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_9_0)
const CFStringRef kCGImagePropertyAPNGLoopCount = (__bridge CFStringRef)@"LoopCount";
const CFStringRef kCGImagePropertyAPNGDelayTime = (__bridge CFStringRef)@"DelayTime";
const CFStringRef kCGImagePropertyAPNGUnclampedDelayTime = (__bridge CFStringRef)@"UnclampedDelayTime";
#endif

@implementation SDWebImageAPNGCoder

+ (instancetype)sharedCoder
{
    static SDWebImageAPNGCoder *coder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coder = [[SDWebImageAPNGCoder alloc] init];
    });
    return coder;
}

- (BOOL)canDecodeFromData:(nullable NSData *)data {
    SDImageFormat format = [NSData sd_imageFormatForImageData:data];
    if (format == SDImageFormatPNG) {
        return YES;
    }
    return NO;
}

- (BOOL)canEncodeToFormat:(SDImageFormat)format {
    if (format == SDImageFormatPNG) {
        return YES;
    }
    return NO;
}

- (nullable UIImage *)decodedImageWithData:(nullable NSData *)data {
    if (!data) {
        return nil;
    }
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    if (!source) {
        return nil;
    }
    size_t count = CGImageSourceGetCount(source);
    
    UIImage *animatedImage;
    
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    } else {
        NSMutableArray<SDWebImageFrame *> *frames = [NSMutableArray array];
        
        for (size_t i = 0; i < count; i++) {
            CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, i, NULL);
            if (!imageRef) {
                continue;
            }
            
            float duration = [self sd_frameDurationAtIndex:i source:source];
#if SD_MAC
            UIImage *image = [[UIImage alloc] initWithCGImage:imageRef size:NSZeroSize];
#else
            UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
#endif
            CGImageRelease(imageRef);
            
            SDWebImageFrame *frame = [SDWebImageFrame frameWithImage:image duration:duration];
            [frames addObject:frame];
        }
        
        NSUInteger loopCount = 0;
        NSDictionary *imageProperties = (__bridge_transfer NSDictionary *)CGImageSourceCopyProperties(source, nil);
        NSDictionary *pngProperties = [imageProperties valueForKey:(__bridge_transfer NSString *)kCGImagePropertyPNGDictionary];
        if (pngProperties) {
            NSNumber *apngLoopCount = [pngProperties valueForKey:(__bridge_transfer NSString *)kCGImagePropertyAPNGLoopCount];
            if (apngLoopCount != nil) {
                loopCount = apngLoopCount.unsignedIntegerValue;
            }
        }
        
        animatedImage = [SDWebImageCoderHelper animatedImageWithFrames:frames];
        animatedImage.sd_imageLoopCount = loopCount;
    }
    
    CFRelease(source);
    
    return animatedImage;
}

- (float)sd_frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *pngProperties = frameProperties[(NSString *)kCGImagePropertyPNGDictionary];
    
    NSNumber *delayTimeUnclampedProp = pngProperties[(__bridge_transfer NSString *)kCGImagePropertyAPNGUnclampedDelayTime];
    if (delayTimeUnclampedProp != nil) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    } else {
        NSNumber *delayTimeProp = pngProperties[(__bridge_transfer NSString *)kCGImagePropertyAPNGDelayTime];
        if (delayTimeProp != nil) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    CFRelease(cfFrameProperties);
    return frameDuration;
}

- (nullable UIImage *)decompressedImageWithImage:(nullable UIImage *)image data:(NSData *__autoreleasing  _Nullable * _Nonnull)data options:(nullable NSDictionary<NSString *,NSObject *> *)optionsDict {
    return image;
}

- (nullable NSData *)encodedDataWithImage:(nullable UIImage *)image format:(SDImageFormat)format {
    if (!image) {
        return nil;
    }
    
    if (format != SDImageFormatPNG) {
        return nil;
    }
    
    NSMutableData *imageData = [NSMutableData data];
    CFStringRef imageUTType = [NSData sd_UTTypeFromSDImageFormat:SDImageFormatPNG];
    NSArray<SDWebImageFrame *> *frames = [SDWebImageCoderHelper framesFromAnimatedImage:image];
    
    CGImageDestinationRef imageDestination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)imageData, imageUTType, frames.count, NULL);
    if (!imageDestination) {
        // Handle failure.
        return nil;
    }
    if (frames.count == 0) {
        // for static single PNG images
        CGImageDestinationAddImage(imageDestination, image.CGImage, nil);
    } else {
        // for animated APNG images
        NSUInteger loopCount = image.sd_imageLoopCount;
        NSDictionary *pngProperties = @{(__bridge_transfer NSString *)kCGImagePropertyPNGDictionary: @{(__bridge_transfer NSString *)kCGImagePropertyAPNGLoopCount : @(loopCount)}};
        CGImageDestinationSetProperties(imageDestination, (__bridge CFDictionaryRef)pngProperties);
        
        for (size_t i = 0; i < frames.count; i++) {
            SDWebImageFrame *frame = frames[i];
            float frameDuration = frame.duration;
            CGImageRef frameImageRef = frame.image.CGImage;
            NSDictionary *frameProperties = @{(__bridge_transfer NSString *)kCGImagePropertyPNGDictionary : @{(__bridge_transfer NSString *)kCGImagePropertyAPNGUnclampedDelayTime : @(frameDuration)}};
            CGImageDestinationAddImage(imageDestination, frameImageRef, (__bridge CFDictionaryRef)frameProperties);
        }
    }
    // Finalize the destination.
    if (CGImageDestinationFinalize(imageDestination) == NO) {
        // Handle failure.
        imageData = nil;
    }
    
    CFRelease(imageDestination);
    
    return [imageData copy];
}

@end
