//
//  PostfixToInfix.h
//  Calculator
//
//  Created by Lee Hounshell on 7/7/12.
//  Copyright (c) 2012 Harlie All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+Whitespace.h"

@interface PostfixToInfix : NSObject

// infix converter for CalculatorBrain programs
+(NSString *)convert:(id)program;

@end
