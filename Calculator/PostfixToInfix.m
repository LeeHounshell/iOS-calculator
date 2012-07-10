//
//  PostfixToInfix.m
//  Calculator
//
//  Created by Lee Hounshell on 7/7/12.
//  Copyright (c) 2012 H.A.R.L.I.E. All rights reserved.
//

#import "PostfixToInfix.h"

@implementation PostfixToInfix

+(NSString *)convert:(NSArray *)program
{
    NSString *result = @"";
    if ([program count]) {
        NSLog(@"---------INFIX CONVERSION---------");
        NSLog(@"RPN=%@", program);
        NSMutableArray *theProgram = [[NSMutableArray alloc] initWithArray:program];
        NSMutableArray *evalStack = [[NSMutableArray alloc] init];
        NSSet *possibleUnaryOperators = [[NSSet alloc] initWithObjects:@"sin", @"cos", @"sqrt", @"ln", @"%", nil];
        NSSet *possibleBinaryOperators = [[NSSet alloc] initWithObjects:@"+", @"-", @"*", @"/", nil];
        
        while ([theProgram count]) {
            id programElement = [PostfixToInfix popFirstElementOffProgram:theProgram];
            if (! programElement) {
                break;
            }
            if ([programElement isKindOfClass:[NSString class]]) {
                NSString *element = (NSString *)programElement;
                if ([possibleUnaryOperators containsObject:element]) {
                    NSString *singleArgument = [PostfixToInfix popLastElementOffStack:evalStack];
                    [evalStack addObject:[NSString stringWithFormat:@"%@(%@)", element, [singleArgument stripParensFromEnds]]];
                }
                else if ([possibleBinaryOperators containsObject:element]) {
                    NSString *secondArgument = [PostfixToInfix popLastElementOffStack:evalStack];
                    NSString *firstArgument = [PostfixToInfix popLastElementOffStack:evalStack];
                    [evalStack addObject:[NSString stringWithFormat:@"(%@%@%@)", firstArgument, element, secondArgument]];
                }
                else if ([@"+/-" isEqualToString:element]) {
                    NSString *argument = [PostfixToInfix popLastElementOffStack:evalStack];
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
                    result = [NSString stringWithFormat:@"(%@)", result];
                }
                result = [result stringByAppendingString:@"?"];
                result = [result stringByAppendingString:[NSString stringWithFormat:@"(%@)", [tmpResult stripParensFromEnds]]];
            }
            else {
                result = [result stringByAppendingString:[tmpResult stripParensFromEnds]];
            }
        }
    }
    NSLog(@"INFIX result=%@", result);
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
