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

@synthesize history = _history;
@synthesize display = _display;
@synthesize variables = _variables;
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
    [self setHistory:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    // we don't want to see the navigation bar for the main screen
	[self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    // but we do want to see the navigation bar in sub views
	[self.navigationController setNavigationBarHidden:NO animated:YES];
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

- (void)updateVariablesAndHistoryUsingInfixWithEquals:(BOOL)showEquals withKeypress:(NSString *)variableKeypress
{
    NSString *resultString = [[CalculatorBrain descriptionOfProgram:[self.brain program]] copy];
    if ([resultString isEqualToString:@"ERROR"]) {
        [self disableAllButtonsExceptCLR_backspace];
        resultString = @"";
    }
    else {
        if (showEquals) {
            resultString = [resultString stringByAppendingString:@" ="];
        }
    }
    NSLog(@"HISTORY=%@", resultString);
    self.history.text = [resultString copy];
    NSSet *variablesUsed = [CalculatorBrain variablesUsedInProgram:[self.brain program]];
    NSMutableSet *programVariablesUsed = [[NSMutableSet alloc] initWithSet:variablesUsed copyItems:YES];
    if (variableKeypress) {
        [programVariablesUsed addObject:[NSString stringWithFormat:@"%@", variableKeypress]];
    }
    // next update the variables.. show all defined variables
    NSOrderedSet *allVariables = [[NSOrderedSet alloc] initWithObjects:@"A", @"B", @"C", @"X", @"Y", @"Z", nil];
    NSString *separator = @",  ";
    NSString *varValues = @"";
    NSString *key;
    for (key in allVariables) {
        NSDictionary *subProgram = [[self.brain variables] objectForKey:key];
        if (subProgram) {
            NSString *subValue = [CalculatorBrain descriptionOfProgram:subProgram];
            if ((! [@"0" isEqualToString:subValue]) || ([programVariablesUsed containsObject:key]))
            {
                // show variables that are used or are non-zero (but don't show unused with value zero)
                varValues = [varValues stringByAppendingString:[NSString stringWithFormat:@"%@=%@%@", key, subValue, separator]];
            }
        }
    }
    if ([varValues hasSuffix:separator]) {
        // strip trailing comma
        varValues = [varValues substringToIndex:[varValues length] - [separator length]];
    }
    resultString = [NSString stringWithString:varValues];
    NSLog(@"VARIABLES=%@", resultString);
    self.variables.text = [resultString copy];
}

- (IBAction)digitPressed:(UIButton *)sender
{
    if (! self.userIsInTheMiddleOfEnteringANumber) {
        [self updateDisplayWithText:@"0"];
    }
    NSString *newDisplay = [[NSString alloc] initWithFormat:@"%@%@", self.display.text, sender.currentTitle];
    [self updateDisplayWithText:newDisplay];
    self.userIsInTheMiddleOfEnteringANumber = YES;
    [self updateVariablesAndHistoryUsingInfixWithEquals:NO withKeypress:nil];    
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
    [self updateVariablesAndHistoryUsingInfixWithEquals:NO withKeypress:nil];
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
        [self updateVariablesAndHistoryUsingInfixWithEquals:NO withKeypress:nil];
    }
    else {
        [self operationPressed:sender];
        [self updateVariablesAndHistoryUsingInfixWithEquals:YES withKeypress:nil];
    }
}

- (IBAction)operationPressed:(UIButton *)sender
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    NSLog(@"operationPressed=%@", sender.currentTitle);
    if ([@"yⁿ" isEqualToString:sender.currentTitle]) {
        double lastCalculation = [CalculatorBrain lastDisplayResult];
        self.display.text = [NSString stringWithFormat:@"%g", lastCalculation];
    }
    double result = [self.brain performOperation:sender.currentTitle usingVariableValues:[self.brain variables]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    if (NAN == result) {
        [self disableAllButtonsExceptCLR_backspace];
        return;
    }
    [self updateDisplayWithText:[NSString stringWithFormat:@"%g", result]];
    BOOL evaluate = YES;
    if ([@"π" isEqualToString:sender.currentTitle] || [@"e" isEqualToString:sender.currentTitle]) {
        evaluate = NO;
    }
    [self updateVariablesAndHistoryUsingInfixWithEquals:evaluate withKeypress:nil];
}

- (IBAction)enterPressed
{
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    [self updateVariablesAndHistoryUsingInfixWithEquals:NO withKeypress:nil];
}

- (IBAction)backspacePressed
{
    if (self.display.text.length > 1
     && ! [@"ERROR" isEqualToString:self.display.text]
     && ! [@"nan" isEqualToString:self.display.text]
     && ! [@"inf" isEqualToString:self.display.text]
     && ! [@"-inf" isEqualToString:self.display.text]
    ) {
        NSString *newDisplay = [[NSString alloc] initWithFormat:@"%@", [self.display.text substringToIndex:self.display.text.length - 1]];
        if ([@"-" isEqualToString:newDisplay]) {
            newDisplay = @"0";
        }
        [self updateDisplayWithText:newDisplay];
    }
    else {
        if (! self.userIsInTheMiddleOfEnteringANumber) {
            double result = [self.brain performOperation:@"backspace" usingVariableValues:[self.brain variables]];
            [self updateDisplayWithText:[NSString stringWithFormat:@"%g", result]];
            [self updateVariablesAndHistoryUsingInfixWithEquals:NO withKeypress:nil];
        }
        else {
            [self updateDisplayWithText:@"0"];
            self.userIsInTheMiddleOfEnteringANumber = NO;
        }
    }
    [self useDefaultButtonFunctionality];
}

- (IBAction)clearEntryPressed
{
    [self updateDisplayWithText:@"0"];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    if (self.userPressedVariableSET) {
        self.userPressedVariableSET = NO;
    }
    [self useDefaultButtonFunctionality];
    // dump content of CalculatorBrain for debug
    NSLog(@"------------------------------------");
    NSLog(@"VARIABLES=%@", [self.brain variables]);
    NSLog(@"PROGRAM=%@", [self.brain program]);
    NSLog(@"------------------------------------");
}

- (IBAction)clearPressed
{
    // NOTE: clear does not reset variable content
    [self clearEntryPressed];
    [self.brain performOperation:@"clear" usingVariableValues:nil];
    [self updateVariablesAndHistoryUsingInfixWithEquals:NO withKeypress:nil];
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

- (BOOL)variableLoopsEquations:(NSString *)operation usingVariableValues:(NSDictionary *)myVariableValues
{
    // detect self-referencing variable equations
    NSArray *program = [myVariableValues objectForKey:operation];
    NSMutableSet *allVariablesUsed = nil;
    if (program) {
        allVariablesUsed = [[CalculatorBrain variablesUsedInProgram:program] mutableCopy];
        BOOL checkAgain = YES;
        while (checkAgain) {
            checkAgain = NO;
            for (NSString *variable in [allVariablesUsed copy]) {
                NSArray *subProgram = [myVariableValues objectForKey:variable];
                if (subProgram) {
                    NSSet *subVariablesUsed = [CalculatorBrain variablesUsedInProgram:subProgram];
                    if ([subVariablesUsed count]) {
                        int oldCount = [allVariablesUsed count];
                        [allVariablesUsed unionSet:subVariablesUsed];
                        if (oldCount != [allVariablesUsed count]) { // anything changed?
                            checkAgain = YES;
                        }
                    }
                }
            }
        }
    }
    BOOL loops = [allVariablesUsed containsObject:operation];
    if (loops) {
        NSLog(@"WARNING: loop found for operation %@ in %@", operation, myVariableValues);
    }
    return loops;
}

- (IBAction)variablePressed:(UIButton *)sender
{
    static int recursionLevel = 0;
    if (self.userPressedVariableSET) {
        self.userPressedVariableSET = NO;
        NSArray *theProgram = [self.brain program];
        // the entire currently entered program gets assigned to the specified variable
        if (NSNotFound != [theProgram indexOfObject:sender.currentTitle]) {
            // handle recursive variable expressions!
            NSArray *origVariableContent = [[self.brain variables] objectForKey:sender.currentTitle];
            theProgram = [self combinePrograms:theProgram and:origVariableContent forKey:sender.currentTitle];
            NSLog(@"redefined %@ to be %@", sender.currentTitle, theProgram);
        }
        // check for circular references that can't be resolved
        NSMutableDictionary *testVariables = [[self.brain variables] mutableCopy];
        [testVariables removeObjectForKey:sender.currentTitle];
        [testVariables setValue:theProgram forKey:sender.currentTitle];
        if (([self variableLoopsEquations:sender.currentTitle usingVariableValues:testVariables])
         || (! [[self brain] setVariable:sender.currentTitle withValue:theProgram])) {
            [self disableAllButtonsExceptCLR_backspace];
            return;
        }
        // push the variable just set onto the display stack for convenience now
        [self variablePressed:sender];
        // enable buttons and change used variables' button color
        [self useDefaultButtonFunctionality];
        if (! recursionLevel) {
            [self clearPressed];
        }
    }
    else {
        if (self.userIsInTheMiddleOfEnteringANumber) {
            [self enterPressed];
        }
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
    [self updateVariablesAndHistoryUsingInfixWithEquals:NO withKeypress:sender.currentTitle];
}

- (IBAction)setVariablePressed
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    // disable all buttons except: CLR CE A B C X Y Z
    NSSet *keepButtons = [[NSSet alloc] initWithObjects:@"CLR", @"CE", @"A", @"B", @"C", @"X", @"Y", @"Z", nil];
    [self useRestrictedButtonFunctionality:keepButtons];
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

- (IBAction)graphXY
{
    [self performSegueWithIdentifier:@"ShowGraphView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowGraphView"]) {
        [segue.destinationViewController setBrain:self.brain];
    }
}

- (void)disableAllButtonsExceptCLR_backspace
{
    self.history.text = @"";
    [self useDefaultButtonFunctionality];
    NSSet *keepButtons = [[NSSet alloc] initWithObjects:@"CLR", @"⇦", nil];
    [self useRestrictedButtonFunctionality:keepButtons];
    [self updateDisplayWithText:@"ERROR"];
}

- (void)useRestrictedButtonFunctionality:(NSSet *) keepButtons
{
    // disable specified buttons
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

@end
