//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Lee Hounshell on 5/29/12.
//  Copyright (c) 2012 H.A.R.L.I.E. All rights reserved.
//

#import "CalculatorBrain.h"
#import "PostfixToInfix.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
@property (nonatomic, strong) NSMutableDictionary *variableValues;


+ (void)setLastDisplayResult:(double)value;
+ (NSMutableArray *)replaceVariablesInProgram:(id)program usingValuesFrom:(id)myVariables;
+(void)replaceOneVariable:(NSString *)operator inProgram:(NSMutableArray *)newProgram withValue:(double)value;
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
        NSSet *possibleVariables = [[NSSet alloc] initWithObjects:@"A", @"B", @"C", @"X", @"Y", @"Z", nil];
        NSArray *zero = [[NSArray alloc] initWithObjects:[NSNumber numberWithDouble:(double)0], nil];
        NSString *key;
        for (key in possibleVariables) {
            [self setVariable:key withValue:zero]; // initialize all variables to zero
        }
    }
    return _variableValues;
}

- (void)setVariableValues:(NSMutableDictionary *)variableValues
{
    if (variableValues) {
        _variableValues = [variableValues mutableCopy];
    }
}

- (id)copyWithZone:(NSZone *) zone
{
    NSLog(@"CalculatorBrain copyWithZone");
    CalculatorBrain *copy = [[CalculatorBrain alloc] init];
    copy.programStack = [[NSMutableArray alloc] initWithArray:[self program] copyItems:YES];
    copy.variableValues = [[NSMutableDictionary alloc] initWithDictionary:[self variables] copyItems:YES];
    return copy;
}

- (BOOL)setVariable:(NSString *)variable withValue:(NSArray *)value
{
    NSLog(@"CalculatorBrain setVariable %@=%@", variable, value);
    if (!value || ! [value count]) {
        value = [[NSArray alloc] initWithObjects:[NSNumber numberWithDouble:(double)0], nil];
    }
    NSString *pendingAssignment = [CalculatorBrain formatProgram:self.program];
    NSRange range = [pendingAssignment rangeOfString:@"?"];
    if (range.length) {
        pendingAssignment = @"ERROR";
    }
    if ([@"ERROR" isEqualToString:pendingAssignment]) {
        return NO;
    }
    [self.variableValues setValue:value forKey:variable];
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
    if ([@"backspace" isEqualToString:operation]) {
        [self.programStack removeLastObject];
    }
    else {
        [self.programStack addObject:operation];
    }
    return [CalculatorBrain runProgram:self.program usingVariableValues:myVariables];
}

- (id)program // copy returns NSArray
{
    return [self.programStack copy];
}

- (id)variables // copy returns NSDictionary
{
    return [self.variableValues copy];
}

- (NSString *)description
{
    return [CalculatorBrain formatProgram:self.program];
}


//---------
static  NSNumber *_lastResult = nil; // used to supply a default value when operation pressed but empty stack

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
    else { // --- nothing on the program stack! (but user pressed an operation or ENTER)
        //result = NAN;
        //NSLog(@"WARNING: empty stack! -- using NAN");
        result = [CalculatorBrain lastDisplayResult];
        NSLog(@"WARNING: empty stack! -- using %g", result);
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
        else if ([@"ℯ" isEqualToString:operation]) {
            result = M_E;
        }
        // next process operations that take 1 argument
        else {
            double topNumber = [self popOperandOffStack:stack];
            if ([@"+/-" isEqualToString:operation]) {
                result = -topNumber;
            }
            else if ([@"││" isEqualToString:operation]) {
                // absolute value
                result = abs(topNumber);
            }
            else if ([@"¹/x" isEqualToString:operation]) {
                // inverse
                result = 1 / topNumber;
            }
            else if ([@"sin" isEqualToString:operation]) {
                result = sin(topNumber);
            }
            else if ([@"cos" isEqualToString:operation]) {
                result = cos(topNumber);
            }
            else if ([@"tan" isEqualToString:operation]) {
                result = tan(topNumber);
            }
            else if ([@"√" isEqualToString:operation]) {
                // square root
                result = sqrt(topNumber);
            }
            else if ([@"㏑" isEqualToString:operation]) {
                // natural log
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
                else if ([@"yⁿ" isEqualToString:operation]) {
                    // power n
                    result = pow(secondNumber, firstNumber);
                }
                else {
                    NSLog(@"ERROR: invalid operation=%@", operation);
                }
            }
        }
    }
    //NSLog(@"result=%g", result);
    [CalculatorBrain setLastDisplayResult:(double)0];
    return result;
}

+ (double)runProgram:(id)program
{
    return [self runProgram:program usingVariableValues:nil];
}
    
+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)myVariableValues
{
    if (! [program isKindOfClass:[NSArray class]]) {
        NSLog(@"ERROR: invalid program: %@", program);
        return (double)0;
    }
    NSMutableArray *programStack = [program mutableCopy];
    NSSet *variablesUsed = nil;
    do {
        programStack = [CalculatorBrain replaceVariablesInProgram:programStack usingValuesFrom:myVariableValues];
        variablesUsed = [CalculatorBrain variablesUsedInProgram:programStack];
    } while ([variablesUsed count]);
    return [CalculatorBrain popOperandOffStack:programStack];
}
                     
+ (NSMutableArray *)replaceVariablesInProgram:(id)program usingValuesFrom:(id)myVariables
{
    NSSet *variablesUsed = [CalculatorBrain variablesUsedInProgram:program];
    if (! myVariables || ! [myVariables count] || ! [variablesUsed count]
        || ! [program isKindOfClass:[NSArray class]]
        || ! [myVariables isKindOfClass:[NSDictionary class]]) {
        //NSLog(@"nothing to replace.");
        return program; // unchanged
    }
    NSMutableArray *newProgram = [[NSMutableArray alloc] initWithArray:program];
    NSSet *possibleVariables = [[NSSet alloc] initWithObjects:@"A", @"B", @"C", @"X", @"Y", @"Z", nil];
    for (id programElement in program) {
        if ([programElement isKindOfClass:[NSString class]]) {
            NSString *operator = [NSString stringWithString:(NSString *)programElement];
            if ([possibleVariables containsObject:operator]) {
                double subValue = [CalculatorBrain runProgram:[myVariables objectForKey:operator] usingVariableValues:myVariables];
                [self replaceOneVariable:operator inProgram:newProgram withValue:subValue];
                continue;
            }
        }
    }
    //NSLog(@"newProgram=%@", newProgram);
    return newProgram;
}

+(void)replaceOneVariable:(NSString *)operator inProgram:(NSMutableArray *)newProgram withValue:(double)value
{
    //NSLog(@"calculated replacement subValue=%g for key=%@ in newProgram=%@", value, operator,newProgram);
    while (YES) {
        int index = [newProgram indexOfObject:operator];
        if (NSNotFound == index) {
            break;
        }
        [newProgram replaceObjectAtIndex:index withObject:[NSNumber numberWithDouble:value]];
    }
}

+ (NSSet *)variablesUsedInProgram:(id)program;
{
    NSMutableSet *varNames = [[NSMutableSet alloc] init];
    if ([program isKindOfClass:[NSArray class]]) {
        NSSet *possibleVariables = [[NSSet alloc] initWithObjects:@"A", @"B", @"C", @"X", @"Y", @"Z", nil];
        for (int i = 0; i < [program count]; i++) {
            id programElement = [program objectAtIndex:i];
            if ([programElement isKindOfClass:[NSString class]]) {
                NSString *operator = (NSString *)programElement;
                if ([possibleVariables containsObject:operator])
                {
                    [varNames addObject:operator];
                }
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
    if ([program isKindOfClass:[NSArray class]]) {
        return [CalculatorBrain formatProgram:program];
    }
    return @"";
}

+ (NSString *)formatProgram:(NSArray *)theProgram
{
    NSCharacterSet *notAllowedChars = [NSCharacterSet characterSetWithCharactersInString:@",\n\t\""];
    NSString *englishDescription = [NSString stringWithFormat:@"%@", [PostfixToInfix convert:theProgram]];
    englishDescription = [[englishDescription componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    // replace the unicode string for PI with the π character
    englishDescription = [englishDescription stringByReplacingOccurrencesOfString:@"\\U03c0" withString:@"π"];
    englishDescription = [englishDescription stringByCompressingWhitespaceTo:@" "];
    //NSLog(@"englishDescription=%@", englishDescription);
    return englishDescription;
}

@end
