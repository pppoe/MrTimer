//
//  ClockView.m
//  MrTimer
//
//  Created by li haoxiang on 10/24/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import "ClockView.h"
#import "MPCoreGraphicsUtil.h"
#import "MPColorUtil.h"
#import "MPLayerSupport.h"
#import <QuartzCore/QuartzCore.h>

#define kSecondsPerMin 60
#define kMinutesPerHour 60
#define kFullNumberOfMarks 24

#define kAnimationKeySecondHand @"kAnimationKeySecondHand"
#define kAnimationKeyMinuteHand @"kAnimationKeyMinuteHand"
#define kAnimationKeyTime       @"kAnimationKeyTime"

@interface ClockView ()

//< Schedule Timer and Animation
- (void)setToTime:(int)timeInSeconds animated:(BOOL)animated speed:(float)speed;

@end

@implementation ClockView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)setup {
    mCurTime = 0;
    self.backgroundColor = [UIColor clearColor];
    
    if (!mLayerSupport)
    {
        mLayerSupport = [[MPLayerSupport alloc] init];
        mLayerSupport.layerDelegate = self;
        
        mSecHand = [CALayer layer];
        mSecHand.delegate = mLayerSupport;
        mSecHand.frame = self.bounds;
        [self.layer addSublayer:mSecHand];
        
        mMinHand = [CALayer layer];
        mMinHand.delegate = mLayerSupport;
        mMinHand.frame = self.bounds;
        [self.layer addSublayer:mMinHand];
    }
    
}

+ (void)clockTimeInRect:(CGRect)rect
              inContext:(CGContextRef)context
                minutes:(int)minutes
                seconds:(int)seconds {
    
    CGFloat secHeight = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect))/1.414*0.6;
    CGFloat minHeight = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect))/1.414*0.4;

    CGPoint ctrPt = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    UIColor *markColor = [MPColorUtil colorFromHex:0xFF0367E7];
    [markColor setFill];
    {
        //< Mins
        CGContextBeginPath(context);
        [MPCoreGraphicsUtil addRectangleInContext:context
                                     bottomCenter:ctrPt
                                  withBottomWidth:8
                                       withHeight:minHeight
                                 withExtendHeight:2
                                        direction:(minutes/(float)kMinutesPerHour*M_PI*2 - M_PI_2)
                                   rotationCenter:ctrPt];
        CGContextFillPath(context);
    }
    {
        //< Seconds
        CGContextBeginPath(context);
        [MPCoreGraphicsUtil addRectangleInContext:context
                                     bottomCenter:ctrPt
                                  withBottomWidth:5
                                       withHeight:secHeight
                                 withExtendHeight:2
                                        direction:(seconds/(float)kSecondsPerMin*M_PI*2 - M_PI_2)
                                   rotationCenter:ctrPt];
        CGContextFillPath(context);
    }
}

+ (void)clockDetailsInRect:(CGRect)rect inContext:(CGContextRef)context numOfMarks:(int)num_of_marks {
    CGFloat markHeight = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect))/1.414*0.08;
    CGPoint ctrPt = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    UIColor *markColor = [MPColorUtil colorFromHex:0xFF0367E7];
    [markColor setFill];
    for (int i = 0; i < num_of_marks; i++)
    {
        CGContextBeginPath(context);
        [MPCoreGraphicsUtil addRectangleInContext:context
                                     bottomCenter:CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect))
                                  withBottomWidth:2
                                       withHeight:(i%2 == 0 ? 2*markHeight : markHeight)
                                 withExtendHeight:0
                                        direction:i/(float)num_of_marks*M_PI*2 - M_PI_2
                                   rotationCenter:ctrPt];
        CGContextFillPath(context);
    }
}

+ (void)rangeClockTimeInRect:(CGRect)rect
                   inContext:(CGContextRef)context
                     seconds:(int)seconds {
    
    float radius = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect))/2;
    CGFloat secHeight = radius*0.9;
    CGFloat minHeight = radius*0.5;
    
    float second_rotation = (seconds/(float)kSecondsPerMin*M_PI*2) - M_PI_2;
    
    CGPoint ctrPt = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    {
        UIColor *markColor = [MPColorUtil colorFromHex:0xFF0367E7];
        [markColor setFill];
        //< Seconds
        CGContextBeginPath(context);
        [MPCoreGraphicsUtil addRectangleInContext:context
                                     bottomCenter:ctrPt
                                  withBottomWidth:2
                                       withHeight:secHeight
                                 withExtendHeight:0
                                        direction:second_rotation
                                   rotationCenter:ctrPt];
        CGContextFillPath(context);
    }
}

- (void)drawRect:(CGRect)rect
{
    int x_padding = 10;
    int y_padding = 10;
    CGFloat borderWidth = 5;
    
    UIColor *inner_borderColor = [UIColor blackColor];
    
    CGPoint ctr = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGFloat sideSize = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect));
    CGRect box = CGRectInset(CGRectMake(ctr.x - sideSize/2,
                                        ctr.y - sideSize/2,
                                        sideSize, sideSize),
                             x_padding, y_padding);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect clockRect = CGRectInset(box, borderWidth, borderWidth);
    CGContextBeginPath(context);
    CGContextAddEllipseInRect(context, clockRect);
    CGContextClosePath(context);
    CGContextSetLineWidth(context, 1);
    [inner_borderColor setFill];
    CGContextFillPath(context);
    
    mClockRect = CGRectInset(clockRect, 5, 5);
    [ClockView clockDetailsInRect:mClockRect inContext:context numOfMarks:kFullNumberOfMarks];
    
    [mMinHand setNeedsDisplay];
    [mSecHand setNeedsDisplay];
    
    mSecHand.frame = mClockRect;
    mMinHand.frame = mClockRect;
}

- (void)supportDrawLayer:(CALayer *)layer inContext:(CGContextRef)context {
    UIGraphicsPushContext(context);
    
    CGRect rect = layer.bounds;
    CGFloat secHeight = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect))/1.414*0.6;
    CGFloat minHeight = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect))/1.414*0.4;
    
    CGPoint ctrPt = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    UIColor *markColor = [MPColorUtil colorFromHex:0xFF0367E7];
    [markColor setFill];
    if (layer == mMinHand)
    {
        //< Mins
        CGContextBeginPath(context);
        [MPCoreGraphicsUtil addRectangleInContext:context
                                     bottomCenter:ctrPt
                                  withBottomWidth:8
                                       withHeight:minHeight
                                 withExtendHeight:2
                                        direction:-M_PI_2
                                   rotationCenter:ctrPt];
        CGContextFillPath(context);
    }
    else if (layer == mSecHand)
    {
        //< Seconds
        CGContextBeginPath(context);
        [MPCoreGraphicsUtil addRectangleInContext:context
                                     bottomCenter:ctrPt
                                  withBottomWidth:5
                                       withHeight:secHeight
                                 withExtendHeight:2
                                        direction:-M_PI_2
                                   rotationCenter:ctrPt];
        CGContextFillPath(context);
    }
    
    UIGraphicsPopContext();    
}

- (void)pause {
}

- (void)resetWithAnimation:(BOOL)animated {
    [self setToTime:0 animated:animated speed:100];
}

- (void)setToTime:(int)timeInSeconds animated:(BOOL)animated speed:(float)speed {

    int cur_time = mCurTime;
    
    int cur_minutes = floor(cur_time/(float)kSecondsPerMin);
    float cur_second_rotation = cur_time/(float)kSecondsPerMin*M_PI*2;
    float cur_minute_rotation = cur_minutes/(float)kMinutesPerHour*M_PI*2;

    int minutes = floor(timeInSeconds/(float)kSecondsPerMin);
    float second_rotation = timeInSeconds/(float)kSecondsPerMin*M_PI*2;
    float minute_rotation = minutes/(float)kMinutesPerHour*M_PI*2;

    [mSecHand removeAllAnimations];
    [mMinHand removeAllAnimations];

    if (animated)
    {
//        CABasicAnimation *animationSec = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
//        animationSec.fillMode = kCAFillModeForwards;
//        animationSec.fromValue = [NSNumber numberWithFloat:MIN(cur_second_rotation,second_rotation)];
//        animationSec.toValue = [NSNumber numberWithFloat:MAX(cur_second_rotation,second_rotation)];
//        animationSec.speed = speed;
//        animationSec.duration = fabs(cur_time - timeInSeconds)/speed;
//        animationSec.removedOnCompletion = NO;
//        animationSec.beginTime = 0;
//        [mSecHand addAnimation:animationSec forKey:kAnimationKeySecondHand];
        
        CABasicAnimation *animationMin = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animationMin.fillMode = kCAFillModeForwards;
        animationMin.fromValue = [NSNumber numberWithFloat:MIN(cur_minute_rotation,minute_rotation)];
        animationMin.toValue = [NSNumber numberWithFloat:MAX(cur_minute_rotation,minute_rotation)];
        animationMin.speed = speed/kSecondsPerMin;
        animationMin.duration = fabs(cur_time - timeInSeconds)/speed;
        animationMin.removedOnCompletion = NO;
        animationMin.beginTime = 0;
        [mMinHand addAnimation:animationMin forKey:kAnimationKeyMinuteHand];

//        CAAnimationGroup *anim = [CAAnimationGroup animation];
//        anim.duration = fabs(cur_time - timeInSeconds)/speed;
//        anim.animations = [NSArray arrayWithObjects:animationMin, animationSec, nil];
    }
    else
    {
        mMinHand.transform = CATransform3DMakeRotation(minute_rotation, 0, 0, 1);
        mSecHand.transform = CATransform3DMakeRotation(second_rotation, 0, 0, 1);
    }
}

- (void)tickToTime:(int)timeInSeconds {
    [self setToTime:timeInSeconds animated:YES speed:10];
    mCurTime = timeInSeconds;
}

+ (UIImage *)imageOfTime:(int)timeInSeconds withSize:(CGSize)size {
    
    UIImage *image = nil;
    
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [ClockView clockDetailsInRect:rect inContext:context numOfMarks:kFullNumberOfMarks];
    [ClockView clockTimeInRect:rect inContext:context
                  minutes:floor(timeInSeconds/(float)kSecondsPerMin)
                  seconds:timeInSeconds%kSecondsPerMin];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageRangeOfTime:(int)timeInSeconds withSize:(CGSize)size {
    
    UIImage *image = nil;
    
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [ClockView rangeClockTimeInRect:rect
                     inContext:context
                  seconds:timeInSeconds%kSecondsPerMin];
    [ClockView clockDetailsInRect:rect inContext:context numOfMarks:12];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
