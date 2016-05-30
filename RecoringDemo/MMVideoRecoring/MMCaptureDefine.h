
//
//  MMCaptureDefine.h
//  RecoringDemo
//
//  Created by 程国帅 on 16/1/7.
//  Copyright © 2016年 chengs. All rights reserved.
//

#ifndef MMCaptureDefine_h
#define MMCaptureDefine_h

#define DEVICE_OS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

#define BAKCOLOR [UIColor colorWithRed:49/255.0 green:49/255.0 blue:49/255.0 alpha:1]


#define DELTA_Y (DEVICE_OS_VERSION >= 7.0f? 20.0f : 0.0f)


#define VIDEO_FOLDER @"videos"

#define MAX_VIDEO_R 10.0f
#define MIN_VIDEO_T 2.0f
#define RECORDERHEGHT SCREEN_WIDTH/4*3
#define PREVIEWHEGHT 350+(SCREEN_WIDTH/4*3 -240)
#define BUTTONHEGHT  80

#endif /* MMCaptureDefine_h */
