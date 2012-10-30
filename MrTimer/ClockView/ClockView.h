//
//  ClockView.h
//  MrTimer
//
//  Created by li haoxiang on 10/24/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ClockView;
@class MPLayerSupport;

@protocol ClockViewDelegate <NSObject>

- (void)scheduledTimeFinished:(ClockView *)clockView;

@end

@interface ClockView : UIView {
@public
@private
    MPLayerSupport *mLayerSupport;
    CALayer *mMinHand;
    CALayer *mSecHand;
    CALayer *mDial;
    CALayer *mShadow;
    
    int mCurTime;
    CGRect mClockRect;
    
    int mTicks;
    int mSpeed;
}

@property (nonatomic) id<ClockViewDelegate> delegate;

- (void)pause;
- (void)resetWithAnimation:(BOOL)animated;

- (void)tickToTime:(int)timeInSeconds;

+ (UIImage *)imageOfTime:(int)timeInSeconds withSize:(CGSize)size;
+ (UIImage *)imageRangeOfTime:(int)timeInSeconds withSize:(CGSize)size;

+ (void)rangeClockTimeInRect:(CGRect)rect
              inContext:(CGContextRef)context
                seconds:(int)seconds;
+ (void)clockTimeInRect:(CGRect)rect
              inContext:(CGContextRef)context
                minutes:(int)minutes
                seconds:(int)seconds;
+ (void)clockDetailsInRect:(CGRect)rect inContext:(CGContextRef)context numOfMarks:(int)num_of_marks;

@end
