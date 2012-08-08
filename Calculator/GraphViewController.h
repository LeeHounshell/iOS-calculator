//
//  GraphViewController.h
//  Calculator
//
//  Created by Lee Hounshell on 7/14/12.
//  Copyright (c) 2012 Harlie All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalculatorViewController.h"
#import "GraphView.h"
#import "CalculatorBrain.h"


@interface GraphViewController : UIViewController <GraphViewDelegate, UISplitViewControllerDelegate>

- (void)doGraph;

@property (nonatomic, weak) id<CalculatorViewControllerProtocol> delegate;

@end

