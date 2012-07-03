//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Lion User on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"


@interface CalculatorViewController ()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) CalculatorBrain *brain;
@end

@implementation CalculatorViewController
@synthesize display = _display;
@synthesize keystrokes = _keystrokes;
@synthesize brain = _brain;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;

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
    [self updateKeystrokes:NO];    
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
    [self updateKeystrokes:NO];
    NSLog(@"end decimalPressed");
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
        [self updateKeystrokes:NO];
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
    double result = [self.brain performOperation:sender.currentTitle];
    self.display.text = [NSString stringWithFormat:@"%g", result];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    BOOL evaluate = YES;
    if ([@"pi" isEqualToString:sender.currentTitle] || [@"e" isEqualToString:sender.currentTitle]) {
        evaluate = NO;
    }
    [self updateKeystrokes:evaluate];
}

- (IBAction)enterPressed
{
    NSLog(@"[ENTER] pressed.");
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    [self updateKeystrokes:NO];
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
}

- (IBAction)clearPressed
{
    NSLog(@"clear");
    [self clearEntryPressed];
    [self.brain performOperation:@"clear"];
    [self updateKeystrokes:NO];
}

- (void)updateKeystrokes:(BOOL)showResult
{
    NSString *unfilteredString = [self.brain description];
    NSCharacterSet *notAllowedChars = [NSCharacterSet characterSetWithCharactersInString:@"(),\n\t\""];
    NSString *resultString = [[unfilteredString componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    resultString = [resultString stringByCompressingWhitespaceTo:@" "];
    if (showResult) {
        resultString = [resultString stringByAppendingString:@" ="];
    }
    NSLog (@"inNumber=%d keystrokes: %@", self.userIsInTheMiddleOfEnteringANumber, resultString);
    self.keystrokes.text = resultString;
}

@end
