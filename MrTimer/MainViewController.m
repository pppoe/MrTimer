//
//  MainViewController.m
//  MrTimer
//
//  Created by li haoxiang on 10/23/12.
//  Copyright (c) 2012 Haoxiang Li. All rights reserved.
//

#import "MainViewController.h"
#import "ClockView.h"
#import "PanelSlideBarView.h"
#import "MPCustomView.h"
#import "MPColorUtil.h"
#import "MPCoreGraphicsUtil.h"
#import "MPGlowLabel.h"
#import "MPAnimationUtil.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

#define kClockButtonSize 44
#define kContentDictKeyLeftTime     @"kContentDictKeyLeftTime"
#define kContentDictKeyMiddleTime   @"kContentDictKeyMiddleTime"
#define kContentDictKeyRightTime    @"kContentDictKeyRightTime"

#define kButtonAnimationKeyPath @"borderColor"
#define kAnimationKeyBtn        @"kAnimationKeyBtn"

#define kMainBlueColor 0xFF0367E7
#define kIndexLeft      0
#define kIndexMiddle    1
#define kIndexRight     2

@interface MainViewController () <MPCustomViewDelegate, ClockViewDelegate, PanelSlideBarViewDelegate>

- (void)presentActiveViewWithColor:(UIColor*)color;
- (void)resetActiveView;

@end

@implementation MainViewController
@synthesize clockView, bgCustomView, panelView, panelContentView;
@synthesize leftBtn, middleBtn, rightBtn;
@synthesize leftBtnLabel, middleBtnLabel, rightBtnLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        mContentDict = [NSMutableDictionary
                        dictionaryWithObjectsAndKeys:
//                        [NSNumber numberWithInt:15*60], kContentDictKeyLeftTime,
//                        [NSNumber numberWithInt:30*60], kContentDictKeyMiddleTime,
//                        [NSNumber numberWithInt:60*60], kContentDictKeyRightTime,
                        [NSNumber numberWithInt:15], kContentDictKeyLeftTime,
                        [NSNumber numberWithInt:5*60], kContentDictKeyMiddleTime,
                        [NSNumber numberWithInt:15*60], kContentDictKeyRightTime,
//                        [NSNumber numberWithInt:15], kContentDictKeyLeftTime,
//                        [NSNumber numberWithInt:30], kContentDictKeyMiddleTime,
//                        [NSNumber numberWithInt:60], kContentDictKeyRightTime,
                        nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor clearColor];

    void (^prepareButton)(UIButton *btn, UILabel *label, NSString *key) =
    ^(UIButton *btn, UILabel *label, NSString *key){
        int timeInSeconds = [[mContentDict valueForKey:key] intValue];
        UIImage *image = [ClockView imageOfTime:timeInSeconds
                                       withSize:CGSizeMake(kClockButtonSize, kClockButtonSize)
                                      withColor:kMainBlueColor];
        [btn setImage:image forState:UIControlStateNormal];
        
        NSString *dateStr = [NSString stringWithFormat:@"%02d:%02d",
                             timeInSeconds/60,
                             timeInSeconds%60];
        label.text = dateStr;
    };
    
    prepareButton(self.leftBtn, self.leftBtnLabel, kContentDictKeyLeftTime);
    prepareButton(self.middleBtn, self.middleBtnLabel, kContentDictKeyMiddleTime);
    prepareButton(self.rightBtn, self.rightBtnLabel, kContentDictKeyRightTime);

    self.clockView.delegate = self;

    self.panelView.panelContentView = self.panelContentView;
    self.panelView.delegate = self;

    self.bgCustomView.delegate = self;
    self.bgCustomView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"newbg"]];
    
    mControlArray = [NSArray arrayWithObjects:
                     [NSArray arrayWithObjects:
                      self.leftBtn, self.leftBtnLabel, kContentDictKeyLeftTime, nil],
                     [NSArray arrayWithObjects:
                      self.middleBtn, self.middleBtnLabel, kContentDictKeyMiddleTime, nil],
                     [NSArray arrayWithObjects:
                      self.rightBtn, self.rightBtnLabel, kContentDictKeyRightTime, nil],
                     nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.panelView showUp];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)drawRect:(CGRect)rect inCustomView:(MPCustomView *)view {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeOverlay);
    [MPCoreGraphicsUtil renderCenterCircleGradient:context
                                       rect:rect
                                    outerColorCode:0x00FFFFFF
                                    innerColorCode:0xFFFFFFFF];
    
}

- (void)refreshViews {
    [self.panelView setNeedsDisplay];
}

- (IBAction)testBtnTapped:(id)sender {
    [self.clockView resetWithAnimation:YES];
}

- (IBAction)leftBtnTapped:(id)sender {
    [self.clockView tickToTime:
     [[mContentDict valueForKey:kContentDictKeyLeftTime] intValue]];
    [self.panelView slideDown];

    [self resetActiveView];
    mActiveControlIndex = kIndexLeft;
}

- (IBAction)middleBtnTapped:(id)sender {
    [self.clockView tickToTime:
     [[mContentDict valueForKey:kContentDictKeyMiddleTime] intValue]];
    [self.panelView slideDown];

    [self resetActiveView];
    mActiveControlIndex = kIndexMiddle;
}

- (IBAction)rightBtnTapped:(id)sender {
    [self.clockView tickToTime:
     [[mContentDict valueForKey:kContentDictKeyRightTime] intValue]];
    [self.panelView slideDown];

    [self resetActiveView];
    mActiveControlIndex = kIndexRight;
}

- (void)scheduledTimeFinished:(ClockView *)clockView {
    //< Flash Clock
    [self.panelView enableHandle];
    [self.panelView showUp];
    [self.clockView flashGreen];

    [self presentActiveViewWithColor:[UIColor greenColor]];
}

- (void)barSlided:(PanelSlideBarView *)panelSlideBarView {
    //< Flash Clock
    [self.clockView resetWithAnimation:YES];
    [self.panelView showUp];
    [self.clockView flashRed];
    
    [self presentActiveViewWithColor:[UIColor redColor]];
}

- (void)panelMovedUp:(PanelSlideBarView*)panelSlideBarView {
    
}

- (BOOL)panelShouldMovedDown:(PanelSlideBarView*)panelSlideBarView {
    return [clockView running];
}

- (void)panelMovedDown:(PanelSlideBarView*)panelSlideBarView {
    if ([clockView running])
    {
        [panelSlideBarView disableHandle];
    }
}

- (void)presentActiveViewWithColor:(UIColor*)color {
    UIButton *btn = [[mControlArray objectAtIndex:mActiveControlIndex] objectAtIndex:0];
    UILabel *label = [[mControlArray objectAtIndex:mActiveControlIndex] objectAtIndex:1];
    NSString *key = [[mControlArray objectAtIndex:mActiveControlIndex] objectAtIndex:2];
    
    UIImage *image = [ClockView imageOfTime:[[mContentDict valueForKey:key] intValue]
                                   withSize:CGSizeMake(kClockButtonSize, kClockButtonSize)
                                  withColor:[MPColorUtil colorInHex:color]];
    [btn setImage:image forState:UIControlStateNormal];
    
    label.textColor = color;
    label.alpha = 0.3;
    btn.alpha = 0.3;
    [UIView beginAnimations:kAnimationKeyBtn context:nil];
    [UIView setAnimationDuration:3.0];
    label.alpha = 1.0;
    btn.alpha = 1.0;
    [UIView commitAnimations];
}

- (void)resetActiveView {
    UIColor *color = [MPColorUtil colorFromHex:kMainBlueColor];
    UIButton *btn = [[mControlArray objectAtIndex:mActiveControlIndex] objectAtIndex:0];
    UILabel *label = [[mControlArray objectAtIndex:mActiveControlIndex] objectAtIndex:1];
    NSString *key = [[mControlArray objectAtIndex:mActiveControlIndex] objectAtIndex:2];
    
    UIImage *image = [ClockView imageOfTime:[[mContentDict valueForKey:key] intValue]
                                   withSize:CGSizeMake(kClockButtonSize, kClockButtonSize)
                                  withColor:kMainBlueColor];
    [btn setImage:image forState:UIControlStateNormal];
    
    label.textColor = color;
    label.alpha = 1.0;
    btn.alpha = 1.0;
}

@end
