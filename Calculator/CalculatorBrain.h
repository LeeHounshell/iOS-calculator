//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Lee Hounshell on 5/29/12.
//  Copyright (c) 2012 H.A.R.L.I.E. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushOperand:(double)operand;
- (double)performOperation:(NSString *)operation;
- (NSString *)description;

@property (readonly) id program;

+ (double)runProgram:(id)program;
+ (NSString *)descriptionOfProgram:(id)program;

@end
