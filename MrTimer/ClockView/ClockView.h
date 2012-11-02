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
    
    UILocalNotification *mNotification;
    BOOL mIsRunning;
    NSTimer *mCurTimer;
    NSString *mTemporaryFilePath;
    UInt32 mSoundID;
    UInt32 mFinishSoundID;
}

@property (nonatomic) id<ClockViewDelegate> delegate;

- (BOOL)running;
- (void)resetWithAnimation:(BOOL)animated;

- (void)tickToTime:(int)timeInSeconds;

+ (UIImage *)imageOfTime:(int)timeInSeconds withSize:(CGSize)size withColor:(int)colorCode;
+ (UIImage *)imageRangeOfTime:(int)timeInSeconds withSize:(CGSize)size withColor:(int)colorCode;

+ (void)rangeClockTimeInRect:(CGRect)rect
                   inContext:(CGContextRef)context
                     seconds:(int)seconds
               withColorCode:(int)colorCode;

+ (void)clockTimeInRect:(CGRect)rect
              inContext:(CGContextRef)context
                minutes:(int)minutes
                seconds:(int)seconds
          withColorCode:(int)colorCode;

+ (void)clockDetailsInRect:(CGRect)rect inContext:(CGContextRef)context
                numOfMarks:(int)num_of_marks
             withColorCode:(int)colorCode;

- (void)flashRed;
- (void)flashGreen;
- (void)flashColor:(UIColor *)color
          maxAlpha:(float)maxAlpha
          minAlpha:(float)minAlpha
      increaseTime:(float)increaseTime
      decreaseTime:(float)decreaseTime;

@end
