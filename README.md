# HTNativePlayer

[![CI Status](https://img.shields.io/travis/tao/HTNativePlayer.svg?style=flat)](https://travis-ci.org/tao/HTNativePlayer)
[![Version](https://img.shields.io/cocoapods/v/HTNativePlayer.svg?style=flat)](https://cocoapods.org/pods/HTNativePlayer)
[![License](https://img.shields.io/cocoapods/l/HTNativePlayer.svg?style=flat)](https://cocoapods.org/pods/HTNativePlayer)
[![Platform](https://img.shields.io/cocoapods/p/HTNativePlayer.svg?style=flat)](https://cocoapods.org/pods/HTNativePlayer)


###  iOS原生视频播放器控件，支持本地视频和网络视频

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

HTNativePlayer is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
添加头文件：#import "HTNativePlayer.h"

HTNativePlayer *view = [[HTNativePlayer alloc] init];
view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
[self.view addSubview:view];
self.playView = view;
view.autoPlay = YES;
view.cyclePlay = YES;
view.url = @"http://xxx";

```

## Author

tao, xxx

## License

HTNativePlayer is available under the MIT license. See the LICENSE file for more info.
