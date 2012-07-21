//
//  CalculatorAppDelegate.h
//  Calculator
//
//  Created by Lee Hounshell on 5/29/12.
//  Copyright (c) 2012 H.A.R.L.I.E. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LeftViewController;
@class RightViewController;

@interface CalculatorAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, strong) IBOutlet LeftViewController *leftViewController;
@property (nonatomic, strong) IBOutlet RightViewController *rightViewController;

@end
