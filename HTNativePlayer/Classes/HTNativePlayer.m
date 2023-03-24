//
//  FHLNativePlayerView.m
//  ZYPlayer-OC
//
//  Created by Car on 2023/3/16.
//  Copyright © 2023 嘴爷. All rights reserved.
//

#import "HTNativePlayer.h"
#import <Masonry/Masonry.h>

#import <MBProgressHUD/MBProgressHUD.h>

@interface HTNativePlayer ()
{
    NSArray* _observerKeyPathes;
    NSDictionary* _notificationInfos;
}
@property (nonatomic, strong) AVPlayerLayer* playerLayer;
@property (nonatomic, strong) AVPlayer* player;
@property (nonatomic, strong) AVPlayerItem* playerItem;

@property (nonatomic, strong) UIView *controllView;
@property (nonatomic, strong) UIView *progressBgView;
@property (strong, nonatomic) UIProgressView* progressView;
@property (strong, nonatomic) UILabel *currentTimeLabel;
@property (strong, nonatomic) UILabel *totalTimeLabel;
@property (strong, nonatomic) UISlider *slider;
@property (nonatomic, strong) UIImageView *playImg;

@property (nonatomic, strong) CADisplayLink* disPlayLink;
@property (nonatomic, assign) BOOL running;
@end


@implementation HTNativePlayer

- (instancetype)init{
    
    self = [super init];
    
    if (self) {
        
        [self configUI];
        
        [self addNotification];
    }
    
    return self;
}

- (void)setUrl:(NSString *)url{
    _url = url;
    
    NSURL *fileUrl;
    if ([url hasPrefix:@"http"]){
        fileUrl = [NSURL URLWithString:url];
    }else{
        fileUrl = [NSURL fileURLWithPath:url];
    }

    self.playerItem = [AVPlayerItem playerItemWithURL:fileUrl];

    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];

    if (self.playerLayer) {
        [self.playerLayer removeFromSuperlayer];
    }
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;//填充模式
    self.playerLayer.backgroundColor = [UIColor blackColor].CGColor;

    self.playerLayer.frame = self.bounds;//需要给一个初始值
    [self.layer insertSublayer:self.playerLayer atIndex:0 ];

    [self addObserverForPlayerItem];
    
//    [MBProgressHUD showHUDAddedTo:self.controllView animated:YES];
    [self.player play];
}

- (void)configUI{
    
    [self addSubview:self.controllView];
    [self.controllView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self insertSubview:self.progressBgView aboveSubview:self.controllView];
    [self.progressBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.mas_equalTo(44);
        make.bottom.equalTo(self).offset(-16);
    }];
    
    [self.controllView addSubview:self.playImg];
    [self.playImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.controllView);
    }];
    
    [self.progressBgView addSubview:self.currentTimeLabel];
    [self.progressBgView addSubview:self.progressView];
    [self.progressBgView addSubview:self.totalTimeLabel];
    [self.progressBgView addSubview:self.slider];
    
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.progressBgView).offset(12);
        make.centerY.equalTo(self.progressBgView);
        make.width.mas_greaterThanOrEqualTo(40);
    }];
    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.progressBgView).offset(-12);
        make.centerY.equalTo(self.progressBgView);
        make.width.mas_greaterThanOrEqualTo(40);
    }];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.currentTimeLabel.mas_right).offset(4);
        make.right.equalTo(self.totalTimeLabel.mas_left).offset(-4);
        make.centerY.equalTo(self.progressBgView);
    }];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.progressView);
        make.centerY.equalTo(self.progressView);
    }];
    
    
}

- (void)setStartImage:(UIImage *)startImage{
    if (startImage) {
        self.playImg.image = startImage;
    }
}

- (void)setSliderImage:(UIImage *)sliderImage{
    
    if (sliderImage) {
        
        [self.slider setThumbImage:sliderImage forState:UIControlStateNormal];
        [self.slider setThumbImage:sliderImage forState:UIControlStateHighlighted];
        [self.slider setThumbImage:sliderImage forState:UIControlStateDisabled];
    }
}

- (void)setProgressFromBottom:(CGFloat)progressFromBottom{
    [self.progressBgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-progressFromBottom);
    }];
}

- (void)setProgressBgColor:(UIColor *)progressBgColor{
    self.progressView.progressTintColor = progressBgColor;
}

- (void)setBufferingColor:(UIColor *)bufferingColor{
    
    self.progressView.trackTintColor = bufferingColor;
}

- (void)setSliderProgressColor:(UIColor *)sliderProgressColor{
    self.slider.minimumTrackTintColor = sliderProgressColor;
}


-(void)addNotification{
    _notificationInfos = @{UIDeviceOrientationDidChangeNotification: @"screenRotate:",
                           AVPlayerItemDidPlayToEndTimeNotification: @"playToEnd:",
                           AVPlayerItemFailedToPlayToEndTimeNotification: @"failedToPlay:",
                           AVPlayerItemPlaybackStalledNotification: @"playbackStalled:",
                           AVAudioSessionInterruptionNotification: @"audioSessionInterruption:",
                           AVAudioSessionRouteChangeNotification: @"audioSessionRouteChange:",
                           UIApplicationWillResignActiveNotification: @"applicationWillResignActive:",
                           UIApplicationDidBecomeActiveNotification: @"applicationDidBecomeActive:"
                           };
    for (NSString* notificationName in _notificationInfos.allKeys) {
        NSString* method = _notificationInfos[notificationName];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:NSSelectorFromString(method) name:notificationName object:nil];
    }
}

#pragma mark - notification
//返回前台
-(void)applicationDidBecomeActive:(NSNotification*)notification{
    NSLog(@"applicationDidBecomeActive");
}

//进入后台
-(void)applicationWillResignActive:(NSNotification*)notification{
    NSLog(@"applicationWillResignActive");
    [self stopPlay];
}

//耳机插入和拔出的通知
-(void)audioSessionRouteChange:(NSNotification*)notification{
    NSLog(@"audioSessionRouteChange");
    [self stopPlay];
}

//声音被打断的通知（电话打来）
-(void)audioSessionInterruption:(NSNotification*)notification{
    NSLog(@"audioSessionInterruption");
    [self stopPlay];
}

//播放失败
-(void)playbackStalled:(NSNotification*)notification{
    NSLog(@"playbackStalled");
    if (self.delegate && [self.delegate respondsToSelector:@selector(onplayerViewError:)]) {
        [self.delegate onplayerViewError:self.player];
    }
}

//异常中断
-(void)failedToPlay:(NSNotification*)notification{
    NSLog(@"failedToPlay");
}

//播放完成
-(void)playToEnd:(NSNotification*)notification{
    NSLog(@"播放完了");
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayCompletedWithCurrentPlayer:)]) {
        [self.delegate videoPlayCompletedWithCurrentPlayer:self.player];
    }
    
    CMTime time = self.player.currentTime;
    time.value = 0;
    [self.player seekToTime:time completionHandler:^(BOOL finished) {
        NSLog(@"seek到初始位置");

        if (self.cyclePlay) {
            [self.player play];
        }else{
            [self stopPlay];
        }
        
    }];
}

//屏幕旋转
-(void)screenRotate:(NSNotification*)notification{
    
    /*
     UIDeviceOrientationPortrait,            // Device oriented vertically, home button on the bottom
     UIDeviceOrientationPortraitUpsideDown,  // Device oriented vertically, home button on the top
     UIDeviceOrientationLandscapeLeft,       // Device oriented horizontally, home button on the right
     UIDeviceOrientationLandscapeRight,      // Device oriented horizontally, home button on the left
     */
    
    //    UIDevice* device = notification.object;
    //    NSLog(@"notification:::%@", @(device.orientation));
}


-(void)addObserverForPlayerItem{
    _observerKeyPathes = @[@"status",                   //播放器状态变化
                           @"loadedTimeRanges",         //缓冲进度
                           @"playbackBufferEmpty",      // 缓冲区空了，需要等待数据
                           @"playbackLikelyToKeepUp"    //缓存足够播放的状态
                           ];
    for (NSString* keyPath in _observerKeyPathes) {
        [self.playerItem addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        NSLog(@"self.playerItem.status = %ld",(long)self.playerItem.status);
        if (self.playerItem.status == AVPlayerStatusReadyToPlay) {
            
            CGFloat duration = CMTimeGetSeconds(self.playerItem.duration);
            NSLog(@"媒体就绪，播放时长：%f", duration);
            NSLog(@"播放视图大小：%@", @(self.playerLayer.videoRect));

//            [MBProgressHUD hideHUDForView:self.controllView animated:YES];
            self.totalTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)duration / 60, (int)duration % 60];
            
            if(self.autoPlay) {
                [self startPlay];
            }else{
                [self stopPlay];
            }
            
        }else {
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(onplayerViewError:)]) {
                [self.delegate onplayerViewError:self.player];
            }
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]){
        
        NSArray* ranges = change[@"new"];
        
        if ([ranges isKindOfClass:[NSArray class]] && ranges.count > 0) {
            CMTimeRange range = [[ranges firstObject] CMTimeRangeValue];
            CMTime bufferDuration = CMTimeAdd(range.start, range.duration);
            NSLog(@"缓冲进度%f", CMTimeGetSeconds(bufferDuration));
            self.progressView.progress = CMTimeGetSeconds(bufferDuration) / CMTimeGetSeconds(self.playerItem.duration);
        }
        
    }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]){//视频缓冲开始
        NSLog(@"缓冲区空了，需要等待数据playbackBufferEmpty:%@", change);
//        [MBProgressHUD showHUDAddedTo:self.controllView animated:YES];
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){//视频缓冲结束
        NSLog(@"缓存足够播放的状态playbackLikelyToKeepUp:%@", change);
//        [MBProgressHUD hideHUDForView:self.controllView animated:YES];
    }
}

- (void)sliderChange:(UISlider *)slider{
    
    NSLog(@"%lf",slider.value);
    
    [self seekToPosion];
}

-(void)seekToPosion{
    CGFloat duration = CMTimeGetSeconds(self.playerItem.duration);
    CGFloat currentTime = duration * self.slider.value;
    CMTime time = self.player.currentTime;
    time.value = currentTime * time.timescale;
    [self.player seekToTime:time completionHandler:^(BOOL finished) {
        NSLog(@"seek到 %f 位置", currentTime);
        if (self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying){
            [self.player play];
        }
        
    }];
}

- (void)updateProgressUI:(CADisplayLink*)displayLink{
 
    CGFloat duration = CMTimeGetSeconds(self.playerItem.duration);
    if (duration <= 0) {
        return;
    }
    
    CGFloat currentTime = CMTimeGetSeconds(self.playerItem.currentTime);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onCurrentPositionCurrentPlayerUpdate:position:)]) {
        [self.delegate onCurrentPositionCurrentPlayerUpdate:self.player position:currentTime];
    }
    
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)currentTime / 60, (int)currentTime % 60];
    
    self.slider.value = currentTime / duration;
}

- (void)startRunloop{
    
    if (!self.running) {
        self.disPlayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgressUI:)];
        [self.disPlayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        self.running = YES;
    }
}
- (void)stopRunloop{
    if (self.running) {
        
        [self.disPlayLink invalidate];
        self.disPlayLink = nil;
        self.running = NO;
    }
}

- (UIView *)controllView{
    if (!_controllView){
        _controllView = [[UIView alloc] init];
        
        UITapGestureRecognizer *res = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ceshi)];
        [_controllView addGestureRecognizer:res];
    }
    return _controllView;
}

- (void)ceshi{
    NSLog(@"ceshiceshi");
    
    if (self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
        
        [self stopPlay];
        
    }else if (self.player.timeControlStatus == AVPlayerTimeControlStatusPaused) {
        
        [self startPlay];
    }
}

- (void)startPlay{
    
    [self.player play];
    [self startRunloop];
    self.playImg.hidden = YES;
}

- (void)stopPlay{
    
    [self.player pause];
    [self stopRunloop];
    self.playImg.hidden = NO;
}



- (UIView *)progressBgView{
    if (!_progressBgView) {
        _progressBgView = [[UIView alloc] init];
        _progressBgView.backgroundColor = [UIColor clearColor];
    }
    return _progressBgView;
}
- (UIProgressView *)progressView{
    if (!_progressView){
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.progressTintColor = [UIColor lightGrayColor];
        _progressView.trackTintColor = [UIColor systemGrayColor];
        
    }
    return _progressView;
}

- (UILabel *)currentTimeLabel{
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.font = [UIFont systemFontOfSize:12];
        _currentTimeLabel.text = @"00:00";
    }
    return _currentTimeLabel;
}
- (UILabel *)totalTimeLabel{
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc] init];
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.font = [UIFont systemFontOfSize:12];
        _totalTimeLabel.text = @"00:00";
        _totalTimeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _totalTimeLabel;
}
- (UISlider *)slider{
    if (!_slider) {
        _slider = [[UISlider alloc] init];
        _slider.minimumTrackTintColor = [UIColor whiteColor];
        [_slider setThumbImage:[UIImage imageNamed:@"sliderImg"] forState:UIControlStateNormal];
        [_slider setThumbImage:[UIImage imageNamed:@"sliderImg"] forState:UIControlStateHighlighted];
        [_slider setThumbImage:[UIImage imageNamed:@"sliderImg"] forState:UIControlStateDisabled];
        [_slider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
        [_slider addTarget:self action:@selector(UIControlEventTouchDragInside) forControlEvents:UIControlEventTouchDragInside];
        [_slider addTarget:self action:@selector(UIControlEventTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    }
    return _slider;
}
- (UIImageView *)playImg{
    if (!_playImg) {
        _playImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fhl_btn_play"] highlightedImage:[UIImage imageNamed:@"fhl_btn_play"]];
        _playImg.contentMode = UIViewContentModeCenter;
    }
    return _playImg;
}

- (void)UIControlEventTouchDragInside{
    [self stopRunloop];
}
- (void)UIControlEventTouchUpInside{
    if (self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
        [self startRunloop];
    }
    
}


@end
