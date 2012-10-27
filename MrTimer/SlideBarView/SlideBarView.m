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
#import "MPGlowLabel.h"
#import "MPImageUtil.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

#define kUnderLayerWidth 50
#define kSlideBarWidth 10
#define kMovingAnimationKey @"kMovingAnimationKey" 

@interface SlideBarView ()

- (void)setup;

@end

@implementation SlideBarView
@synthesize displayText;
@synthesize leftPadding, rightPadding;
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

- (void)setup {
    self.showRightHandler = YES;
    self.leftPadding = 0;
    self.rightPadding = 0;
    self.backgroundColor = [MPColorUtil colorFromHex:0xFF403E3F];
    self.displayText =  @"slide to stop";
    
    if (!mGrowLabel)
    {
        mGrowLabel = [[MPGlowLabel alloc] initWithFrame:self.bounds];
        [self addSubview:mGrowLabel];
    }
    
    if (!mSlider)
    {
        mSlider = [[UISlider alloc] initWithFrame:self.bounds];
        
        mSlider.backgroundColor = [UIColor clearColor];
        mSlider.minimumValue = 0.0;
        mSlider.maximumValue = 1.0;
        mSlider.continuous = YES;
        mSlider.value = 0.0;
        
        UIImage *emptyImage = [UIImage imageNamed:@"empty"];
        [mSlider setMaximumTrackImage:emptyImage forState:UIControlStateNormal];
        [mSlider setMinimumTrackImage:emptyImage forState:UIControlStateNormal];
        
        UIImage *thumbImage = [UIImage imageNamed:@"clock"];
        [mSlider setThumbImage:thumbImage forState:UIControlStateNormal];

        // Set the slider action methods
        [mSlider addTarget:self
                   action:@selector(actSliderUp:)
         forControlEvents:UIControlEventTouchUpInside];
        [mSlider addTarget:self
                   action:@selector(actSliderDown:)
         forControlEvents:UIControlEventTouchDown];
        [mSlider addTarget:self
                   action:@selector(actSliderChanged:)
         forControlEvents:UIControlEventValueChanged];
        [mSlider addTarget:self
                    action:@selector(actSliderCanceled:)
          forControlEvents:UIControlEventTouchCancel];
        
        
        [self addSubview:mSlider];
    }
    
    mGrowLabel.frame = self.bounds;
    mGrowLabel.text = self.displayText;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)drawRect:(CGRect)rect {

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *backgroundColor = [MPColorUtil colorFromHex:0xFF403E3F];
    [backgroundColor setFill];
    CGContextFillRect(context, rect);
    
    CGFloat x_padding_l = MAX(self.leftPadding, 0);
    CGFloat x_padding_r = MAX(self.rightPadding, 0);
    CGFloat inner_x_padding = 10;
    CGFloat inner_y_padding = 10;
    CGFloat cornerRadius = 5;
    
    UIColor *topBorderColor1 = [MPColorUtil colorFromHex:0xFF000000];
    UIColor *topBorderColor2 = [MPColorUtil colorFromHex:0xFF969696];
    UIColor *btmBorderColor1 = [MPColorUtil colorFromHex:0xFF000000];
    
    UIColor *grooveColorBorder1 = [MPColorUtil colorFromHex:0xFF000000];
    UIColor *grooveColorBorder2 = [MPColorUtil colorFromHex:0xFF969696];
    
    CGRect box = rect;
    
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
    
    CGRect grooveRect =
    CGRectMake(CGRectGetMinX(rect) + inner_x_padding + x_padding_l, CGRectGetMinY(rect) + inner_y_padding,
               CGRectGetWidth(rect) - 2*inner_x_padding - x_padding_l - x_padding_r, CGRectGetHeight(rect) - 2*inner_y_padding);
    
    if (self.showRightHandler)
    {
        CGFloat handleWidth = 25;
        CGFloat handleBorder = 0.8;
        UIColor *handleColor1 = [MPColorUtil colorFromHex:0xFF969696];
        UIColor *handleColor2 = [MPColorUtil colorFromHex:0xFF000000];
        
        int lineCounts = 3;
        CGFloat gapY = 8;
        CGFloat startY = CGRectGetMidY(rect) - gapY;
        
        CGContextSetLineCap(context, kCGLineCapRound);
        for (int i = 0; i < lineCounts; i++)
        {
            lineSegs[0].x = (CGRectGetMaxX(grooveRect) + CGRectGetMaxX(rect))/2 - handleWidth/2;
            lineSegs[0].y = startY + i*gapY;
            
            lineSegs[1].x = (CGRectGetMaxX(grooveRect) + CGRectGetMaxX(rect))/2 + handleWidth/2;
            lineSegs[1].y = startY + i*gapY;
            CGContextSetLineWidth(context, handleBorder);
            [handleColor1 setStroke];
            CGContextStrokeLineSegments(context, lineSegs, 2);
            
            lineSegs[0].y += handleBorder;
            lineSegs[1].y += handleBorder;
            [handleColor2 setStroke];
            CGContextStrokeLineSegments(context, lineSegs, 2);
        }
        
        mHandleRect = CGRectMake(lineSegs[0].x, startY, handleWidth, lineSegs[1].y - startY);
    }
    
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
        mGrowLabel.frame = CGRectInset(grooveRect_inner, 10, 10);
    }
    
    mGrooveRect = grooveRect;
    
    mSlider.frame = CGRectInset(grooveRect_inner, -1, 0);
    UIImage *orgThumbImage = [mSlider thumbImageForState:UIControlStateNormal];
    UIImage *thumbImage = [MPImageUtil resizeForImage:orgThumbImage
                                               toSize:CGSizeMake(CGRectGetHeight(grooveRect_inner),
                                                                 CGRectGetHeight(grooveRect_inner))];
    [mSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    
    [mGrowLabel setNeedsDisplay];
}

- (IBAction)actSliderUp:(id)sender {
    if (mSlideMoving && fabs([(UISlider *)sender value] - 1.0f) < 1e-3)
    {
        [self.delegate slidingFinished:self];
    }
    else
    {
        [mSlider setValue:0 animated:YES];
    }
    mSlideMoving = NO;
    mGrowLabel.alpha = 1;
}

- (IBAction)actSliderDown:(id)sender {
    mSlideMoving = YES;
}

- (IBAction)actSliderChanged:(id)sender {
    if (mSlideMoving)
    {
        mGrowLabel.alpha = MAX((1-[(UISlider *)sender value]*3), 0);
    }
}

- (IBAction)actSliderCanceled:(id)sender {
    mSlideMoving = NO;
    [mSlider setValue:0 animated:YES];
    mGrowLabel.alpha = 1;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = (UITouch *)[touches anyObject];
    CGPoint pt = [touch locationInView:self];
    CGRect actHandleRect = CGRectInset(mHandleRect, -20, -20);
    if (CGRectContainsPoint(actHandleRect, pt))
    {
        mTouchDeteced = YES;
        [self.delegate handleTouched:self touch:touch];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = (UITouch *)[touches anyObject];
    if (mTouchDeteced)
    {
        [self.delegate handleMoved:self touch:touch];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = (UITouch *)[touches anyObject];
    if (mTouchDeteced)
    {
        [self.delegate handleEnded:self touch:touch];
    }
    mTouchDeteced = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (mTouchDeteced)
    {
        [self.delegate handleCanceled:self];
    }
    mTouchDeteced = NO;
}

@end
