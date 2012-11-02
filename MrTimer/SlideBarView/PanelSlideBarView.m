//
//  PanelSlideBarView.m
//  MrTimer
//
//  Created by li haoxiang on 10/26/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import "PanelSlideBarView.h"
#import "SlideBarView.h"
#import "MPColorUtil.h"

#define kSlideBarViewHeight 60

@interface PanelSlideBarView () <UIScrollViewDelegate, SlideBarViewDelegate>

- (void)setup;

@end

@implementation PanelSlideBarView
@synthesize panelContentView, delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat spaceGapHeight = CGRectGetHeight(self.bounds)-kSlideBarViewHeight;
    if (!panelView)
    {
        panelView = [[UIView alloc] initWithFrame:self.bounds];
        panelView.backgroundColor = [MPColorUtil colorFromHex:0xFF403E3F];
        [self addSubview:panelView];
    }
    
    if (!slideBarView)
    {
        slideBarView = [[SlideBarView alloc] initWithFrame:CGRectMake(0, 0,
                                                                      CGRectGetWidth(self.bounds),
                                                                      kSlideBarViewHeight)];
        slideBarView.rightPadding = 40;
        slideBarView.delegate = self;
        [panelView addSubview:slideBarView];
    }

    slideBarView.frame = CGRectMake(0, 0,
                                    CGRectGetWidth(slideBarView.frame),
                                    CGRectGetHeight(slideBarView.frame));
    panelView.frame = CGRectMake(0, spaceGapHeight,
                                 CGRectGetWidth(panelView.frame),
                                 CGRectGetHeight(panelView.frame));
    if (self.panelContentView.superview != panelView)
    {
        [self.panelContentView removeFromSuperview];
        self.panelContentView.frame = CGRectMake(0, CGRectGetMaxY(slideBarView.frame),
                                                 CGRectGetWidth(panelView.frame),
                                                 spaceGapHeight);
        [panelView addSubview:self.panelContentView];
    }
    
    mPanelCenterPt = panelView.center;
    mPanelCenterPtAlter = CGPointMake(panelView.center.x,
                                      panelView.center.y - spaceGapHeight);
    mHasShownUp = NO;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [slideBarView setNeedsDisplay];
}

- (void)slidingFinished:(SlideBarView*)slideBarView_ {
    mDisableHandle = NO;
    [self.delegate barSlided:self];
//    int64_t delayInSeconds = 1.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){        
//        [slideBarView_ resetSlider];
//    });
}

- (void)handleMoved:(SlideBarView *)slideBarView touch:(UITouch *)touch {    
    if (mDisableHandle)
    {
        return;
    }

    CGPoint pt = [touch locationInView:self];
    CGFloat newY = (*pTouchBeginCenterPt).y + (pt.y - mDefaultHandlePt.y);
    CGFloat maxY = MAX(mPanelCenterPt.y, mPanelCenterPtAlter.y);
    CGFloat minY = MIN(mPanelCenterPt.y, mPanelCenterPtAlter.y);
    panelView.center = CGPointMake(mPanelCenterPt.x, MAX(MIN(maxY, newY), minY));
}

- (void)handleEnded:(SlideBarView*)slideBarView touch:(UITouch *)touch {    
    if (mDisableHandle)
    {
        return;
    }

    CGPoint pt = [touch locationInView:self];
    
    if (fabs(pt.y - mDefaultHandlePt.y)
                      > 0.4*fabs(mPanelCenterPtAlter.y - mPanelCenterPt.y))
    {
        if (pt.y > mDefaultHandlePt.y)
        {
            if ([self.delegate panelShouldMovedDown:self])
            {
                [self slideDown];
                return;
            }
        }
        else
        {
            [self showUp];
            return;
        }
    }
    
    {
        [UIView beginAnimations:@"" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        panelView.center = *pTouchBeginCenterPt;
        [UIView commitAnimations];
    }
}

- (void)handleTouched:(SlideBarView*)slideBarView touch:(UITouch *)touch {
    if (mDisableHandle)
    {
        return;
    }
    mDefaultHandlePt = [touch locationInView:self];
    pTouchBeginCenterPt = (!mHasShownUp ? &mPanelCenterPt : &mPanelCenterPtAlter);
}

- (void)handleCanceled:(SlideBarView*)slideBarView {
    if (mDisableHandle)
    {
        return;
    }
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    panelView.center = *pTouchBeginCenterPt;
    [UIView commitAnimations];
}

- (void)showUp {
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    panelView.center = mPanelCenterPtAlter;
    [UIView commitAnimations];
    
    [slideBarView disableWithText:NSLocalizedString(@"SELECT_YOUR_TIMER", @"select your timer")];
    [self enableHandle];
    mHasShownUp = YES;
    
    [self.delegate panelMovedUp:self];
}

- (void)slideDown {
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    panelView.center = mPanelCenterPt;
    [UIView commitAnimations];
    
    [slideBarView enable];
    [self disableHandle];
    mHasShownUp = NO;
    
    [self.delegate panelMovedDown:self];
}

- (void)disableHandle {
    mDisableHandle = YES;
}

- (void)enableHandle {
    mDisableHandle = NO;
}

@end
