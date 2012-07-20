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
@property (nonatomic, strong) UIBarButtonItem *splitViewBarButtonItem;
@end

@interface GraphViewController : UIViewController <GraphViewDelegate, SplitViewBarButtonItemPresenter>

@property (nonatomic, strong) CalculatorBrain *brain;

@end
