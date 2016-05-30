//
//  MMCaptitudeToolKit.m
//  RecoringDemo
//
//  Created by 程国帅 on 16/1/7.
//  Copyright © 2016年 chengs. All rights reserved.
//

#import "MMCaptitudeToolKit.h"
#import "MMCaptureDefine.h"
#import <CommonCrypto/CommonDigest.h>

@implementation MMCaptitudeToolKit



+ (void)setView:(UIView *)view toSizeWidth:(CGFloat)width
{
    CGRect frame = view.frame;
    frame.size.width = width;
    view.frame = frame;
}

+ (void)setView:(UIView *)view toOriginX:(CGFloat)x
{
    CGRect frame = view.frame;
    frame.origin.x = x;
    view.frame = frame;
}

+ (void)setView:(UIView *)view toOriginY:(CGFloat)y
{
    CGRect frame = view.frame;
    frame.origin.y = y;
    view.frame = frame;
}

+ (void)setView:(UIView *)view toOrigin:(CGPoint)origin
{
    CGRect frame = view.frame;
    frame.origin = origin;
    view.frame = frame;
}

+ (NSString *)createLocalPath{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];

    path = [path stringByAppendingPathComponent:VIDEO_FOLDER];

    return path;
}


+ (BOOL)createVideoFolderIfNotExist
{

    NSString *folderPath = [self createLocalPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    BOOL isDirExist = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    
    if(!(isDirExist && isDir))
    {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"创建视频文件夹失败");
            return NO;
        }
        return YES;
    }
    return YES;
}


//录制视频暂存部分
+ (NSString *)getVideoSaveFilePathString
{

    NSString *path = [self createLocalPath];

    NSString *nowTimeStr = [self getDateTimeString];
    
    NSString *fileName = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@".mp4"];
    
    return fileName;
}

+ (NSString *)getDateTimeString
{
    NSDateFormatter *formatter;
    NSString        *dateString;

    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss"];

    dateString = [formatter stringFromDate:[NSDate date]];

    return dateString;
}

//删除暂存的视频
+ (void)removeItemAtChatPath
{

    NSString *extension = @"mp4";
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *documentsDirectory = [self createLocalPath];

    NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {

        if ([[filename pathExtension] isEqualToString:extension]) {

            [fileManager removeItemAtPath:[documentsDirectory
                                           stringByAppendingPathComponent:filename] error:NULL];
        }
    }
    
    
}



+ (NSString*) getUUIDString

{

    CFUUIDRef uuidObj = CFUUIDCreate(nil);

    NSString *uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuidObj);

    CFRelease(uuidObj);

    return uuidString;

}

+ (NSString*)getgetLocalPathByURLByFileName:(NSString *)fileName ofType:(NSString *)type
{
    NSString* fileDirectory = [[self getLocalPathByURL:fileName] stringByAppendingPathExtension:type];
    return fileDirectory;
}

+ (NSString *)getLocalPathByURL:(NSString *)url
{
    if (url.length == 0) {
        return nil;
    }

    NSString* md5 = [self getMD5String:url];
    NSString* path = [self documentsChatPath];
    NSString* localPath = [NSString stringWithFormat:@"%@%@", path, md5];
    return localPath;
}

+ (NSString *)getMD5String:(NSString *)string
{
    if (string.length<=0) {
        return nil;
    }

    const char *value = string.UTF8String;
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (unsigned int)strlen(value), outputBuffer);

    NSMutableString *encodedString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [encodedString appendFormat:@"%02X", outputBuffer[count]];
    }
    return encodedString;
}

+ (NSString *)documentsChatPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);

    NSString *path = [[paths objectAtIndex:0] stringByAppendingFormat:@"/Caches/ChatCache/"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}
@end
