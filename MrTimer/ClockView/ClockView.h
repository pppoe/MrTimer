//
//  ClockView.h
//  MrTimer
//
//  Created by li haoxiang on 10/24/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClockView : UIView {
@public
    int mTimeInSeconds;
    int mTotalSegs;
@private
    int mCircleSegs;
}

@end
