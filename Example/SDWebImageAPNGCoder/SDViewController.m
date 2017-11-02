//
//  SDViewController.m
//  SDWebImageAPNGCoder
//
//  Created by dreampiggy on 11/02/2017.
//  Copyright (c) 2017 dreampiggy. All rights reserved.
//

#import "SDViewController.h"
#import <SDWebImageAPNGCoder/SDWebImageAPNGCoder.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDWebImageCodersManager.h>

@interface SDViewController ()

@end

@implementation SDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SDWebImageAPNGCoder *APNGCoder = [SDWebImageAPNGCoder sharedCoder];
    [[SDWebImageCodersManager sharedInstance] addCoder:APNGCoder];
    NSURL *staticPNGURL = [NSURL URLWithString:@"https://upload.wikimedia.org/wikipedia/commons/4/47/PNG_transparency_demonstration_1.png"];
    NSURL *animatedAPNGURL = [NSURL URLWithString:@"http://apng.onevcat.com/assets/elephant.png"];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height / 2)];
    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, screenSize.height / 2, screenSize.width, screenSize.height / 2)];
    
    [self.view addSubview:imageView1];
    [self.view addSubview:imageView2];
    
    [imageView1 sd_setImageWithURL:staticPNGURL completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (image) {
            NSLog(@"Static PNG load success");
        }
    }];
    [imageView2 sd_setImageWithURL:animatedAPNGURL completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (image.images) {
            NSLog(@"Animated APNG load success");
        }
    }];
	// Do any additional setup after loading the view, typically from a nib.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
