//
//  BaseButton.m
//  UIButton滑出边界
//
//  Created by chengs on 15/12/3.
//  Copyright © 2015年 chengs. All rights reserved.
//

#import "MMBaseButton.h"
#import "MMCaptitudeToolKit.h"

@implementation MMBaseButton

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(IOS_Ver(8)) {

        CGFloat boundsExtension = 25.0f;
        CGRect outerBounds = CGRectInset(self.bounds, -1 * boundsExtension, -1 * boundsExtension);

        BOOL touchOutside = !CGRectContainsPoint(outerBounds, [touch locationInView:self]);
        if(touchOutside) {
            BOOL previousTouchInside = CGRectContainsPoint(outerBounds, [touch previousLocationInView:self]);
            if(previousTouchInside) {
                [self sendActionsForControlEvents:UIControlEventTouchDragExit];
            }
            else
            {
                [self sendActionsForControlEvents:UIControlEventTouchDragOutside];
            }
        }

    }

        return [super continueTrackingWithTouch:touch withEvent:event];
}

@end
