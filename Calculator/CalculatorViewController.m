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

- (void)useDefaultButtonFunctionality;
- (void)useRestrictedButtonFunctionality;

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
    NSLog(@"got %@", sender.currentTitle);
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
    NSLog(@"decimalPressed");
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
        NSLog(@"change sign (number in progress)");
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
        NSLog(@"execute change sign operation");
        [self operationPressed:sender];
    }
}

- (IBAction)operationPressed:(UIButton *)sender
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    NSLog(@"do operation %@", sender.currentTitle);
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
    NSLog(@"[ENTER] pressed.");
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    [self updateKeystrokesWithEquals:NO];
}

- (IBAction)backspacePressed
{
    NSLog(@"backspace");
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
    NSLog(@"clear entry");
    self.display.text = @"0";
    self.userIsInTheMiddleOfEnteringANumber = NO;
    if (self.userPressedVariableSET) {
        [self useDefaultButtonFunctionality];
        self.userPressedVariableSET = NO;
    }
}

- (IBAction)clearPressed
{
    // NOTE: clear does not reset variable values
    NSLog(@"clear program stack");
    [self clearEntryPressed];
    [self.brain performOperation:@"clear" usingVariableValues:nil];
    [self updateKeystrokesWithEquals:NO];
}

- (IBAction)variablePressed:(UIButton *)sender
{
    if (self.userPressedVariableSET) {
        // the entire currently entered program gets assigned to a variable
        NSArray *variableValue = [self.brain program];
        if (NSNotFound == [variableValue indexOfObject:sender.currentTitle]) {
            self.variable.text = [self.variable.text stringByAppendingString:@"  "];
            [[self brain] setVariable:sender.currentTitle withValue:variableValue];
            [self useDefaultButtonFunctionality];
            self.variable.text = [self.brain getAllVariableSubPrograms];
        }
        else {
            NSLog(@"ERROR: recursive variable value");
        }
        [self clearPressed];
    }
    else {
        NSArray *variableValue = [[self.brain variables] objectForKey:sender.currentTitle];
        if (variableValue) {
            [self operationPressed:sender];
        }
        else {
            NSLog(@"the variable %@ is UNASSIGNED", sender.currentTitle);
        }
    }
}

- (IBAction)setVariablePressed
{
    NSLog(@"SET");
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    [self useRestrictedButtonFunctionality];
    self.userPressedVariableSET = YES;
}

- (void)useDefaultButtonFunctionality
{
    NSLog(@"restore all disabled buttons to active");
}

- (void)useRestrictedButtonFunctionality
{
    NSLog(@"disable all buttons except: CLR CE A B C X Y Z");
}

- (void)updateKeystrokesWithEquals:(BOOL)showResult
{
    NSString *resultString = [CalculatorBrain descriptionOfProgram:[self.brain program]];
    if (showResult) {
        resultString = [resultString stringByAppendingString:@" ="];
    }
    NSLog (@"inNumber=%d keystrokes: %@", self.userIsInTheMiddleOfEnteringANumber, resultString);
    self.keystrokes.text = resultString;
}

@end
