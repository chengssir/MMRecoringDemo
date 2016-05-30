//
//  TNCVedioPalyerView.h
//  SBVideoCaptureDemo
//
//  Created by 程国帅 on 15/9/23.
//  Copyright (c) 2015年 Pandara. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TNCVedioPalyerDelegate <NSObject>

- (void)cannelVedioPalyer;


@end


@interface TNCVedioPalyerView : UIView

@property (nonatomic, strong) NSURL *vedioUrl;

@property (nonatomic, strong) id <TNCVedioPalyerDelegate> v_delegate;

+ (instancetype)vedioPalyerView:(CGRect)frame vedioUrl:(NSURL *)vedioUrl;

-(void)play;

@end
