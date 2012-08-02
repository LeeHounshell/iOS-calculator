//
//  CalculatorViewController.h
//  Calculator
//
//  Created by Lee Hounshell on 5/29/12.
//  Copyright (c) 2012 H.A.R.L.I.E. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculatorViewController : UIViewController

- (id)brain;
- (void)remakeTheCalculator:(id)commLinkup;
- (void)setProgram:(id)aProgram andVariables:(id)someVariables;

@property (nonatomic, weak) id graphViewCtl;

@end
