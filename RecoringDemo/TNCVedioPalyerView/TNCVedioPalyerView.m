//
//  TNCVedioPalyerView.m
//  SBVideoCaptureDemo
//
//  Created by 程国帅 on 15/9/23.
//  Copyright (c) 2015年 Pandara. All rights reserved.
//

#import "TNCVedioPalyerView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "UIView+TNNAdditions.h"

@interface TNCVedioPalyerView ()

@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
//@property (strong, nonatomic) AVPlayerItem *playerItem;
@end

@implementation TNCVedioPalyerView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avPlayerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:)
                                                     name:UIApplicationWillResignActiveNotification object:nil];

        UITapGestureRecognizer * tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
        [self addGestureRecognizer:tapImage];


        UILabel* leaveLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 100, 200, 30)];
        leaveLabel.text = @"轻触退出";
        leaveLabel.textColor = [UIColor whiteColor];
        leaveLabel.textAlignment = NSTextAlignmentCenter;
        leaveLabel.font = [UIFont systemFontOfSize:14.0];

        leaveLabel.centerX = [[UIScreen mainScreen] applicationFrame].size.width/2;
        leaveLabel.top = [[UIScreen mainScreen] applicationFrame].size.height/2- [[UIScreen mainScreen] applicationFrame].size.width/3-50+[[UIScreen mainScreen] applicationFrame].size.width/3*2+100+10;
        
        [self addSubview:leaveLabel];

        
    }
    return self;
}

- (void)sensorStateChange:(NSNotification *)notification
{
    [self tapImageView:nil];
}

-(void) dealloc
{
    NSLog(@"dealloc TNCVedioPalyerView");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}


- (void)tapImageView:(id)sender
{
    [_player pause];

    if ([self.v_delegate respondsToSelector:@selector(cannelVedioPalyer)]) {
        [self.v_delegate cannelVedioPalyer];
    }
    
}
+ (instancetype)vedioPalyerView:(CGRect)frame vedioUrl:(NSURL *)vedioUrl
{
    TNCVedioPalyerView *vedioPalyerView = [[self alloc] initWithFrame:frame];
    vedioPalyerView.vedioUrl = vedioUrl;
    return vedioPalyerView;
}

- (void)setVedioUrl:(NSURL *)vedioUrl
{
    _vedioUrl = vedioUrl;

    NSLog(@" 完成了一段视频====%@",vedioUrl);
    AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:vedioUrl options:nil];
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
    [playerItem seekToTime:kCMTimeZero];

    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    AVPlayerLayer* playerLayer = [AVPlayerLayer  playerLayerWithPlayer:self.player];

    playerLayer.frame = CGRectMake(0, [[UIScreen mainScreen] applicationFrame].size.height/2- [[UIScreen mainScreen] applicationFrame].size.width/3-50, [[UIScreen mainScreen] applicationFrame].size.width, [[UIScreen mainScreen] applicationFrame].size.width/3*2+100);

    playerLayer.player = self.player;

    if (self.playerLayer != nil) {
        [self.playerLayer removeFromSuperlayer];
    }

    self.playerLayer = playerLayer;

    [self.layer addSublayer:playerLayer];

}

-(void)play
{
    [self.player play];
}

#pragma mark - PlayEndNotification
- (void)avPlayerItemDidPlayToEnd:(NSNotification *)notification
{
    AVPlayerItem * p = [notification object];
    //关键代码
    [p seekToTime:kCMTimeZero];
    
    [_player play];
}
@end
