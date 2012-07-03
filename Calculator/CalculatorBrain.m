//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Lion User on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;

+ (double)lastDisplayResult;
+ (void)setLastDisplayResult:(double)value;
@end


@implementation CalculatorBrain

@synthesize programStack = _programStack;


- (NSMutableArray *)programStack
{
    if (_programStack == nil)
    {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

- (void)pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (double)performOperation:(NSString *)operation
{
    if ([@"clear" isEqualToString:operation]) {
        [self.programStack removeAllObjects];
        return (double)0;
    }
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program];
}

- (id)program
{
    return [self.programStack copy];
}


//---------
static  NSNumber *_lastResult = nil;

+ (double)lastDisplayResult
{
    if (! _lastResult) {
        _lastResult = [NSNumber numberWithDouble:(double)0];
    }
    return [_lastResult doubleValue];
}

+ (void)setLastDisplayResult:(double)value
{
    _lastResult = [NSNumber numberWithDouble:value];
}
//---------


+ (double)popOperand:(NSMutableArray *)stack
{
    double result = 0;
    id topOfStack = [stack lastObject];
    if (topOfStack)
    {
        [stack removeLastObject];
    }
    else { // --- nothing on stack
        result = [self lastDisplayResult];
        NSLog(@"WARNING: empty stack! -- using last value: %g", result);
    }
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [topOfStack doubleValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operation = topOfStack;
        // first process operations that take 0 arguments
        if ([@"pi" isEqualToString:operation]) {
            NSLog(@"pi");
            result = M_PI;
        }
        else if ([@"e" isEqualToString:operation]) {
            NSLog(@"e");
            result = M_E;
        }
        // next process operations that take 1 argument
        else {
            double topNumber = [self popOperand:stack];
            if ([@"+/-" isEqualToString:operation]) {
                NSLog(@"+/-");
                result = -topNumber;
            }
            else if ([@"sin" isEqualToString:operation]) {
                NSLog(@"sin(%g)", topNumber);
                result = sin(topNumber);
            }
            else if ([@"cos" isEqualToString:operation]) {
                NSLog(@"cos(%g)", topNumber);
                result = cos(topNumber);
            }
            else if ([@"sqrt" isEqualToString:operation]) {
                NSLog(@"sqrt(%g)", topNumber);
                result = sqrt(topNumber);
            }
            else if ([@"log" isEqualToString:operation]) {
                NSLog(@"log(%g)", topNumber);
                result = log(topNumber);
            }
            else if ([@"%" isEqualToString:operation]) {
                NSLog(@"percent(%g)", topNumber);
                result = topNumber / 100.0;
            }
            else {
                // last process operations that take 2 arguments
                double secondNumber = [self popOperand:stack];
                double firstNumber = topNumber;
                if ([@"+" isEqualToString:operation])
                {
                    NSLog(@"%g + %g", secondNumber, firstNumber);
                    result = secondNumber + firstNumber;
                }
                else if ([@"-" isEqualToString:operation])
                {
                    NSLog(@"%g - %g", secondNumber, firstNumber);
                    result = secondNumber - firstNumber;
                }
                else if ([@"*" isEqualToString:operation])
                {
                    NSLog(@"%g * %g", secondNumber, firstNumber);
                    result = secondNumber * firstNumber;
                }
                else if ([@"/" isEqualToString:operation])
                {
                    NSLog(@"%g / %g", secondNumber, firstNumber);
                    if (secondNumber && firstNumber) {
                        result = secondNumber / firstNumber;
                    }
                    else {
                        result = 0;
                    }
                }
                else {
                    NSLog(@"ERROR: invalid operation=%@", operation);
                }
            }
        }
    }
    NSLog(@"result=%g", result);
    [CalculatorBrain setLastDisplayResult:result];
    return result;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", (NSMutableArray *)self.program];
}
    
+ (double)runProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    NSLog(@"runProgram: %@", [self descriptionOfProgram:stack]);
    double result = [self popOperand:stack];
    [CalculatorBrain setLastDisplayResult:result];
    return result;
}

+ (NSString *)descriptionOfProgram:(id)program
{
    return [NSString stringWithFormat:@"STACK = %@", (NSMutableArray *)program];
}

@end
