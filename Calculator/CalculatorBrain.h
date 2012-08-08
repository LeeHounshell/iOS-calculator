//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Lee Hounshell on 5/29/12.
//  Copyright (c) 2012 Harlie All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+Whitespace.h"
#import "CalculatorViewController.h"


@interface CalculatorBrain : NSObject <CalculationControlProtocol, NSCopying>

+ (double)runProgram:(id)program;
+ (double)runProgram:(id)program usingVariableValues:(id)myVariableValues;

+ (NSString *)descriptionOfProgram:(id)program;
+ (NSString *)descriptionOfVariables:(id)variables forProgram:(id)program;
+ (NSSet *)variablesUsedInProgram:(id)program;
+ (double)lastDisplayResult;

@end
