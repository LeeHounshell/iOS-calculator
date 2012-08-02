//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Lee Hounshell on 5/29/12.
//  Copyright (c) 2012 H.A.R.L.I.E. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+Whitespace.h"

@interface CalculatorBrain : NSObject <NSCopying>

- (void)pushOperand:(double)operand;
- (BOOL)setVariable:(NSString *)variable withValue:(NSArray *)value;
- (double)performOperation:(NSString *)operation usingVariableValues:(NSDictionary *)variables;
- (NSString *)description;

@property (readonly) id program; // guaranteed to be a Property List
@property (readonly) id variables; // guaranteed to be a Dictionary

+ (double)runProgram:(id)program;
+ (double)runProgram:(id)program usingVariableValues:(id)myVariableValues;

+ (NSString *)descriptionOfProgram:(id)program;
+ (NSString *)descriptionOfVariables:(id)variables forProgram:(id)program;
+ (NSSet *)variablesUsedInProgram:(id)program;
+ (double)lastDisplayResult;

@end
