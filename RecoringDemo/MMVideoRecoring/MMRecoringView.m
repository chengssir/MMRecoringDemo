//
//  RecoringView.m
//  RecoringDemo
//
//  Created by 程国帅 on 16/1/5.
//  Copyright © 2016年 chengs. All rights reserved.
//



#import "MMRecoringView.h"
#import <QuartzCore/QuartzCore.h>
#import "MMProgressBar.h"
#import "MMCaptitudeToolKit.h"
#import "MMVideoRecringManager.h"
#import "MMBaseButton.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import "UIView+TNNAdditions.h"

//#import "TNAChatMessageUtils.h"
//#import <ChatLibrary/ChatLibrary.h>

@interface MMRecoringView()

@property (strong, nonatomic) UIView *recordingBacView;

@property (strong, nonatomic) MMProgressBar *progressBar;

@property (strong, nonatomic) MMBaseButton *recordButton;

@property (assign, nonatomic) BOOL initalized;

@property (strong, nonatomic) UILabel *cannelLaebl;

@property (strong, nonatomic) UIImageView *markImageView;

@property (strong, nonatomic) UIImageView *redImageView;

@property (strong, nonatomic) UIButton *cordButton;

@property (strong, nonatomic) UIButton *backButton;

@property (assign, nonatomic) float  recordY;

@property (assign, nonatomic) BOOL isJust;

@end

@implementation MMRecoringView


+ (instancetype)sharedView {
    static MMRecoringView *v;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        v = [MMRecoringView new];
    });
    return v;
}

- (instancetype)init {
    self = [super init];
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.backgroundColor  = [UIColor clearColor];

    [self initrecordingBacView];
    [MMCaptitudeToolKit createVideoFolderIfNotExist];
    [self initProgressBar];
    [self initRecordButton];
    self.initalized = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:UIApplicationWillResignActiveNotification object:nil];

    return self;
}

- (void)sensorStateChange:(NSNotification *)notification
{
    [self stopCurrentVideoRecording:NO];
    
}

#pragma  mark - 初始化

- (void)initrecordingBacView
{
    self.recordingBacView = [[UIView alloc] initWithFrame:CGRectMake(0, 110, SCREEN_WIDTH, PREVIEWHEGHT)];
    self.recordingBacView.bottom = self.height;
    _recordingBacView.backgroundColor = BAKCOLOR;
    _recordingBacView.clipsToBounds = YES;
    [self addSubview:_recordingBacView];
    [self.recordingBacView addSubview:self.markImageView];
    [self.recordingBacView addSubview:self.redImageView];
    [self.recordingBacView addSubview:self.recorderImageView];

}


- (void)initProgressBar
{
    self.progressBar = [MMProgressBar getInstance];
    [MMCaptitudeToolKit setView:_progressBar toOriginY:RECORDERHEGHT+16];
    [self.recordingBacView addSubview:_progressBar];
}


- (void)initRecordButton
{
    _recordButton = [[MMBaseButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - BUTTONHEGHT) / 2.0, PREVIEWHEGHT - BUTTONHEGHT - 5, BUTTONHEGHT, BUTTONHEGHT)];
    [_recordButton setImage:[UIImage imageNamed:@"video_longvideo_btn_shoot.png"] forState:UIControlStateNormal];
    [_recordButton addTarget:self action:@selector(holdDownButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [_recordButton addTarget:self action:@selector(btnDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [_recordButton addTarget:self action:@selector(btnDragged:withEvent:) forControlEvents:UIControlEventTouchDragOutside];
    [_recordButton addTarget:self action:@selector(btnTouchUp:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    [_recordButton addTarget:self action:@selector(btnTouchUp:withEvent:) forControlEvents:UIControlEventTouchUpOutside];
    [self.recordingBacView addSubview:_recordButton];
    
    
    _cordButton = [[UIButton alloc] initWithFrame:CGRectMake(10, RECORDERHEGHT - BUTTONHEGHT, 80, 50)];
    _cordButton.centerY = _recordButton.centerY;
    [_cordButton setImage:[UIImage imageNamed:@"tnc_switchCamera.png"] forState:UIControlStateNormal];
    _cordButton.imageEdgeInsets = UIEdgeInsetsMake(4, 0, 4, 15);
    
    [_cordButton addTarget:self action:@selector(cordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [self.recordingBacView addSubview:_cordButton];
    
    
    
    _backButton = [[UIButton alloc] initWithFrame:CGRectMake(30, RECORDERHEGHT - BUTTONHEGHT, 80, 50)];
    _backButton.centerY = _recordButton.centerY;
    _backButton.right = SCREEN_WIDTH-10;
    [_backButton setImage:[UIImage imageNamed:@"video_longvideo_back.png"] forState:UIControlStateNormal];
    _backButton.imageEdgeInsets = UIEdgeInsetsMake(4, 15, 4, 0);
    [_backButton addTarget:self action:@selector(backButtonButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [self.recordingBacView addSubview:_backButton];
    
    
    
    _cannelLaebl = [[UILabel alloc]init];
    _cannelLaebl.textAlignment = NSTextAlignmentCenter;
    _cannelLaebl.hidden = YES;
    _cannelLaebl.layer.masksToBounds = YES;
    _cannelLaebl.layer.cornerRadius = 2;
    _cannelLaebl.font = [UIFont systemFontOfSize:14.0];
    [self setLabel];
    [self addSubview:_cannelLaebl];
    
}

#pragma  mark  - 视图加载

-(UIImageView *)markImageView
{
    if (!_markImageView) {
        _markImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 10)];
        _markImageView.top = 4;
        _markImageView.image = [UIImage imageNamed:@"video_longvideo_mark.png"];
        _markImageView.centerX = SCREEN_WIDTH/2;
        _markImageView.hidden = NO;
    }
    return _markImageView;
}

-(UIImageView *)recorderImageView
{
    if (!_recorderImageView) {
        _recorderImageView = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-54)/2, 16+(RECORDERHEGHT -37)/2, 54, 37)];
        _recorderImageView.image = [UIImage imageNamed:@"video_longvideo_loading.png"];
    }
    return _recorderImageView;
}


-(UIImageView *)redImageView
{
    if (!_redImageView) {
        _redImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 8, 8)];
        _redImageView.centerY = _markImageView.centerY;
        _redImageView.centerX = SCREEN_WIDTH/2;
        _redImageView.layer.cornerRadius = _redImageView.frame.size.width / 2;
        _redImageView.layer.masksToBounds = YES;
        _redImageView.backgroundColor = [UIColor redColor];
        _redImageView.hidden = YES;
    }
    return _redImageView;
}

- (void)willShowViewHandler {

    [self setButtonsHidden:NO];


}

#pragma  mark - 属性改变

- (void)setLabel{
    
    self.cannelLaebl.alpha = 1;
    self.cannelLaebl.frame = CGRectMake(0, 0, 100, 30);
    self.cannelLaebl.bottom = self.height - BUTTONHEGHT - 20;
    self.cannelLaebl.centerX = self.centerX;
    self.cannelLaebl.text = @"上移取消";
    self.cannelLaebl.textColor = [UIColor greenColor];
    self.cannelLaebl.backgroundColor = [UIColor clearColor];
    
}

-(void)setButtonsHidden:(BOOL)isHidden
{
    _backButton.hidden = _cordButton.hidden = _recordButton.hidden = isHidden;
}

-(void)setmarkImageViewAndredImageView:(BOOL)isHidden
{
    _markImageView.hidden = isHidden;
    _redImageView.hidden = !isHidden;
}

#pragma mark -
-(void)resetvideoDeviceInput
{
    [_recorder resetvideoDeviceInput];
    
}

- (void)initRecorder
{
    CGFloat tim= 0.15;
    [self performSelector:@selector(performRecorder) withObject:nil afterDelay:tim];

}


-(void)performRecorder
{
    if ([self authStatus]) {
        self.recorder = [[MMVideoRecringManager alloc] init];
        _recorder.delegate = self;
        _recorder.preViewLayer.frame = CGRectMake(0, 16, SCREEN_WIDTH, RECORDERHEGHT);
        [self.recordingBacView.layer addSublayer:_recorder.preViewLayer];
        _isJust = YES;
    }
}

-(void)removeAVCaptureDeviceInput
{
    [_recorder removeAVCaptureDeviceInput];
    
}


- (void)backButtonButtonTouchDown
{
    if (!self.initalized) {
        [self videoInputDidTapBackspace:NO];
        [_recorder removeAVCaptureDeviceInput];

    }
}
- (void)cordButtonTouchDown
{
    if (!self.initalized) {
        [_recorder switchCamera];
    }
}



-(void)videoInputDidTapBackspace:(BOOL)isSend{
    if ([_delegate respondsToSelector:@selector(videoInputDidTapBackspace:)]) {
        self.backgroundColor = [UIColor clearColor];
        [_delegate videoInputDidTapBackspace:isSend];
    }
}


-(void)movieFileOutputstopRecording{
    
    [self videoInputDidTapBackspace:YES];

}

#pragma  mark - 录制按钮事件
//松开手
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint currentLocation = [touch locationInView:self];
    BOOL touchOutside = CGRectContainsPoint(self.recordingBacView.bounds, currentLocation);
    if (touchOutside) {
        if (!self.initalized) {
            [self backButtonButtonTouchDown];
            
        }
    }
    
}

- (void)holdDownButtonTouchDown {
    if (![self authStatus]) {
        return;
    }
    if (_isJust) {
        _isJust = NO;
        [self resetvideoDeviceInput];
    }

    _recordY = 600;
    [self setLabel];
    self.initalized = YES;
    self.cannelLaebl.hidden = NO;
    _progressBar.barView.hidden = NO;
    [self setmarkImageViewAndredImageView:YES];
    [_progressBar setLastProgressToWidth:SCREEN_WIDTH];
    [self setButtonsHidden:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kVodio_RecordingProcessing" object:nil userInfo:@{@"isRecording":@(1)}];

    NSString *filePath = [MMCaptitudeToolKit getVideoSaveFilePathString];
    [_recorder startRecordingToOutputFileURL:[NSURL fileURLWithPath:filePath]];
    
}

- (void)btnDragged:(UIButton *)sender withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];

    CGPoint currentLocation = [touch locationInView:self];
//    float difference  = currentLocation.y - _recordY;
//    if (fabsf(difference) > 200) {
//        return;
//    }

    if (currentLocation.y < self.height - BUTTONHEGHT-5) {
        _cannelLaebl.backgroundColor = [UIColor colorWithRed:255/255.0 green:0 blue:0 alpha:.7];
        _cannelLaebl.text = @"松手取消发送";
        _cannelLaebl.textColor = [UIColor whiteColor];
        _cannelLaebl.bottom = currentLocation.y;
        _progressBar.barView.backgroundColor =  _cannelLaebl.backgroundColor;
        
    }else{
        _cannelLaebl.backgroundColor = [UIColor clearColor];
        _cannelLaebl.bottom = self.height - BUTTONHEGHT -20;
        _cannelLaebl.text = @"上移取消";
        _cannelLaebl.textColor = [UIColor greenColor];
        _progressBar.barView.backgroundColor = [UIColor greenColor];
        
    }
    _recordY = currentLocation.y;
    
}
- (void)btnTouchUp:(UIButton *)sender withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint currentLocation = [touch locationInView:self];
    

    if (currentLocation.y < self.height - BUTTONHEGHT-5) {
        
        [_recorder deleteAllVideo];
        [self stopCurrentVideoRecording:YES];
        [self setButtonsHidden:NO];

    }else{
        
        if ([_recorder getTotalVideoDuration] < MIN_VIDEO_T) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"视频太短了" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [alertView show];
            [_recorder deleteAllVideo];
            [self stopCurrentVideoRecording:YES];
            [self setButtonsHidden:NO];

        }else{
            [self stopCurrentVideoRecording:NO];
        }

    }
    
}

-(void)stopCurrentVideoRecording:(BOOL)isFinish
{
    [self setProgressBar];
    [_recorder stopCurrentVideoRecording:isFinish];
    [self setmarkImageViewAndredImageView:NO];
    self.initalized = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kVodio_RecordingProcessing" object:nil userInfo:@{@"isRecording":@(0)}];


}

-(void)setProgressBar
{
    [UIView animateWithDuration:0.3 animations:^{
        self.cannelLaebl.alpha = 0;
    } completion:^(BOOL finished) {
        self.cannelLaebl.hidden = YES;
    }];
    
    _progressBar.barView.hidden = YES;
    _progressBar.barView.backgroundColor = [UIColor greenColor];
    [_progressBar setLastProgressToWidth:SCREEN_WIDTH];
    
}


//进行处理
- (void)pressOKButton
{
    NSLog(@"DASDASDA");
    NSString *filePath = [MMCaptitudeToolKit getgetLocalPathByURLByFileName:[MMCaptitudeToolKit getUUIDString] ofType:@"mp4"];
    [_recorder mergeVideoFiles:filePath];
}

#pragma mark - SBVideoRecorderDelegate
//开始录制  返回路径
- (void)videoRecorder:(MMVideoRecringManager *)videoRecorder didStartRecordingToOutPutFileAtURL:(NSURL *)fileURL
{
    NSLog(@"正在录制视频: %@", fileURL);
    [self.progressBar addProgressView];
    
    
}
//完成录制
- (void)videoRecorder:(MMVideoRecringManager *)videoRecorder didFinishRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration totalDur:(CGFloat)totalDur error:(NSError *)error
{
    [self setProgressBar];

    if (error) {
        NSLog(@"录制视频错误:%@", error);
        [self.delegate videoInputDidTapText:nil];
    } else {

        [self pressOKButton];
         NSLog(@"录制视频完成: %@", outputFileURL);
    }
    
}

//实时长度
- (void)videoDidRecordingToOutPutFileDuration:(CGFloat)videoDuration
{
    [_progressBar setLastProgressToWidth:videoDuration / MAX_VIDEO_R * _progressBar.frame.size.width];
}

//转换完成  等等的
- (void)videoRecorder:(MMVideoRecringManager *)videoRecorder didFinishMergingVideosToOutPutFileAtURL:(NSURL *)outputFileURL
{
    NSLog(@"--videoDuration---%@",outputFileURL);
    self.backgroundColor  = [UIColor clearColor];
    [self setmarkImageViewAndredImageView:NO];
    [_recorder deleteAllVideo];
    //返回上一页
    [self setButtonsHidden:NO];

    dispatch_async(dispatch_get_main_queue(), ^{
    [self.delegate videoInputDidTapText:[outputFileURL absoluteString]];
    [_recorder removeAVCaptureDeviceInput];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kVodio_RecordingProcessing" object:nil userInfo:@{@"isRecording":@(0)}];
    });
}

- (BOOL)authStatus
{
    __block BOOL idAuthStatus = YES;
    
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
                                     }
                                     else {
                                         idAuthStatus = NO;
                                     }
                                     
                                 }];
        
    }else if (authStatus == AVAuthorizationStatusAuthorized) {
    }else {
        idAuthStatus = NO;
    }
    
#endif
    
    if (idAuthStatus) {
        idAuthStatus = [self microphoneEnable];
    }
    
    return idAuthStatus;
}

- (void)showUIAlertView
{
    UIAlertView* alerView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请在iPhone的“设置-隐私-麦克风”选项中，允许toon访问你的手机麦克风。" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
    [alerView show];
}

- (BOOL)microphoneEnable
{
    __block BOOL microphone = YES;
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            microphone = granted;
        }];
    }
    return microphone;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


@end
