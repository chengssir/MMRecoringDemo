//
//  GSProgressBar.h
//
//
//  Created by 程国帅 on 16-1-6.
//  Copyright (c) 2016年 思源. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "MMCaptureDefine.h"

@interface MMProgressBar : UIView

@property (strong, nonatomic) UIView *barView;

+ (MMProgressBar *)getInstance;

- (void)addProgressView;

- (void)setLastProgressToWidth:(CGFloat)width;

- (void)setProgressViewFrame;
@end
