//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Lee Hounshell on 5/29/12.
//  Copyright (c) 2012 H.A.R.L.I.E. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"


@interface CalculatorViewController ()

@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL userPressedVariableSET;
@property (nonatomic, strong) CalculatorBrain *brain;
@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize keystrokes = _keystrokes;
@synthesize variable = _variable;
@synthesize brain = _brain;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize userPressedVariableSET = _userPressedVariableSET;


- (CalculatorBrain *)brain
{
    if (!_brain)
    {
        _brain = [[CalculatorBrain alloc] init];
    }
    return _brain;
}
 
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setDisplay:nil];
    [self setKeystrokes:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)updateDisplayWithText:(NSString *)someText
{
    self.display.text = [NSString stringWithString:someText];
    if (2 <= [self.display.text length]) {
        if ('0' == [self.display.text characterAtIndex:0]
            && '.' != [self.display.text characterAtIndex:1]) {  // leading zeroes?
            self.display.text = [self.display.text substringFromIndex:1];
        }
    }
}

- (void)updateVariableDisplay:(NSString *)variableKeypress
{
    NSSet *variablesUsed = [CalculatorBrain variablesUsedInProgram:[self.brain program]];
    NSMutableSet *allVariablesUsed = [[NSMutableSet alloc] initWithSet:variablesUsed copyItems:YES];
    if (variableKeypress) {
        [allVariablesUsed addObject:[NSString stringWithFormat:@"%@", variableKeypress]];
    }
    NSString *varValues = @"";
    NSString *key;
    for (key in allVariablesUsed) {
        NSDictionary *subProgram = [[self.brain variables] objectForKey:key];
        if (subProgram) {
            varValues = [varValues stringByAppendingString:[NSString stringWithFormat:@"   %@=%@", key, [CalculatorBrain descriptionOfProgram:subProgram]]];
        }
    }
    self.variable.text = [NSString stringWithString:varValues];
}

- (IBAction)digitPressed:(UIButton *)sender
{
    if (! self.userIsInTheMiddleOfEnteringANumber) {
        [self updateDisplayWithText:@"0"];
    }
    NSString *newDisplay = [[NSString alloc] initWithFormat:@"%@%@", self.display.text, sender.currentTitle];
    [self updateDisplayWithText:newDisplay];
    self.userIsInTheMiddleOfEnteringANumber = YES;
    [self updateKeystrokesWithEquals:NO];    
}

- (IBAction)decimalPressed
{
    if (! self.userIsInTheMiddleOfEnteringANumber) {
        [self updateDisplayWithText:@"0"];
    }
    NSRange range = [self.display.text rangeOfString:@"."];
    if (NSNotFound == range.location) {
        NSString *newDisplay = [[NSString alloc] initWithFormat:@"%@.", self.display.text];
        [self updateDisplayWithText:newDisplay];
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
    [self updateKeystrokesWithEquals:NO];
}

- (IBAction)changeSignPressed:(UIButton *)sender
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        NSRange minus = [self.display.text rangeOfString:@"-"];
        if (NSNotFound == minus.location) {
            NSString *newDisplay = [[NSString alloc] initWithFormat:@"-%@", self.display.text];
            [self updateDisplayWithText:newDisplay];
        }
        else {
            NSString *newDisplay = [[NSString alloc] initWithFormat:@"%@", [self.display.text substringFromIndex:1]];
            [self updateDisplayWithText:newDisplay];
        }
        [self updateKeystrokesWithEquals:NO];
    }
    else {
        [self operationPressed:sender];
    }
}

- (IBAction)operationPressed:(UIButton *)sender
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    double result = [self.brain performOperation:sender.currentTitle usingVariableValues:[self.brain variables]];
    [self updateDisplayWithText:[NSString stringWithFormat:@"%g", result]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    BOOL evaluate = YES;
    if ([@"π" isEqualToString:sender.currentTitle] || [@"e" isEqualToString:sender.currentTitle]) {
        evaluate = NO;
    }
    [self updateKeystrokesWithEquals:evaluate];
}

- (IBAction)enterPressed
{
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    [self updateKeystrokesWithEquals:NO];
}

- (IBAction)backspacePressed
{
    if (self.display.text.length > 1) {
        NSString *newDisplay = [[NSString alloc] initWithFormat:@"%@", [self.display.text substringToIndex:self.display.text.length - 1]];
        [self updateDisplayWithText:newDisplay];
    }
    else {
        [self updateDisplayWithText:@"0"];
        self.userIsInTheMiddleOfEnteringANumber = NO;
    }
}

- (IBAction)clearEntryPressed
{
    [self updateDisplayWithText:@"0"];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    if (self.userPressedVariableSET) {
        [self useDefaultButtonFunctionality];
        self.userPressedVariableSET = NO;
    }
}

- (IBAction)clearPressed
{
    // NOTE: clear does not reset variable content
    [self clearEntryPressed];
    [self.brain performOperation:@"clear" usingVariableValues:nil];
    [self updateKeystrokesWithEquals:NO];
    [self updateVariableDisplay:nil];
}

// helper method for recursive definition of variable
- (NSArray *)combinePrograms:(NSArray *)theProgram and:(NSArray *)origVariableContent forKey:(NSString *)variableKey
{
    NSArray *newProgram = [[NSArray alloc] init];
    for (int i = 0; i < [theProgram count]; i++) {
        id programElement = [theProgram objectAtIndex:i];
        if ([programElement isKindOfClass:[NSString class]]) {
            NSString *operator = (NSString *)programElement;
            if ([variableKey isEqualToString:operator]) {
                // we need to substitute using origVariableContent
                newProgram = [newProgram arrayByAddingObjectsFromArray:origVariableContent];
                continue;
            }
        }
        newProgram = [newProgram arrayByAddingObject:programElement];
    }
    return newProgram;
}

- (IBAction)variablePressed:(UIButton *)sender
{
    static int recursionLevel = 0;
    if (self.userPressedVariableSET) {
        self.userPressedVariableSET = NO;
        // the entire currently entered program gets assigned to the specified variable
        NSArray *theProgram = [self.brain program];
        if (NSNotFound != [theProgram indexOfObject:sender.currentTitle]) {
            // handle recursive variable expressions!
            NSArray *origVariableContent = [[self.brain variables] objectForKey:sender.currentTitle];
            theProgram = [self combinePrograms:theProgram and:origVariableContent forKey:sender.currentTitle];
            NSLog(@"redefined %@ to be %@", sender.currentTitle, theProgram);
        }
        // update the variable's content and change button color
        [[self brain] setVariable:sender.currentTitle withValue:theProgram];
        [self useDefaultButtonFunctionality];
        [sender setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        if (! recursionLevel) {
            [self clearPressed];
        }
        else {
            // we used a variable without first doing a SET
            // it will be set to whatever is shown in the display
            [self operationPressed:sender];
            return;
        }
    }
    else {
        //----------------------------------------
        // here a variable is being used as an operand
        NSArray *variableValue = [[self.brain variables] objectForKey:sender.currentTitle];
        if (variableValue) {
            [self operationPressed:sender];
        }
        else { // but it is an undefined variable so create it now
            [self updateDisplayWithText:@"0"];
            [self setVariablePressed];
            ++recursionLevel;
            [self variablePressed:sender];
            --recursionLevel;
        }
    }
    // now update the variable label text
    [self updateVariableDisplay:sender.currentTitle];
}

- (IBAction)setVariablePressed
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    [self useRestrictedButtonFunctionality];
    self.userPressedVariableSET = YES;
}

- (void)useDefaultButtonFunctionality
{
    // restore all disabled buttons to active
    for (UIView *view in [[self view] subviews]) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            [button setEnabled:YES];
            [button setAlpha:1.0];
        }
    }
}

- (void)useRestrictedButtonFunctionality
{
    // disable all buttons except: CLR CE A B C X Y Z
    NSSet *keepButtons = [[NSSet alloc] initWithObjects:@"CLR", @"CE", @"A", @"B", @"C", @"X", @"Y", @"Z", nil];
    for (UIView *view in [[self view] subviews]) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            if (! [keepButtons containsObject:button.currentTitle]) {
                [button setEnabled:NO];
                [button setAlpha:0.3];
            }
        }
    }
}

- (void)updateKeystrokesWithEquals:(BOOL)showResult
{
    NSString *resultString = [CalculatorBrain descriptionOfProgram:[self.brain program]];
    if (showResult) {
        resultString = [resultString stringByAppendingString:@" ="];
    }
    self.keystrokes.text = resultString;
}

@end
