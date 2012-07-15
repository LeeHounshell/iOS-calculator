//
//  GraphViewController.h
//  Calculator
//
//  Created by Lee Hounshell on 7/14/12.
//  Copyright (c) 2012 H.A.R.L.I.E. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalculatorBrain.h"

@interface GraphViewController : UIViewController

@property (nonatomic, weak) CalculatorBrain *brain; // FIXME: change to protocol

@end
