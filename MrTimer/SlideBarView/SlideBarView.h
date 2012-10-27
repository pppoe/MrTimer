//
//  SlideBarView.h
//  MrTimer
//
//  Created by li haoxiang on 10/24/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SlideBarView;
@class MPGlowLabel;

@protocol SlideBarViewDelegate <NSObject>

- (void)slidingFinished:(SlideBarView*)slideBarView;
- (void)handleTouched:(SlideBarView*)slideBarView touch:(UITouch*)touch;
- (void)handleMoved:(SlideBarView*)slideBarView touch:(UITouch*)touch;
- (void)handleEnded:(SlideBarView*)slideBarView touch:(UITouch*)touch;
- (void)handleCanceled:(SlideBarView*)slideBarView;

@end

@interface SlideBarView : UIView {
@private
    MPGlowLabel *mGrowLabel;
    UISlider    *mSlider;
    CGRect mGrooveRect;
    CGRect mHandleRect;
    
    BOOL mSlideMoving;
    BOOL mTouchDeteced;
}

@property (nonatomic) id<SlideBarViewDelegate> delegate;

@property (nonatomic) NSString *displayText;
@property (nonatomic) CGFloat leftPadding;
@property (nonatomic) CGFloat rightPadding;
@property (nonatomic) BOOL showRightHandler;

@end
