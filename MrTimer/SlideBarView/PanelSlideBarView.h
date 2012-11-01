//
//  PanelSlideBarView.h
//  MrTimer
//
//  Created by li haoxiang on 10/26/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SlideBarView;
@class PanelSlideBarView;

@protocol PanelSlideBarViewDelegate <NSObject>

- (void)barSlided:(PanelSlideBarView*)panelSlideBarView;
- (void)panelMovedUp:(PanelSlideBarView*)panelSlideBarView;
- (BOOL)panelShouldMovedDown:(PanelSlideBarView*)panelSlideBarView;
- (void)panelMovedDown:(PanelSlideBarView*)panelSlideBarView;

@end

@interface PanelSlideBarView : UIView {
@private
    SlideBarView *slideBarView;
    UIView       *panelView;
    BOOL         mHasShownUp;
    BOOL         mDisableHandle;
    
    CGPoint mDefaultHandlePt;
    CGPoint mPanelCenterPt;
    CGPoint mPanelCenterPtAlter;
    CGPoint *pTouchBeginCenterPt;
}

@property (nonatomic) UIView *panelContentView;
@property (nonatomic) id<PanelSlideBarViewDelegate> delegate;

- (void)showUp;
- (void)slideDown;
- (void)disableHandle;
- (void)enableHandle;

@end
