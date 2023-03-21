//
//  FHLNativePlayerView.h
//  ZYPlayer-OC
//
//  Created by Car on 2023/3/16.
//  Copyright © 2023 嘴爷. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
NS_ASSUME_NONNULL_BEGIN

@protocol FHLNativePlayerViewDelegate <NSObject>

/**
 播放完成
 */
- (void)videoPlayCompletedWithCurrentPlayer:(AVPlayer*)player;

/**
 @brief 视频当前播放位置回调
 @param player 播放器player指针
 @param position 视频当前播放位置
 */
- (void)onCurrentPositionCurrentPlayerUpdate:(AVPlayer*)player position:(CGFloat)position;

/**
 @brief 错误代理回调
 */
- (void)onplayerViewError:(AVPlayer*)player;

@end

@interface HTNativePlayer : UIView

/**
 是否需要自动播放，默认no
 */
@property (nonatomic, assign) BOOL autoPlay;

/**
 开始播放按钮图标
 */
@property (nonatomic, strong) UIImage *startImage;

/**
 是否需要循环播放，默认no
 */
@property (nonatomic, assign) BOOL cyclePlay;

/**
 自定义进度条图标
 */
@property (nonatomic, strong) UIImage *sliderImage;

/**
  视频进度条距离底部的距离
 */
@property (nonatomic, assign) CGFloat progressFromBottom;

/**
 视频进度条背景色
 */
@property (nonatomic, strong) UIColor *progressBgColor;

/**
 视频缓冲进度条背景色
 */
@property (nonatomic, strong) UIColor *bufferingColor;

/**
 视频已播放进度条背景色
 */
@property (nonatomic, strong) UIColor *sliderProgressColor;

@property (nonatomic, weak) id <FHLNativePlayerViewDelegate> delegate;

/**
 支持网络视频和本地视频
 */
@property (nonatomic, strong) NSString *url;

@end

NS_ASSUME_NONNULL_END
