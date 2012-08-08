//
//  CalculatorViewController.h
//  Calculator
//
//  Created by Lee Hounshell on 5/29/12.
//  Copyright (c) 2012 Harlie All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CalculationControlProtocol

- (void)pushOperand:(double)operand;
- (double)performOperation:(NSString *)operation usingVariableValues:(NSDictionary *)variables;
- (BOOL)setVariable:(NSString *)variable withValue:(NSArray *)value;
- (NSString *)description;

@property (readonly) id program; // guaranteed to be a Property List
@property (readonly) id variables; // guaranteed to be a Dictionary

@end



@protocol CalculatorViewControllerProtocol <NSObject>

- (id<CalculationControlProtocol>)brain;
- (void)remakeTheCalculator:(id)commLinkup;
- (void)setProgram:(id)aProgram andVariables:(id)someVariables;

@end


#import "CalculatorBrain.h"
#import "GraphViewController.h"


@interface CalculatorViewController : UIViewController <CalculatorViewControllerProtocol>

@property (nonatomic, weak) id graphViewCtl;

@end
