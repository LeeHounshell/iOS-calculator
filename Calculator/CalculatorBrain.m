//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Lee Hounshell on 5/29/12.
//  Copyright (c) 2012 H.A.R.L.I.E. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
@property (nonatomic, strong) NSMutableDictionary *variableValues;

+ (double)lastDisplayResult;
+ (void)setLastDisplayResult:(double)value;
+ (NSMutableArray *)replaceVariablesInProgram:(id)program usingValuesFrom:(id)myVariables;
+ (NSSet *)variablesUsedInProgram:(id)program;
+ (NSString *)formatProgram:(NSArray *)theProgram;
@end


@implementation CalculatorBrain

@synthesize programStack = _programStack;
@synthesize variableValues = _variableValues;


- (NSMutableArray *)programStack
{
    if (_programStack == nil)
    {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

- (NSMutableDictionary *)variableValues
{
    if (_variableValues == nil)
    {
        _variableValues = [[NSMutableDictionary alloc] init];
    }
    return _variableValues;
}

- (BOOL)setVariable:(NSString *)variable withValue:(NSString *)value
{
    NSLog(@"SET(%@ = %@)", variable, value);
    [self.variableValues setValue:value forKey:variable];
    [CalculatorBrain setLastDisplayResult:(double)0];
    return YES;
}

- (void)pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

- (double)performOperation:(NSString *)operation usingVariableValues:(NSDictionary *)myVariables
{
    if ([@"clear" isEqualToString:operation]) {
        [self.programStack removeAllObjects];
        if (myVariables) { // use custom variables?
            self.variableValues = [myVariables mutableCopy];
        } // otherwise old variable settings are not cleared
        return (double)0;
    }
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program usingVariableValues:myVariables];
}

- (id)program
{
    return [self.programStack copy];
}

- (id)variables
{
    return [self.variableValues copy];
}

- (NSString *)description
{
    return [CalculatorBrain formatProgram:self.program];
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


+ (double)popOperandOffStack:(NSMutableArray *)stack
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
        if ([@"π" isEqualToString:operation]) {
            result = M_PI;
        }
        else if ([@"e" isEqualToString:operation]) {
            result = M_E;
        }
        // next process operations that take 1 argument
        else {
            double topNumber = [self popOperandOffStack:stack];
            if ([@"+/-" isEqualToString:operation]) {
                result = -topNumber;
            }
            else if ([@"sin" isEqualToString:operation]) {
                result = sin(topNumber);
            }
            else if ([@"cos" isEqualToString:operation]) {
                result = cos(topNumber);
            }
            else if ([@"sqrt" isEqualToString:operation]) {
                result = sqrt(topNumber);
            }
            else if ([@"log" isEqualToString:operation]) {
                result = log(topNumber);
            }
            else if ([@"%" isEqualToString:operation]) {
                result = topNumber / 100.0;
            }
            else {
                // last process operations that take 2 arguments
                double secondNumber = [self popOperandOffStack:stack];
                double firstNumber = topNumber;
                if ([@"+" isEqualToString:operation])
                {
                    result = secondNumber + firstNumber;
                }
                else if ([@"-" isEqualToString:operation])
                {
                    result = secondNumber - firstNumber;
                }
                else if ([@"*" isEqualToString:operation])
                {
                    result = secondNumber * firstNumber;
                }
                else if ([@"/" isEqualToString:operation])
                {
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

+ (double)runProgram:(id)program
{
    return [self runProgram:program usingVariableValues:nil];
}
    
+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)myVariableValues
{
    NSMutableArray *stack = [program mutableCopy];
    NSSet *variablesUsed = [CalculatorBrain variablesUsedInProgram:program];
    if ([variablesUsed count]) {
        NSLog(@"found variables we need to evaluate..");
        stack = [CalculatorBrain replaceVariablesInProgram:stack usingValuesFrom:myVariableValues];
    }
    return [CalculatorBrain popOperandOffStack:stack];
}
                     
+ (NSMutableArray *)replaceVariablesInProgram:(id)program usingValuesFrom:(id)myVariables
{
    if (! myVariables || (! [program isKindOfClass:[NSArray class]])) {
        NSLog(@"nothing to replace.");
        return program; // unchanged
    }
    NSMutableArray *newProgram = [[NSMutableArray alloc] init];
    NSSet *possibleVariables = [[NSSet alloc] initWithObjects:@"A", @"B", @"C", @"X", @"Y", @"Z", nil];
    for (id programElement in program) {
        if ([programElement isKindOfClass:[NSString class]]) {
            NSString *operator = [NSString stringWithString:(NSString *)programElement];
            if ([possibleVariables containsObject:operator]) {
                double subValue = [CalculatorBrain runProgram:[myVariables objectForKey:operator] usingVariableValues:myVariables];
                NSLog(@"calculated replacement subValue=%g for key=%@", subValue, operator);
                [newProgram insertObject:[NSNumber numberWithDouble:subValue]atIndex:[newProgram count]];
                continue;
            }
        }
        [newProgram insertObject:programElement atIndex:[newProgram count]];
    }
    NSLog(@"newProgram=%@", newProgram);
    return newProgram;
}

+ (NSSet *)variablesUsedInProgram:(id)program;
{
    NSMutableSet *varNames = [[NSMutableSet alloc] init];
    if ([program isKindOfClass:[NSArray class]]) {
        NSSet *possibleVariables = [[NSSet alloc] initWithObjects:@"A", @"B", @"C", @"X", @"Y", @"Z", nil];
        for (int i = 0; i < [program count]; i++) {
            NSString *operator = (NSString *)[program objectAtIndex:i];
            if ([possibleVariables containsObject:operator])
            {
                [varNames addObject:operator];
            }
        }
    }
    if (! [varNames count]) {
        return nil;
    }
    return [varNames copy];
}

+ (NSString *)descriptionOfProgram:(id)program
{
    return [CalculatorBrain formatProgram:program];
}

+ (NSString *)formatProgram:(NSArray *)theProgram
{
    NSCharacterSet *notAllowedChars = [NSCharacterSet characterSetWithCharactersInString:@"(),\n\t\""];
    NSString *englishDescription = [NSString stringWithFormat:@"%@", theProgram];
    englishDescription = [[englishDescription componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    // replace the unicode string for PI with the π character
    englishDescription = [englishDescription stringByReplacingOccurrencesOfString:@"\\U03c0" withString:@"π"];
    englishDescription = [englishDescription stringByCompressingWhitespaceTo:@" "];
    NSLog(@"englishDescription = %@", englishDescription);
    return englishDescription;
}

@end
