//
//  MMVideoRecringManager.h
//  RecoringDemo
//
//  Created by 程国帅 on 16/1/7.
//  Copyright © 2016年 chengs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class MMVideoRecringManager;
@protocol MMVideoRecringManagerDelegate <NSObject>

@optional
//recorder开始录制一段视频时
- (void)videoRecorder:(MMVideoRecringManager *)videoRecorder didStartRecordingToOutPutFileAtURL:(NSURL *)fileURL;

//recorder完成一段视频的录制时
- (void)videoRecorder:(MMVideoRecringManager *)videoRecorder didFinishRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration totalDur:(CGFloat)totalDur error:(NSError *)error;

//recorder正在录制的过程中
- (void)videoDidRecordingToOutPutFileDuration:(CGFloat)videoDuration;

//发送停止回调、使键盘回收
- (void)movieFileOutputstopRecording;

//recorder完成视频的合成
- (void)videoRecorder:(MMVideoRecringManager *)videoRecorder didFinishMergingVideosToOutPutFileAtURL:(NSURL *)outputFileURL ;

@end

@interface MMVideoRecringManager : NSObject<AVCaptureFileOutputRecordingDelegate>

@property (weak, nonatomic) id <MMVideoRecringManagerDelegate> delegate;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preViewLayer;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (strong, nonatomic) AVCaptureDeviceInput *audioDeviceInput;
@property (strong, nonatomic) AVCaptureVideoDataOutput *output;
@property (assign ,nonatomic) BOOL isDelete;


- (CGFloat)getTotalVideoDuration;
- (void)startRecordingToOutputFileURL:(NSURL *)fileURL;
- (void)stopCurrentVideoRecording:(BOOL)isDelete;
- (void)deleteAllVideo;//不调用delegate
- (void)removeAVCaptureDeviceInput;

- (void)mergeVideoFiles:(NSString *)mergeFilePath;
- (void)resetvideoDeviceInput;

- (void)switchCamera;
- (void)openTorch:(BOOL)open;
- (void)stopCountDurTimer;

@end
