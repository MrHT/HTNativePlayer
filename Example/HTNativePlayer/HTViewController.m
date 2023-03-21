//
//  HTViewController.m
//  HTNativePlayer
//
//  Created by tao on 03/21/2023.
//  Copyright (c) 2023 tao. All rights reserved.
//

#import "HTViewController.h"
#import "HTNativePlayer.h"
@interface HTViewController ()

@end

@implementation HTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    HTNativePlayer *view = [[HTNativePlayer alloc] init];
    view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.view addSubview:view];
    
    view.autoPlay = YES;
    view.cyclePlay = YES;
    view.url = @"http://xxx";//替换视频URL
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
