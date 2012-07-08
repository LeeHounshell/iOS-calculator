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

- (IBAction)digitPressed:(UIButton *)sender
{
    if (! self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = @"0";
    }
    self.display.text = [self.display.text stringByAppendingString:sender.currentTitle];
    if ('0' == [self.display.text characterAtIndex:0]) {  // leading zeroes?
        self.display.text = [self.display.text substringFromIndex:1];
    }
    self.userIsInTheMiddleOfEnteringANumber = YES;
    [self updateKeystrokesWithEquals:NO];    
}

- (IBAction)decimalPressed
{
    if (! self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = @"0";
    }
    NSRange range = [self.display.text rangeOfString:@"."];
    if (range.location == NSNotFound) {
        self.display.text = [self.display.text stringByAppendingString:@"."];
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
    [self updateKeystrokesWithEquals:NO];
}

- (IBAction)changeSignPressed:(UIButton *)sender
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        NSRange minus = [self.display.text rangeOfString:@"-"];
        if (minus.location == NSNotFound) {
            self.display.text = [@"-" stringByAppendingString:self.display.text];
        }
        else {
            self.display.text = [self.display.text substringFromIndex:1];
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
    self.display.text = [NSString stringWithFormat:@"%g", result];
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
        self.display.text = [self.display.text substringToIndex:self.display.text.length - 1];
    }
    else {
        self.display.text = @"0";
        self.userIsInTheMiddleOfEnteringANumber = NO;
    }
}

- (IBAction)clearEntryPressed
{
    self.display.text = @"0";
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
    self.variable.text = @"";
}

- (IBAction)variablePressed:(UIButton *)sender
{
    if (self.userPressedVariableSET) {
        // the entire currently entered program gets assigned to a variable
        NSArray *theProgram = [self.brain program];
        if (NSNotFound == [theProgram indexOfObject:sender.currentTitle]) {
            [[self brain] setVariable:sender.currentTitle withValue:theProgram];
            [self useDefaultButtonFunctionality];
            [sender setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        }
        else {
            NSLog(@"ERROR: recursive variable content");
        }
        [self clearPressed];
    }
    else {
        NSArray *variableValue = [[self.brain variables] objectForKey:sender.currentTitle];
        if (variableValue) {
            [self operationPressed:sender];
        }
        else { // undefined variable
            self.display.text = @"0";
            [self enterPressed];
        }
        // now update the variable label text
        NSSet *variablesUsed = [CalculatorBrain variablesUsedInProgram:[self.brain program]];
        NSMutableSet *allVariablesUsed = [[NSMutableSet alloc] initWithSet:variablesUsed copyItems:YES];
        [allVariablesUsed addObject:[NSString stringWithFormat:@"%@", sender.currentTitle]];
        NSString *varValues = @"";
        NSString *key;
        for (key in allVariablesUsed) {
            NSArray *subProgram = [[self.brain variables] objectForKey:key];
            if (subProgram) {
                varValues = [varValues stringByAppendingString:[NSString stringWithFormat:@"   %@=%@", key, [CalculatorBrain descriptionOfProgram:subProgram]]];
            }
        }
        self.variable.text = varValues;
    }
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
            [button setAlpha:1];
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
