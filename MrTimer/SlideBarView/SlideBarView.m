//
//  SlideBarView.m
//  MrTimer
//
//  Created by li haoxiang on 10/24/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import "SlideBarView.h"
#import "MPColorUtil.h"
#import "MPLayerSupport.h"
#import <QuartzCore/QuartzCore.h>

@interface SlideBarView ()

- (void)drawTopLayerInContext:(CGContextRef)context;
- (void)drawUnderLayerInContext:(CGContextRef)context;

@end

@implementation SlideBarView
@synthesize displayText;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    self.displayText =  @"slide to stop";
    
    if (!mLayerSupport)
    {
        mLayerSupport = [[MPLayerSupport alloc] init];
        mLayerSupport.layerDelegate = self;
    }

    if (!mUnderLayer)
    {
        mUnderLayer = [CALayer layer];
        mUnderLayer.frame = self.bounds;
        mUnderLayer.delegate = mLayerSupport;
        [self.layer addSublayer:mUnderLayer];
    } //< Should add Under Layer First

    if (!mTopLayer)
    {
        mTopLayer = [CALayer layer];
        mTopLayer.frame = self.bounds;
        mTopLayer.delegate = mLayerSupport;
        [self.layer addSublayer:mTopLayer];
    }
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)drawRect:(CGRect)rect {
    [mTopLayer setNeedsDisplay];
    [mUnderLayer setNeedsDisplay];
}

- (void)supportDrawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    if (layer == mTopLayer)
    {
        [self drawTopLayerInContext:ctx];
    }
    else if (layer == mUnderLayer)
    {
        [self drawUnderLayerInContext:ctx];
    }
}

- (void)drawUnderLayerInContext:(CGContextRef)context {
    
    UIGraphicsPushContext(context);

    CGRect rect = [mUnderLayer bounds];

    [MPColorUtil renderCenterCircleGradient:context
                                       rect:CGRectInset(rect, 20, 20)
                             outerColorCode:0xFF000000
                             innerColorCode:0xFFFFFFFF];
    
    UIGraphicsPopContext();
}

- (void)drawTopLayerInContext:(CGContextRef)context
{
    CGRect rect = [mTopLayer bounds];
    
    UIGraphicsPushContext(context);

    CGContextSetBlendMode(context, kCGBlendModeCopy);

    UIColor *backgroundColor = [MPColorUtil colorFromHex:0xFF403E3F];
    [backgroundColor setFill];
    CGContextFillRect(context, rect);
    
    int x_padding = 0;
    int y_padding = 0;
    int inner_x_padding = 10;
    int inner_y_padding = 10;
    float cornerRadius = 5;
    float textSize = 20.0;
    UIFont *textFont = [UIFont systemFontOfSize:textSize];
    UIColor *textColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.0f];
    UIColor *textShadowColor = [UIColor blackColor];

    UIColor *topBorderColor1 = [MPColorUtil colorFromHex:0xFF000000];
    UIColor *topBorderColor2 = [MPColorUtil colorFromHex:0xFF969696];
    UIColor *btmBorderColor1 = [MPColorUtil colorFromHex:0xFF000000];
    
    UIColor *grooveColorBorder1 = [MPColorUtil colorFromHex:0xFF000000];
    UIColor *grooveColorBorder2 = [MPColorUtil colorFromHex:0xFF969696];
    
    CGRect box = CGRectInset(rect, x_padding, y_padding);
    
    CGContextSetLineWidth(context, 1.0);
    CGPoint lineSegs[2];
    {
        //< TOP
        lineSegs[0].x = CGRectGetMinX(box); lineSegs[0].y = CGRectGetMinY(box) + 0.5;
        lineSegs[1].x = CGRectGetMaxX(box); lineSegs[1].y = CGRectGetMinY(box) + 0.5;
        [topBorderColor1 setStroke];
        CGContextStrokeLineSegments(context, lineSegs, 2);
        lineSegs[0].x = CGRectGetMinX(box); lineSegs[0].y = CGRectGetMinY(box) + 1.5;
        lineSegs[1].x = CGRectGetMaxX(box); lineSegs[1].y = CGRectGetMinY(box) + 1.5;
        [topBorderColor2 setStroke];
        CGContextStrokeLineSegments(context, lineSegs, 2);
    }
    {
        //< BOTTOM
        lineSegs[0].x = CGRectGetMinX(box); lineSegs[0].y = CGRectGetMaxY(box) - 0.5;
        lineSegs[1].x = CGRectGetMaxX(box); lineSegs[1].y = CGRectGetMaxY(box) - 0.5;
        [btmBorderColor1 setStroke];
        CGContextStrokeLineSegments(context, lineSegs, 2);
    }
    
    CGRect grooveRect = CGRectInset(box, inner_x_padding, inner_y_padding);
    CGRect grooveRect_inner = CGRectInset(grooveRect, 1, 1);
    {
        //< GROOVE
        {
            CGContextBeginPath(context);
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:grooveRect
                                                       byRoundingCorners:UIRectCornerAllCorners
                                                             cornerRadii:CGSizeMake(cornerRadius,
                                                                                    cornerRadius)];
            CGContextAddPath(context, [path CGPath]);
            [grooveColorBorder2 setStroke];
            CGContextStrokePath(context);
        }
        {
            CGContextBeginPath(context);
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:grooveRect_inner
                                                       byRoundingCorners:UIRectCornerAllCorners
                                                             cornerRadii:CGSizeMake(cornerRadius,
                                                                                    cornerRadius)];
            CGContextAddPath(context, [path CGPath]);
            [grooveColorBorder1 setStroke];
            CGContextStrokePath(context);
        }
    }
    
    if (self.displayText)
    {
        [textColor setFill];
        CGSize sz = [self.displayText sizeWithFont:textFont
                                          forWidth:CGRectGetWidth(grooveRect_inner)
                                     lineBreakMode:NSLineBreakByTruncatingTail];
        CGContextSetShadowWithColor(context, CGSizeMake(0, -1), 0.8, textShadowColor.CGColor);
        [self.displayText drawInRect:CGRectInset(grooveRect_inner,
                                                 (grooveRect_inner.size.width - sz.width)/2,
                                                 (grooveRect_inner.size.height - sz.height)/2)
                            withFont:textFont
                       lineBreakMode:NSLineBreakByTruncatingTail
                           alignment:NSTextAlignmentCenter];
    }
    
    UIGraphicsPopContext();
}

@end
