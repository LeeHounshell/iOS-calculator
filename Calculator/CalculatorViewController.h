//
//  CalculatorViewController.h
//  Calculator
//
//  Created by Lee Hounshell on 5/29/12.
//  Copyright (c) 2012 H.A.R.L.I.E. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+Whitespace.h"

@interface CalculatorViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *keystrokes;

@end
