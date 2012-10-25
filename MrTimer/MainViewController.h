//
//  MainViewController.h
//  MrTimer
//
//  Created by li haoxiang on 10/23/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ClockView;
@class SlideBarView;
@class MPCustomView;

@interface MainViewController : UIViewController

@property IBOutlet MPCustomView *bgCustomView;

@property IBOutlet ClockView *clockView;
@property IBOutlet SlideBarView *slideBarView;

@end
