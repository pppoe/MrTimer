//
//  MainViewController.m
//  MrTimer
//
//  Created by li haoxiang on 10/23/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import "MainViewController.h"
#import "ClockView.h"
#import "SlideBarView.h"
#import "MPCustomView.h"
#import "MPColorUtil.h"

@interface MainViewController () <MPCustomViewDelegate>

@end

@implementation MainViewController
@synthesize clockView, slideBarView, bgCustomView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.bgCustomView.delegate = self;
    self.clockView.hidden = YES;
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)drawRect:(CGRect)rect inCustomView:(MPCustomView *)view {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [MPColorUtil renderCenterCircleGradient:context
                                       rect:rect
                             outerColorCode:0xFF403E3F
                             innerColorCode:0xFF969696];
}

@end
