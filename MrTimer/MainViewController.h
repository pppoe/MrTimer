//
//  MainViewController.h
//  MrTimer
//
//  Created by li haoxiang on 10/23/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ClockView;
@class PanelSlideBarView;
@class MPCustomView;

@interface MainViewController : UIViewController {
    NSMutableDictionary *mContentDict;

    NSArray *mControlArray; //< Array of Array (Button, Label, Key)
    int     mActiveControlIndex; //< 0:Left 1:Middle 2:Right
}

@property IBOutlet MPCustomView *bgCustomView;

@property IBOutlet ClockView *clockView;
@property IBOutlet PanelSlideBarView *panelView;
@property IBOutlet UIView    *panelContentView;

@property IBOutlet UIButton   *leftBtn;
@property IBOutlet UIButton   *middleBtn;
@property IBOutlet UIButton   *rightBtn;

@property IBOutlet UILabel   *leftBtnLabel;
@property IBOutlet UILabel   *middleBtnLabel;
@property IBOutlet UILabel   *rightBtnLabel;

- (void)refreshViews;

- (IBAction)leftBtnTapped:(id)sender;
- (IBAction)middleBtnTapped:(id)sender;
- (IBAction)rightBtnTapped:(id)sender;

- (IBAction)testBtnTapped:(id)sender;

@end
