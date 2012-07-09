//
//  PostfixToInfix.h
//  Calculator
//
//  Created by Lee Hounshell on 7/7/12.
//  Copyright (c) 2012 H.A.R.L.I.E. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostfixToInfix : NSObject

// infix converter for CalculatorBrain programs
+(NSArray *)convert:(NSArray *)theProgram;

@end
