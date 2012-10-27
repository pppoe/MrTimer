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
@synthesize panelContentView;

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
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [slideBarView setNeedsDisplay];
}

- (void)slidingFinished:(SlideBarView*)slideBarView {
    
}

- (void)handleMoved:(SlideBarView *)slideBarView touch:(UITouch *)touch {
    CGPoint pt = [touch locationInView:self];
    CGFloat newY = mPanelCenterPt.y + (pt.y - mDefaultHandlePt.y);
    CGFloat maxY = MAX(mPanelCenterPt.y, mPanelCenterPtAlter.y);
    CGFloat minY = MIN(mPanelCenterPt.y, mPanelCenterPtAlter.y);
    panelView.center = CGPointMake(mPanelCenterPt.x, MAX(MIN(maxY, newY), minY));
}

- (void)handleEnded:(SlideBarView*)slideBarView touch:(UITouch *)touch {    
    
    CGPoint pt = [touch locationInView:self];
    CGPoint retCtr = (fabs(pt.y - mDefaultHandlePt.y)
                      > 0.6*fabs(mPanelCenterPtAlter.y - mPanelCenterPt.y)) ?
    mPanelCenterPtAlter : mPanelCenterPt;
    
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    panelView.center = retCtr;
    [UIView commitAnimations];
    
    mIsScrolling = NO;
}

- (void)handleTouched:(SlideBarView*)slideBarView touch:(UITouch *)touch {
    mPanelCenterPt = panelView.center;
    CGFloat spaceGapHeight = CGRectGetHeight(self.bounds)-kSlideBarViewHeight;
    if (mPanelCenterPt.y > CGRectGetHeight(self.bounds))
    {
        mPanelCenterPtAlter = CGPointMake(panelView.center.x,
                                          panelView.center.y - spaceGapHeight);
    }
    else
    {
        mPanelCenterPtAlter = CGPointMake(panelView.center.x,
                                          panelView.center.y + spaceGapHeight);
    }
    mDefaultHandlePt = [touch locationInView:self];
    mIsScrolling = YES;
}

- (void)handleCanceled:(SlideBarView*)slideBarView {
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    panelView.center = mPanelCenterPt;
    [UIView commitAnimations];
    mIsScrolling = NO;
}

@end
