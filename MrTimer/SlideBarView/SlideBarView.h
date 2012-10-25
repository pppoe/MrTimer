//
//  SlideBarView.h
//  MrTimer
//
//  Created by li haoxiang on 10/24/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MPLayerSupport;

@interface SlideBarView : UIView {
@private
    MPLayerSupport *mLayerSupport;
    CALayer *mTopLayer;
    CALayer *mUnderLayer;
}

@property (nonatomic) NSString *displayText;

@end
