//
//  AppDelegate.h
//  MrTimer
//
//  Created by li haoxiang on 10/23/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    MainViewController *mMainVC;
}

@property (strong, nonatomic) UIWindow *window;

@end
