# SDWebImageAPNGCoder

[![CI Status](http://img.shields.io/travis/SDWebImage/SDWebImageAPNGCoder.svg?style=flat)](https://travis-ci.org/dreampiggy/SDWebImageAPNGCoder)
[![Version](https://img.shields.io/cocoapods/v/SDWebImageAPNGCoder.svg?style=flat)](http://cocoapods.org/pods/SDWebImageAPNGCoder)
[![License](https://img.shields.io/cocoapods/l/SDWebImageAPNGCoder.svg?style=flat)](http://cocoapods.org/pods/SDWebImageAPNGCoder)
[![Platform](https://img.shields.io/cocoapods/p/SDWebImageAPNGCoder.svg?style=flat)](http://cocoapods.org/pods/SDWebImageAPNGCoder)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

This is a demo to show how to build animated coder which use coder helper from SDWebImage. Althrough this code is nearly same with GIF coder, but it can be a good demo to look in.

## Requirements

+ iOS 8
+ macOS 10.10
+ tvOS 9.0
+ watchOS 2.0

## Installation

SDWebImageAPNGCoder is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SDWebImageAPNGCoder'
```

## Usage

```objective-c
SDWebImageAPNGCoder *APNGCoder = [SDWebImageAPNGCoder sharedCoder];
[[SDWebImageCodersManager sharedInstance] addCoder:APNGCoder];
UIImageView *imageView;
NSURL *APNGURL;
[imageView sd_setImageWithURL:APNGURL];
```

## Screenshot

<img src="https://raw.githubusercontent.com/SDWebImage/SDWebImageAPNGCoder/master/Example/Screenshot/APNGDemo.png" width="300" />

## Author

DreamPiggy

## License

SDWebImageAPNGCoder is available under the MIT license. See the LICENSE file for more info.
