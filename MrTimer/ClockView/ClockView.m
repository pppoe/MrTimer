//
//  ClockView.m
//  MrTimer
//
//  Created by li haoxiang on 10/24/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import "ClockView.h"

@implementation ClockView

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
    mTimeInSeconds = 120;
    mTotalSegs = 100;
    mCircleSegs = -1;
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect
{
    float clockBorderWidth = 6;
    BOOL increGrowth = YES;
    UIColor *strokeColor = [UIColor grayColor];
    UIFont *strokeFont =[UIFont fontWithName:@"Courier-Bold" size:20.0f];

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    float radius = MIN(CGRectGetWidth(rect),CGRectGetHeight(rect))/2.0f - clockBorderWidth/2.0f;
    float angleOffset = M_PI_2;
    
    CGContextSetLineWidth(context, clockBorderWidth);
    CGContextBeginPath(context);
    if (increGrowth)
    {
        CGContextAddArc(context,
                        CGRectGetMidX(rect), CGRectGetMidY(rect),
                        radius,
                        -angleOffset,
                        (mCircleSegs + 1)/(float)mTotalSegs*M_PI*2 - angleOffset,
                        0);
    }
    else
    {
        CGContextAddArc(context,
                        CGRectGetMidX(rect), CGRectGetMidY(rect),
                        radius,
                        (mCircleSegs + 1)/(float)mTotalSegs*M_PI*2 - angleOffset,
                        2*M_PI - angleOffset,
                        0);
    }
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    CGContextStrokePath(context);
    
    CGContextSetLineWidth(context, 1.0f);
    NSString *numberText = [NSString stringWithFormat:@"%02d:%02d",
                            (int)(floor(mTimeInSeconds/60.0)), (mTimeInSeconds%60)];
    CGSize sz = [numberText sizeWithFont:strokeFont];
    CGContextSetFillColorWithColor(context, strokeColor.CGColor);
    [numberText drawInRect:CGRectInset(rect, (CGRectGetWidth(rect) - sz.width)/2.0f,
                                       (CGRectGetHeight(rect) - sz.height)/2.0f)
                  withFont:strokeFont];
}

@end
