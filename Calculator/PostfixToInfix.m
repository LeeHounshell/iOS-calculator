//
//  PostfixToInfix.m
//  Calculator
//
//  Created by Lee Hounshell on 7/7/12.
//  Copyright (c) 2012 H.A.R.L.I.E. All rights reserved.
//

#import "PostfixToInfix.h"

@implementation PostfixToInfix

+(NSString *)convert:(id)program
{
    NSString *result = @"";
    if ([program isKindOfClass:[NSArray class]] && [program count]) {
        //NSLog(@"---------INFIX CONVERSION---------");
        //NSLog(@"RPN=%@", program);
        NSMutableArray *theProgram = [[NSMutableArray alloc] initWithArray:(NSArray *)program];
        NSMutableArray *evalStack = [[NSMutableArray alloc] init];
        NSSet *possibleUnaryOperators = [[NSSet alloc] initWithObjects:@"││", @"¹/x", @"sin", @"cos", @"tan", @"√", @"㏑", @"%", nil];
        NSSet *possibleBinaryOperators = [[NSSet alloc] initWithObjects:@"+", @"-", @"*", @"/", @"yⁿ", nil];
        
        while ([theProgram count]) {
            id programElement = [PostfixToInfix popFirstElementOffProgram:theProgram];
            if (! programElement) {
                break;
            }
            if ([programElement isKindOfClass:[NSString class]]) {
                NSString *element = (NSString *)programElement;
                if ([possibleUnaryOperators containsObject:element]) {
                    NSString *singleArgument = [PostfixToInfix popLastElementOffStack:evalStack];
                    if (! singleArgument) { // short stack
                        singleArgument = @"?";
                    }
                    if ([@"││" isEqualToString:element]) { // absolute value
                        [evalStack addObject:[NSString stringWithFormat:@"│%@│", [singleArgument stripParensFromEnds]]];
                    }
                    else if ([@"¹/x" isEqualToString:element]) { // inverse
                        [evalStack addObject:[NSString stringWithFormat:@"1/(%@)", [singleArgument stripParensFromEnds]]];
                    }
                    else if ([@"%" isEqualToString:element]) { // percent
                        [evalStack addObject:[NSString stringWithFormat:@"(%@)%@", [singleArgument stripParensFromEnds], @"%"]];
                    }
                    else {
                        [evalStack addObject:[NSString stringWithFormat:@"%@(%@)", element, [singleArgument stripParensFromEnds]]];
                    }
                }
                else if ([possibleBinaryOperators containsObject:element]) {
                    NSString *secondArgument = [PostfixToInfix popLastElementOffStack:evalStack];
                    if (! secondArgument) { // short stack
                        secondArgument = @"?";
                    }
                    NSString *firstArgument = [PostfixToInfix popLastElementOffStack:evalStack];
                    if (! firstArgument) { // short stack
                        firstArgument = @"?";
                    }
                    [evalStack addObject:[NSString stringWithFormat:@"(%@%@%@)", firstArgument, element, secondArgument]];
                }
                else if ([@"+/-" isEqualToString:element]) {
                    NSString *argument = [PostfixToInfix popLastElementOffStack:evalStack];
                    if (! argument) { // short stack
                        argument = @"?";
                    }
                    [evalStack addObject:[NSString stringWithFormat:@" -(%@) ", [argument stripParensFromEnds]]];
                }
                else {
                    NSString *variable = [NSString stringWithString:element];
                    [evalStack addObject:variable];
                }
            }
            else if ([programElement isKindOfClass:[NSNumber class]]) {
                double value = [(NSNumber *)programElement doubleValue];
                NSString *strNumber = [NSString stringWithFormat:@"%g", value];
                [evalStack addObject:strNumber];
            }
            else {
                NSLog(@"ERROR: unknown element=%@", programElement);
            }
        }
        for (int i = 0; i < [evalStack count]; i++) {
            NSString *tmpResult = [evalStack objectAtIndex:i];
            if (i) {
                if (i == 1) {
                    if (1 == [result length]) {
                        result = [NSString stringWithFormat:@"%@", result];
                    }
                    else {
                        result = [NSString stringWithFormat:@"(%@)", result];
                    }
                }
                result = [result stringByAppendingString:@"?"];
                if (1 == [tmpResult length]) {
                    result = [result stringByAppendingString:[NSString stringWithFormat:@"%@", [tmpResult stripParensFromEnds]]];
                }
                else {
                    result = [result stringByAppendingString:[NSString stringWithFormat:@"(%@)", [tmpResult stripParensFromEnds]]];
                }
            }
            else {
                result = [result stringByAppendingString:[tmpResult stripParensFromEnds]];
            }
        }
        NSRange range = [result rangeOfString:@"null"];
        if (range.length) {
            result = @"ERROR";
        }
    }
    //NSLog(@"INFIX result=%@", result);
    return result;
}

+(id)popFirstElementOffProgram:(NSMutableArray *)programStack
{
    id bottomOfStack = [programStack objectAtIndex:0];
    if (bottomOfStack)
    {
        [programStack removeObjectAtIndex:0];
    }
    return bottomOfStack;
}

+(NSString *)popLastElementOffStack:(NSMutableArray *)programStack
{
    id topOfStack = [programStack lastObject];
    if (topOfStack)
    {
        [programStack removeLastObject];
    }
    return topOfStack;
}


@end
