//
//  MMVideoRecringManager.m
//  RecoringDemo
//
//  Created by 程国帅 on 16/1/7.
//  Copyright © 2016年 chengs. All rights reserved.
//

#import "MMVideoRecringManager.h"
#import "MMCaptureDefine.h"
#import "MMCaptitudeToolKit.h"

@interface MMVideoData: NSObject

@property (assign, nonatomic) CGFloat duration;
@property (strong, nonatomic) NSURL *fileURL;

@end

@implementation MMVideoData

@end



#define COUNT_DUR_TIMER_INTERVAL 0.05

@interface MMVideoRecringManager ()

@property (strong, nonatomic) NSTimer *countDurTimer;
@property (assign, nonatomic) CGFloat currentVideoDur;
@property (assign, nonatomic) NSURL *currentFileURL;

@property (assign, nonatomic) BOOL isUsingFrontCamera;

@property (strong, nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (strong, nonatomic) MMVideoData * Videodata;
@property (assign, nonatomic) BOOL isRecring;

@end

@implementation MMVideoRecringManager


- (id)init
{
    self = [super init];
    if (self) {
        [self initalize];
    }
    
    return self;
}

- (void)initalize
{
    [self initCapture];
    
}

- (void)initCapture
{
    //session---------------------------------
    if (self.captureSession) {
        self.captureSession = nil;
    }
    
    self.captureSession = [[AVCaptureSession alloc] init];
    _captureSession.sessionPreset = AVCaptureSessionPreset640x480;

    //input
    [self registerAVCaptureDevice];
    
    //output
    [self registerAVCaptureMovieFileOutput];

    //preview layer------------------
    [self registerAVCaptureVideoPreviewLayer];
    
    //AVCaptureVideoDataOutput
    [self registerAVCaptureVideoDataOutput];
    
    [self addAVCaptureDeviceInput];

    [_captureSession startRunning];
    
    
}

-(void)registerAVCaptureDevice

{
//    [self resvideoDeviceInput];
    AVCaptureDevice *frontCamera = nil;
    AVCaptureDevice *backCamera = nil;
    
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if (camera.position == AVCaptureDevicePositionFront) {
            frontCamera = camera;
        } else {
            backCamera = camera;
        }
    }
    
    [backCamera lockForConfiguration:nil];
    if ([backCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [backCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    
    [backCamera unlockForConfiguration];
    
    self.videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:nil];
    if ([_captureSession canAddInput:_videoDeviceInput]) {
        [_captureSession addInput:_videoDeviceInput];
    }
}

-(void)registerAVCaptureMovieFileOutput
{
    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([_captureSession canAddOutput:_movieFileOutput])
    {
        [_captureSession addOutput:_movieFileOutput];
    }
}

-(void)registerAVCaptureVideoDataOutput
{
    self.output = [[AVCaptureVideoDataOutput alloc] init];
    if ([_captureSession canAddInput:_output]){
        [_captureSession addInput:_output];
    }
    self.output.videoSettings =
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange]
                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];

}


-(void)registerAVCaptureVideoPreviewLayer
{
    if (self.preViewLayer) {
        
        [self.preViewLayer removeFromSuperlayer];
    }
    self.preViewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    _preViewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
}

- (void)startCountDurTimer
{
    if (self.countDurTimer) {
        [_countDurTimer invalidate];
        self.countDurTimer = nil;
        _isRecring = YES;
    }
    _isRecring = NO;
    self.countDurTimer = [NSTimer scheduledTimerWithTimeInterval:COUNT_DUR_TIMER_INTERVAL target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
}

- (void)onTimer:(NSTimer *)timer
{
    self.currentVideoDur += COUNT_DUR_TIMER_INTERVAL;
    if ([_delegate respondsToSelector:@selector(videoDidRecordingToOutPutFileDuration:)]) {
        [_delegate videoDidRecordingToOutPutFileDuration:_currentVideoDur];
    }
    
    if (_currentVideoDur >= MAX_VIDEO_R) {
        [self stopCurrentVideoRecording:NO];
    }
}

- (void)stopCountDurTimer
{
    [_countDurTimer invalidate];
    self.countDurTimer = nil;
}

//必须是fileURL
//截取将会是视频的中间部分
//这里假设拍摄出来的视频总是高大于宽的

/*!
 
 @param fileURLArray
 包含所有视频分段的文件URL数组，必须是[NSURL fileURLWithString:...]得到的
 
 @discussion
 将所有分段视频合成为一段完整视频，并且裁剪为正方形
 */
- (void)mergeAndExportVideosAtFileURLs:(NSURL *)fileURL newUrl:(NSString *)mergeFilePath

{
    NSError *error = nil;
    
    CMTime totalDuration = kCMTimeZero;
    //转换AVAsset
    AVAsset *asset = [AVAsset assetWithURL:fileURL];
    if (!asset) {
        return;
    }
  
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    //提取音频、视频
    AVAssetTrack *assetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    //AVMediaTypeAudio
    [self audioTrackWith:mixComposition assetTrack:assetTrack asset:asset totalDuration:totalDuration error:error];
    
    //AVMediaTypeVideo
    AVMutableCompositionTrack *videoTrack = [self videoTrackWith:mixComposition assetTrack:assetTrack asset:asset totalDuration:totalDuration error:error];

    CGFloat renderW = [self videoTrackRenderSizeWithassetTrack:assetTrack];
    totalDuration = CMTimeAdd(totalDuration, asset.duration);

    NSMutableArray *layerInstructionArray = [self assetArrayWith:videoTrack totalDuration:totalDuration assetTrack:assetTrack renderW:renderW];

    [self mergingVideoWithmergeFilePath:mergeFilePath layerInstructionArray:layerInstructionArray mixComposition:mixComposition totalDuration:totalDuration renderW:renderW];
   
}

//压缩视频
-(void)mergingVideoWithmergeFilePath:(NSString *)mergeFilePath
               layerInstructionArray:(NSMutableArray*)layerInstructionArray
                      mixComposition:(AVMutableComposition *)mixComposition
                       totalDuration:(CMTime)totalDuration
                             renderW:(CGFloat)renderW

{
    //get save path
    NSURL *mergeFileURL = [NSURL fileURLWithPath:mergeFilePath];
    
    //export
    AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruciton.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
    mainInstruciton.layerInstructions = layerInstructionArray;
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = @[mainInstruciton];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    mainCompositionInst.renderSize = CGSizeMake(renderW, renderW/4*3);//renderW/4*3
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    exporter.videoComposition = mainCompositionInst;
    exporter.outputURL = mergeFileURL;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([_delegate respondsToSelector:@selector(videoRecorder:didFinishMergingVideosToOutPutFileAtURL:)]) {
                [_delegate videoRecorder:self didFinishMergingVideosToOutPutFileAtURL:mergeFileURL];
            }
        });
    }];
}

//合成视频
- (NSMutableArray *)assetArrayWith:(AVMutableCompositionTrack *)videoTrack
                     totalDuration:(CMTime)totalDuration
                        assetTrack:(AVAssetTrack *)assetTrack
                           renderW:(CGFloat)renderW

{
    NSMutableArray *layerInstructionArray = [[NSMutableArray alloc] init];

    AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    
    CGFloat rate;
    rate = renderW / MIN(assetTrack.naturalSize.width, assetTrack.naturalSize.height);
    
    CGAffineTransform layerTransform = CGAffineTransformMake(assetTrack.preferredTransform.a, assetTrack.preferredTransform.b, assetTrack.preferredTransform.c, assetTrack.preferredTransform.d, assetTrack.preferredTransform.tx * rate, assetTrack.preferredTransform.ty * rate);
    
    layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0, -(assetTrack.naturalSize.width - assetTrack.naturalSize.height/4*3) / 2.0));//向上移动取中部影响
    layerTransform = CGAffineTransformScale(layerTransform, rate, rate);//放缩，解决前后摄像结果大小不对称
    
    [layerInstruciton setTransform:layerTransform atTime:kCMTimeZero];
    [layerInstruciton setOpacity:0.0 atTime:totalDuration];
    //data
    [layerInstructionArray addObject:layerInstruciton];
    
    return layerInstructionArray;
}

//视频大小
-(CGFloat)videoTrackRenderSizeWithassetTrack:(AVAssetTrack *)assetTrack{
    
    CGSize renderSize = CGSizeMake(0, 0);
    renderSize.width = MAX(renderSize.width, assetTrack.naturalSize.height);
    renderSize.height = MAX(renderSize.height, assetTrack.naturalSize.width);
    return MIN(renderSize.width, renderSize.height);
}

//videoTrack
-(AVMutableCompositionTrack*)videoTrackWith:(AVMutableComposition *)mixComposition
                             assetTrack:(AVAssetTrack *)assetTrack
                                  asset:(AVAsset *)asset
                          totalDuration:(CMTime)totalDuration
                                  error:(NSError *)error{
    
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                        ofTrack:assetTrack
                         atTime:totalDuration
                          error:&error];


    return videoTrack;

}
//audioTrack
-(void)audioTrackWith:(AVMutableComposition *)mixComposition
                                 assetTrack:(AVAssetTrack *)assetTrack
                                      asset:(AVAsset *)asset
                              totalDuration:(CMTime)totalDuration
                                      error:(NSError *)error{
    
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    NSArray *array =  [asset tracksWithMediaType:AVMediaTypeAudio];
    if (array.count > 0) {
        AVAssetTrack *audiok =[array objectAtIndex:0];
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                            ofTrack:audiok
                             atTime:totalDuration
                              error:nil];
    }
    
}




- (AVCaptureDevice *)getCameraDevice:(BOOL)isFront
{
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *camera in cameras) {
        if (camera.position == AVCaptureDevicePositionBack) {
            backCamera = camera;
        } else {
            frontCamera = camera;
        }
    }
    
    if (isFront) {
        return frontCamera;
    }
    
    return backCamera;
}


//闪光灯
- (void)openTorch:(BOOL)open
{
    AVCaptureTorchMode torchMode;
    if (open) {
        torchMode = AVCaptureTorchModeOn;
    } else {
        torchMode = AVCaptureTorchModeOff;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        [device lockForConfiguration:nil];
        [device setTorchMode:torchMode];
        [device unlockForConfiguration];
    });
}

#pragma  mark - 切换摄像头
- (void)switchCamera
{
    
    [_captureSession beginConfiguration];
    
    [_captureSession removeInput:_videoDeviceInput];
    
    self.isUsingFrontCamera = !_isUsingFrontCamera;
    AVCaptureDevice *device = [self getCameraDevice:_isUsingFrontCamera];
    
    [device lockForConfiguration:nil];
    if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    [device unlockForConfiguration];
    
    self.videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    [_captureSession addInput:_videoDeviceInput];
    [_captureSession commitConfiguration];
}

#pragma  mark -再次进入

- (void)resetvideoDeviceInput
{
   
//    [self resvideoDeviceInput];

}

-(void)resvideoDeviceInput
{
    [_captureSession beginConfiguration];
    
    [_captureSession removeInput:_videoDeviceInput];
    
    AVCaptureDevice *device = [self getCameraDevice:NO];
    
    [device lockForConfiguration:nil];
    if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    [device unlockForConfiguration];
    
    self.videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if (_videoDeviceInput) {
        [_captureSession addInput:_videoDeviceInput];
//        [self addAVCaptureDeviceInput];
        [_captureSession commitConfiguration];
    }else{
        NSLog(@"-------- 无法启动相机");
    }
}


-(void)addAVCaptureDeviceInput
{
    if (_captureSession) {
        if (_audioDeviceInput) {
            [_captureSession removeInput:_audioDeviceInput];
        }
        _audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:nil];
        if (_audioDeviceInput) {
            [_captureSession addInput:_audioDeviceInput];
        }
    }
}

-(void)removeAVCaptureDeviceInput
{
    if (_captureSession) {
        [_captureSession removeInput:_audioDeviceInput];
    }
}

- (void)mergeVideoFiles:(NSString *)mergeFilePath
{
    [self mergeAndExportVideosAtFileURLs:self.Videodata.fileURL newUrl:mergeFilePath];
}
- (void)mergeVideoFiles
{
//    [self mergeAndExportVideosAtFileURLs:self.Videodata.fileURL ];
}

//总时长
- (CGFloat)getTotalVideoDuration
{
    return _currentVideoDur;
}

- (void)startRecordingToOutputFileURL:(NSURL *)fileURL
{
    self.currentVideoDur = 0.0f;
    self.Videodata.fileURL = fileURL;
    [_movieFileOutput startRecordingToOutputFileURL:fileURL recordingDelegate:self];
}

//暂停

- (void)stopCurrentVideoRecording:(BOOL)isDelete
{
    NSLog(@"停止录制视频");
    if (!_isRecring) {
        _isRecring = YES;
        _isDelete = isDelete;
        [self stopCountDurTimer];
        [_movieFileOutput stopRecording];
        if (!isDelete) {
            [_captureSession stopRunning];
        }
        NSLog(@"真的停止了吗");
    }
}

- (void)cancelRecorder
{
    [self deleteAllVideo];
}


//不调用delegate
- (void)deleteAllVideo
{
    
    [MMCaptitudeToolKit removeItemAtChatPath];

}


#pragma mark - AVCaptureFileOutputRecordignDelegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    self.currentFileURL = fileURL;
    NSLog(@"--fileURL----%@",fileURL);
    [self startCountDurTimer];
    
    if ([_delegate respondsToSelector:@selector(videoRecorder:didStartRecordingToOutPutFileAtURL:)]) {
        [_delegate videoRecorder:self didStartRecordingToOutPutFileAtURL:fileURL];
    }
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    NSLog(@"本段视频长度: %f", _currentVideoDur);
    
    
    if (_isDelete) {
        [self cancelRecorder];
        return;
    }
    if (_currentVideoDur > MIN_VIDEO_T) {
        if (!error) {
            self.Videodata = [[MMVideoData alloc]init];
            self.Videodata.duration = _currentVideoDur;
            self.Videodata.fileURL = outputFileURL;
        }
        
        
        if ([_delegate respondsToSelector:@selector(videoRecorder:didFinishRecordingToOutPutFileAtURL:duration:totalDur:error:)]) {
            [_delegate videoRecorder:self didFinishRecordingToOutPutFileAtURL:outputFileURL duration:_currentVideoDur totalDur:0 error:error];
        }
    }
    
    
}


@end
