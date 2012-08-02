//
//  CalculatorProgramsTableViewController.h
//  Calculator
//
//  Created by Lee Hounshell on 7/27/12.
//  Copyright (c) 2012 H.A.R.L.I.E. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FAVORITES_KEY @"GraphViewController.Favorites"

@class CalculatorProgramsTableViewController;


@protocol CalculatorProgramsTableViewControllerDelegate

@optional
- (void)calculatorProgramsTableViewController:(CalculatorProgramsTableViewController *)sender
                     choseProgramAndVariables:(id)programAndVariablesDict;

@end


@interface CalculatorProgramsTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *programs; // of CalculatorBrain programs including the variable assignments
@property (nonatomic, weak) id <CalculatorProgramsTableViewControllerDelegate> delegate;

@end
