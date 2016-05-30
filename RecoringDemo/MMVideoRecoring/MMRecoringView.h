//
//  RecoringView.h
//  RecoringDemo
//
//  Created by 程国帅 on 16/1/5.
//  Copyright © 2016年 chengs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MMCaptureDefine.h"
#import "MMVideoRecringManager.h"

@protocol MMRecoringViewDelegate <NSObject>

- (void)videoInputDidTapText:(NSString *)text;

- (void)videoInputDidTapBackspace:(BOOL)isSend;

@end

@interface MMRecoringView : UIView<MMVideoRecringManagerDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) id<MMRecoringViewDelegate> delegate;

@property (strong, nonatomic) MMVideoRecringManager *recorder;

@property (strong, nonatomic) UIImageView *recorderImageView;

+ (instancetype)sharedView;
- (void)initRecorder;
-(void)resetvideoDeviceInput;
-(void)removeAVCaptureDeviceInput;
@end
