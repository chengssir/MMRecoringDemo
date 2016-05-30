//
//  ViewController.m
//  RecoringDemo
//
//  Created by 程国帅 on 16/1/5.
//  Copyright © 2016年 chengs. All rights reserved.
//
#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MMCaptitudeToolKit.h"
#import <AVFoundation/AVFoundation.h>
#import "MMCaptureDefine.h"
#import "MMRecoringView.h"
#import "UIView+TNNAdditions.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<MMRecoringViewDelegate,UIImagePickerControllerDelegate,AVAudioPlayerDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) MMRecoringView *videoView;
@property (weak, nonatomic) IBOutlet UIImageView *framesImageView;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.videoView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avPlayerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

}

- (IBAction)mmRecoringChick:(id)sender {

    if ([self authStatus]) {
        [_videoView initRecorder];
        _videoView.recorder.preViewLayer.hidden = YES;

    }
     [self.view bringSubviewToFront:_videoView];
     [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState

                     animations:^{
                         _videoView.bottom = SCREEN_HEIGHT;
                     } completion:^(BOOL finished) {
                         _videoView.recorder.preViewLayer.hidden = NO;

                     }];
}

-(void)animateWithDuration{
    
    [self.view addSubview:self.videoView];

    [UIView animateWithDuration:0.3 animations:^{
        _videoView.top = 0;
    } completion:^(BOOL finished) {
        _videoView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3];
    }];
}

-(UIView *)videoView
{
    if (!_videoView) {
         _videoView = [MMRecoringView sharedView];
        _videoView.delegate = self;
        _videoView.top = SCREEN_HEIGHT;
      }
    return _videoView;
}
-(BOOL)authStatus
{
    __block BOOL idAuthStatus = NO;

#if TARGET_IPHONE_SIMULATOR
    /**
     *  模拟器
     */
    NSLog(@"模拟器无法拍照");
#else
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                 completionHandler:^(BOOL granted) {
                                     if (granted) { //点击允许访问时调用
                                         idAuthStatus = YES;
                                     }
                                     dispatch_async(dispatch_get_main_queue(), ^{

                                          [UIView animateWithDuration:.3
                                                               delay:0
                                                             options:UIViewAnimationOptionBeginFromCurrentState
                                                          animations:^{
                                                              _videoView.top = SCREEN_HEIGHT;
                                                          } completion:NULL];
                                     });


                                 }];

    }else if (authStatus == AVAuthorizationStatusAuthorized) {
        idAuthStatus = YES;
    }else {
        [self showUIAlertView];
    }

#endif

    if (idAuthStatus) {
        idAuthStatus = [self microphoneEnable];
    }

    return idAuthStatus;
}

- (void)showUIAlertView
{
    UIAlertView* alerView = [[UIAlertView alloc] initWithTitle:@"请在iPhone的“设置-隐私”选项中，允许toon访问你的摄像头和麦克风。" message:nil delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
    [alerView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self videoInputDidTapBackspace:NO];
}

- (BOOL)microphoneEnable
{
    __block BOOL microphone = YES;
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            microphone = granted;
            if (!granted) {
                [self showUIAlertView];
            }
        }];
    }
    return microphone;
}

- (void)videoInputDidTapText:(NSString *)text{

    NSLog(@"-----%@",text);
    [self videoInputDidTapBackspace:NO];

    [self setVedioUrl:[NSURL URLWithString:text]];
    [self play];
}

- (void)videoInputDidTapBackspace:(BOOL)isSend
{
    [UIView animateWithDuration:0.3 animations:^{
        _videoView.top = SCREEN_HEIGHT;
    } completion:^(BOOL finished) {
    }];
}




- (void)setVedioUrl:(NSURL *)vedioUrl
{
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

    [self.view.layer addSublayer:playerLayer];

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

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}

-(void) dealloc
{
    NSLog(@"dealloc TNCVedioPalyerView");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

@end
