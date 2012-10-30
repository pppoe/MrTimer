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
- (void)setToTime:(int)timeInSeconds animated:(BOOL)animated speed:(int)speed;
- (void)moveHands;

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
    self.backgroundColor = [UIColor clearColor];
    
    if (!mLayerSupport)
    {
        mLayerSupport = [[MPLayerSupport alloc] init];
        mLayerSupport.layerDelegate = self;
        
        mDial = [CALayer layer];
        mDial.delegate = mLayerSupport;
        mDial.frame = self.bounds;
        mDial.backgroundColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:mDial];
        
        mMinHand = [CALayer layer];
        mMinHand.delegate = mLayerSupport;
        mMinHand.frame = self.bounds;
        [self.layer addSublayer:mMinHand];

        mSecHand = [CALayer layer];
        mSecHand.delegate = mLayerSupport;
        mSecHand.frame = self.bounds;
        [self.layer addSublayer:mSecHand];
        
    }
    
    mTicks = 0; //<
    mSpeed = 1; //< Ticks per second
    
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
    CGFloat markHeight = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect))/1.414*0.05;
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
//    CGFloat minHeight = radius*0.5;
    
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
    
    CGPoint ctr = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGFloat sideSize = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect));
    CGRect box = CGRectInset(CGRectMake(ctr.x - sideSize/2,
                                        ctr.y - sideSize/2,
                                        sideSize, sideSize),
                             x_padding, y_padding);
    
    mClockRect = CGRectInset(box, borderWidth, borderWidth);
    
    [mMinHand setNeedsDisplay];
    [mSecHand setNeedsDisplay];
    [mDial setNeedsDisplay];
    
    mDial.frame = self.bounds;
    mSecHand.frame = mClockRect;
    mMinHand.frame = mClockRect;
}

- (void)supportDrawLayer:(CALayer *)layer inContext:(CGContextRef)context {
    UIGraphicsPushContext(context);
    
    CGRect rect = layer.bounds;
    CGFloat secHeight = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect))/1.414*0.6;
    CGFloat minHeight = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect))/1.414*0.4;
    
    CGPoint ctrPt = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    CGFloat nobRad = 5;
    [MPCoreGraphicsUtil renderCenterCircleGradient:context
                                              rect:CGRectMake(ctrPt.x - nobRad,
                                                              ctrPt.y - nobRad,
                                                              nobRad*2,
                                                              nobRad*2)
                                    outerColorCode:0x000367E7
                                    innerColorCode:0xFF0367E7
                                            radius:nobRad
                                           options:kCGGradientDrawsBeforeStartLocation];
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    if (layer == mMinHand)
    {
        UIColor *markColor = [MPColorUtil colorFromHex:0xFF0367E7];
        [markColor setFill];
        //< Mins
        CGContextBeginPath(context);
        [MPCoreGraphicsUtil addRectangleInContext:context
                                     bottomCenter:ctrPt
                                  withBottomWidth:6
                                       withHeight:minHeight
                                 withExtendHeight:2
                                        direction:-M_PI_2
                                   rotationCenter:ctrPt];
        CGContextFillPath(context);
    }
    else if (layer == mSecHand)
    {
        UIColor *markColor = [MPColorUtil colorFromHex:0xFF0367FF];
        [markColor setFill];
        //< Seconds
        CGContextBeginPath(context);
        [MPCoreGraphicsUtil addRectangleInContext:context
                                     bottomCenter:ctrPt
                                  withBottomWidth:3
                                       withHeight:secHeight
                                 withExtendHeight:2
                                        direction:-M_PI_2
                                   rotationCenter:ctrPt];
        CGContextFillPath(context);
    }
    else if (layer == mDial)
    {
        UIColor *inner_borderColor = [[MPColorUtil colorFromHex:0xFFF9AD81] colorWithAlphaComponent:0.0f];

        rect = mClockRect;
        
        CGContextSetBlendMode(context, kCGBlendModeCopy);
        
//        CGContextBeginPath(context);
//        CGGradientRef gradient = [MPCoreGraphicsUtil
//                                  createGradientFromColorTop:[MPColorUtil colorFromHex:0xFF000000]
//                                  colorBottom:[MPColorUtil colorFromHex:0xFF3E3E3E]];
//        CGPoint startP = CGPointMake(rect.origin.x + rect.size.width/4.0f,
//                                     rect.origin.y + rect.size.height/4.0f);
//        CGPoint endP = CGPointMake(rect.origin.x + rect.size.width*0.75f,
//                                   rect.origin.y + rect.size.height*0.75f);
//        [MPCoreGraphicsUtil addRoundedPathInContext:context
//                                           WithRect:CGRectInset(rect, -20, -20)
//                                        borderWidth:10.0
//                                          andRadius:10];
//        CGContextClip(context);
//        CGContextDrawLinearGradient(context, gradient, startP, endP, kCGGradientDrawsBeforeStartLocation|kCGGradientDrawsAfterEndLocation);
//        CGGradientRelease(gradient);
        
//        CGContextBeginPath(context);
//        CGContextAddEllipseInRect(context, rect);
//        CGContextClosePath(context);
//        CGContextSetLineWidth(context, 1);
//        [inner_borderColor setFill];
//        CGContextFillPath(context);

        CGContextAddEllipseInRect(context, rect);
        CGContextClip(context);
        [MPCoreGraphicsUtil renderCenterCircleGradient:context
                                                  rect:rect
                                        outerColorCode:0xFF000000
                                        innerColorCode:0xFF3E3E3E
                                                radius:MIN(CGRectGetWidth(rect), CGRectGetHeight(rect))*0.9
                                               options:kCGGradientDrawsBeforeStartLocation|kCGGradientDrawsAfterEndLocation];
        
//        CGContextBeginPath(context);
//        CGGradientRef gradient = [MPCoreGraphicsUtil
//                                  createGradientFromColorTop:[MPColorUtil colorFromHex:0xFF3E3E3E]
//                                  colorBottom:[MPColorUtil colorFromHex:0xFF000000]];
//        CGPoint startP = CGPointMake(rect.origin.x + rect.size.width/4.0f,
//                                     rect.origin.y + rect.size.height/4.0f);
//        CGPoint endP = CGPointMake(rect.origin.x + rect.size.width*0.95f,
//                                   rect.origin.y + rect.size.height*0.95f);
//        CGContextAddEllipseInRect(context, rect);
//        CGContextClip(context);
//        CGContextDrawLinearGradient(context, gradient, startP, endP, kCGGradientDrawsBeforeStartLocation|kCGGradientDrawsAfterEndLocation);
//        CGGradientRelease(gradient);

        [ClockView clockDetailsInRect:CGRectInset(rect, 10, 10) inContext:context numOfMarks:kFullNumberOfMarks];

        if (!mShadow)
        {
            CALayer *shadowLayer = [CALayer layer];
            
            ctrPt = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
            
            CGFloat sideSize = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect));
            
            UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:ctrPt
                                                                radius:sideSize/2
                                                            startAngle:0 endAngle:M_PI*2
                                                             clockwise:1];
            shadowLayer.shadowColor = [UIColor blackColor].CGColor;
            shadowLayer.shadowOpacity = 0.8f;
            shadowLayer.shadowRadius = 3;
            shadowLayer.shadowOffset = CGSizeMake(0, 0);
            shadowLayer.shadowPath = path.CGPath;
            shadowLayer.frame = mDial.bounds;
            [self.layer insertSublayer:shadowLayer below:mDial];
            
            mShadow = shadowLayer;
        }
        
        //< Show add some reflection here
    }
    
    UIGraphicsPopContext();    
}

- (void)pause {
}

- (void)resetWithAnimation:(BOOL)animated {
    [self setToTime:0 animated:animated speed:1];
}

- (void)moveHands {
    float curTimeInSeconds = (float)mTicks/kSecondsPerMin;
    float curTimeInMins = curTimeInSeconds/kMinutesPerHour;
    
    float min_rotation = curTimeInMins*M_PI*2;
    float sec_rotation = curTimeInSeconds*M_PI*2;
    mMinHand.transform = CATransform3DMakeRotation(min_rotation, 0, 0, 1);
    mSecHand.transform = CATransform3DMakeRotation(sec_rotation, 0, 0, 1);
}

- (void)updateCycle {

    [self moveHands];

    if (mTicks < mCurTime*mSpeed)
    {
        mTicks++;
        [NSTimer scheduledTimerWithTimeInterval:1.0/mSpeed
                                         target:self
                                       selector:@selector(updateCycle)
                                       userInfo:nil
                                        repeats:NO];
    }
    else
    {
        [self.delegate scheduledTimeFinished:self];
        mTicks = 0;
    }
}

- (void)setToTime:(int)timeInSeconds animated:(BOOL)animated speed:(int)speed {
    mCurTime = timeInSeconds;
    mTicks = 0;
    mSpeed = speed;
    [self updateCycle];
}

- (void)tickToTime:(int)timeInSeconds {
    
    [self setToTime:0 animated:YES speed:1];
    int64_t delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self setToTime:timeInSeconds animated:YES speed:1];
    });
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
