//
//  TNCVedioManager.m
//  SBVideoCaptureDemo
//
//  Created by 程国帅 on 15/9/23.
//  Copyright (c) 2015年 Pandara. All rights reserved.
//

#import "TNCVedioManager.h"
#import "TNCVedioPalyerView.h"

@interface TNCVedioManager()<TNCVedioPalyerDelegate>

@property (nonatomic,strong) UIView                 *containerView;     // 当前显示的item视图的数据源左侧index
@property (nonatomic,strong) TNCVedioPalyerView           *vedioPalyerView;     // 被点击的视图

@end

@implementation TNCVedioManager



- (instancetype)init
{
    self = [super init];
    if (self) {
        _vedioPalyerView = [[TNCVedioPalyerView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _vedioPalyerView.v_delegate = self;

    }
    return self;
}



+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static TNCVedioManager* sharedInstance = nil;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];

    });
    return sharedInstance;
}

-(void) dealloc
{
    NSLog(@"dealloc TNCVedioManager");
}

- (void)sharedInstanceEnterFull
{
    _vedioPalyerView.vedioUrl = self.vedioUrl;
    _vedioPalyerView.alpha = 0.0;
    [[UIApplication sharedApplication].delegate.window addSubview:_vedioPalyerView];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [UIView animateWithDuration:0.3 animations:^{
        _vedioPalyerView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [_vedioPalyerView play];
    }];

}

-(void)cannelVedioPalyer
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [UIView animateWithDuration:0.3 animations:^{
        _vedioPalyerView.alpha = 0.0;

    } completion:^(BOOL finished) {
        if (_vedioPalyerView) {
            [_vedioPalyerView removeFromSuperview];
        }
        [_vedioPalyerView removeFromSuperview];
    }];
}
@end
