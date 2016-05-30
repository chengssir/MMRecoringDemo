//
//  ProcessBar.m
//
//
//  Created by 程国帅 on 16-1-6.
//  Copyright (c) 2016年 思源. All rights reserved.
//


#import "MMProgressBar.h"
#import "MMCaptitudeToolKit.h"

#define BAR_H 2

@interface MMProgressBar ()

@property (strong, nonatomic) UIView *rightProgressView;
@property (strong, nonatomic) UIView *leftProgressView;

@end

@implementation MMProgressBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initalize];
    }
    return self;
}

- (void)initalize
{
    self.autoresizingMask = UIViewAutoresizingNone;

    _barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, BAR_H)];
    _barView.backgroundColor = BAKCOLOR;
    [self addSubview:_barView];
}

#pragma mark - method

- (void)addProgressView
{
    [_barView addSubview:self.rightProgressView];
    [_barView addSubview:self.leftProgressView];
    _barView.backgroundColor = [UIColor greenColor];

}

- (void)setLastProgressToWidth:(CGFloat)width
{
    CGRect frame = self.rightProgressView.frame;
    frame.size.width = width/2;
    frame.origin.x = SCREEN_WIDTH - width/2;
    self.rightProgressView.frame = frame;
    
    CGRect frame2 = self.leftProgressView.frame;
    frame2.size.width = width/2;
    self.leftProgressView.frame = frame2;
}

-(void)setProgressViewFrame
{
    self.rightProgressView.frame = CGRectMake(SCREEN_WIDTH/2, 0, SCREEN_WIDTH/2, BAR_H);
    self.leftProgressView.frame = CGRectMake(0, 0, SCREEN_WIDTH/2, BAR_H);

}

+ (MMProgressBar *)getInstance
{
    static MMProgressBar *progressBar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        progressBar = [[MMProgressBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, BAR_H)];
    });
    return progressBar;
 
}

-(UIView *)rightProgressView
{
    if (!_rightProgressView) {
        _rightProgressView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, 1, BAR_H)];
        _rightProgressView.backgroundColor = BAKCOLOR;
        _rightProgressView.autoresizesSubviews = YES;
    }
    return _rightProgressView;
}

-(UIView *)leftProgressView
{
    if (!_leftProgressView) {
        _leftProgressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, BAR_H)];
        _leftProgressView.backgroundColor = BAKCOLOR;
        _leftProgressView.autoresizesSubviews = YES;
    }
    return _leftProgressView;
}

@end

