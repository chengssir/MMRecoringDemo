//
//  MMCaptitudeToolKit.h
//  RecoringDemo
//
//  Created by 程国帅 on 16/1/7.
//  Copyright © 2016年 chengs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define SCREEN_HEIGHT               [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH                ([UIScreen mainScreen].bounds.size.width)
#define IOS_Ver(version) ([[UIDevice currentDevice].systemVersion doubleValue] >= version)

@interface MMCaptitudeToolKit : NSObject

+ (void)setView:(UIView *)view toSizeWidth:(CGFloat)width;
+ (void)setView:(UIView *)view toOriginX:(CGFloat)x;
+ (void)setView:(UIView *)view toOriginY:(CGFloat)y;
+ (void)setView:(UIView *)view toOrigin:(CGPoint)origin;

+ (BOOL)createVideoFolderIfNotExist;
+ (void)removeItemAtChatPath;
+ (NSString *)getVideoSaveFilePathString;

+ (NSString *)getDateTimeString;
+ (NSString*) getUUIDString;
+ (NSString*)getgetLocalPathByURLByFileName:(NSString *)fileName ofType:(NSString *)type;
@end