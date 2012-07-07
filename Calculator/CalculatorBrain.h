//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Lee Hounshell on 5/29/12.
//  Copyright (c) 2012 H.A.R.L.I.E. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+Whitespace.h"

@interface CalculatorBrain : NSObject

- (void)pushOperand:(double)operand;
- (BOOL)setVariable:(NSString *)variable withValue:(NSArray *)value;
- (NSString *)getAllVariableSubPrograms;
- (double)performOperation:(NSString *)operation usingVariableValues:(NSDictionary *)variables;
- (NSString *)description;

@property (readonly) id program;
@property (readonly) id variables;

+ (double)runProgram:(id)program;
+ (double)runProgram:(id)program
 usingVariableValues:(NSDictionary *)myVariableValues;

+ (NSString *)descriptionOfProgram:(id)program;

@end
