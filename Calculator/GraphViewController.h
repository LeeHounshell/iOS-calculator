//
//  GraphViewController.h
//  Calculator
//
//  Created by Lee Hounshell on 7/14/12.
//  Copyright (c) 2012 H.A.R.L.I.E. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"
#import "CalculatorBrain.h"

@protocol SplitViewBarButtonItemPresenter <NSObject>
- (void)setupSplitViewBarButtonItemAtPosition:(int)index doDisplay:(BOOL)displayItHint;
@property (nonatomic, strong) UIPopoverController *myPopoverController;
@property (nonatomic, weak) id delegate;
@end

@interface GraphViewController : UIViewController <GraphViewDelegate, UISplitViewControllerDelegate, SplitViewBarButtonItemPresenter>
@property (nonatomic, strong) CalculatorBrain *brain;
@end
