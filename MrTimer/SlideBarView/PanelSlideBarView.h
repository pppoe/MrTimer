//
//  PanelSlideBarView.h
//  MrTimer
//
//  Created by li haoxiang on 10/26/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SlideBarView;

@interface PanelSlideBarView : UIView {
@private
    SlideBarView *slideBarView;
    UIView       *panelView;
    BOOL         mIsScrolling;
    
    CGPoint mDefaultHandlePt;
    CGPoint mPanelCenterPt;
    CGPoint mPanelCenterPtAlter;
}

@property (nonatomic) UIView *panelContentView;

@end
