//
//  TNCVedioManager.h
//  SBVideoCaptureDemo
//
//  Created by 程国帅 on 15/9/23.
//  Copyright (c) 2015年 Pandara. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface TNCVedioManager : NSObject

@property (nonatomic,strong) NSURL *vedioUrl;

+ (instancetype)sharedInstance;

- (void)sharedInstanceEnterFull;

- (void)cannelVedioPalyer;
@end
