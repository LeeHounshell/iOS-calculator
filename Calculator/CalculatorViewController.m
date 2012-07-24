//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Lee Hounshell on 5/29/12.
//  Copyright (c) 2012 H.A.R.L.I.E. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "GraphViewController.h"

@interface CalculatorViewController ()

@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL userPressedVariableSET;
@property (weak, nonatomic) IBOutlet UILabel *variables;
@property (nonatomic, strong) CalculatorBrain *theBrain;

@end


@implementation CalculatorViewController

@synthesize history = _history;
@synthesize display = _display;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize userPressedVariableSET = _userPressedVariableSET;
@synthesize theBrain = _theBrain;
@synthesize variables = _variables;


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (! UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationIsPortrait(interfaceOrientation); // iPhone logic
    }
    return YES; // iPad logic
}

- (void)setup
{
    //NSLog(@"CalculatorViewController setup");
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //NSLog(@"CalculatorViewController viewDidLoad");
    [self setTheBrain:nil];
    id theGraphViewC = [self splitViewGraphViewController];
    if (theGraphViewC) {
        [theGraphViewC setDelegate:self];
        [[self splitViewGraphViewController] doGraph:self]; // initialize the GraphView
    }
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 500.0);
}

- (void)viewDidUnload
{
    [self setDisplay:nil];
    [self setHistory:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // we don't want to see the navigation bar for the main screen
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // but we do want to see the navigation bar in sub views
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    NSLog(@"CalculatorViewController ROTATING");
}

//----------------------------------------------------------------------------


- (CalculatorBrain *)theBrain
{
    if (! _theBrain)
    {
        _theBrain = [[CalculatorBrain alloc] init];
    }
    return _theBrain;
}

- (void)setTheBrain:(CalculatorBrain *)theBrain
{
    if (theBrain && _theBrain != theBrain) {
        _theBrain = theBrain;
    }
    else if (! theBrain) {
        _theBrain = nil;
        _theBrain = [self theBrain];
    }
    id theGraphViewC = [self splitViewGraphViewController];
    [theGraphViewC doGraph:self];
}

- (id)brain
{
    return self.theBrain;
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
    NSString *resultString = [[CalculatorBrain descriptionOfProgram:[self.theBrain program]] copy];
    if ([resultString isEqualToString:@"ERROR"]) {
        [self disableAllButtonsExceptCLR_backspace];
        resultString = @"";
    }
    else {
        if (showEquals) {
            resultString = [resultString stringByAppendingString:@" ="];
        }
    }
    //NSLog(@"HISTORY=%@", resultString);
    self.history.text = [resultString copy];
    NSSet *variablesUsed = [CalculatorBrain variablesUsedInProgram:[self.theBrain program]];
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
        NSDictionary *subProgram = [[self.theBrain variables] objectForKey:key];
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
    //NSLog(@"VARIABLES=%@", resultString);
    self.variables.text = [resultString copy];
}

- (IBAction)digitPressed:(UIButton *)sender
{
    if (! self.userIsInTheMiddleOfEnteringANumber || [self errorCondition]) {
        [self updateDisplayWithText:@"0"];
    }
    NSString *newDisplay = [[NSString alloc] initWithFormat:@"%@%@", self.display.text, sender.currentTitle];
    [self updateDisplayWithText:newDisplay];
    self.userIsInTheMiddleOfEnteringANumber = YES;
    [self updateVariablesAndHistoryUsingInfixWithEquals:NO withKeypress:nil];    
}

- (IBAction)decimalPressed
{
    if (! self.userIsInTheMiddleOfEnteringANumber || [self errorCondition]) {
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
    double result = [self.theBrain performOperation:sender.currentTitle usingVariableValues:[self.theBrain variables]];
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
    if ([self errorCondition]) {
        [self clearPressed];
    }
    [self.theBrain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    [self updateVariablesAndHistoryUsingInfixWithEquals:NO withKeypress:nil];
}

- (BOOL)errorCondition
{
    if (! [@"ERROR" isEqualToString:self.display.text]
     && ! [@"nan" isEqualToString:self.display.text]
     && ! [@"inf" isEqualToString:self.display.text]
     && ! [@"-inf" isEqualToString:self.display.text]
        ) {
        return NO;
    }
    return YES;
}

- (IBAction)backspacePressed
{
     if (self.userIsInTheMiddleOfEnteringANumber && self.display.text.length > 1 && ! [self errorCondition]) {
        NSString *newDisplay = [[NSString alloc] initWithFormat:@"%@", [self.display.text substringToIndex:self.display.text.length - 1]];
        if ([@"-" isEqualToString:newDisplay]) {
            newDisplay = @"0";
        }
        [self updateDisplayWithText:newDisplay];
    }
    else {
        if (! self.userIsInTheMiddleOfEnteringANumber) {
            double result = [self.theBrain performOperation:@"backspace" usingVariableValues:[self.theBrain variables]];
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
}

- (IBAction)clearPressed
{
    // NOTE: clear does not reset variable content
    [self clearEntryPressed];
    [self.theBrain performOperation:@"clear" usingVariableValues:nil];
    [self updateVariablesAndHistoryUsingInfixWithEquals:NO withKeypress:nil];
    NSMutableDictionary *keepVariables = [[self.theBrain variables] mutableCopy];
    [self setTheBrain:nil];
    for (NSString *key in keepVariables) {
        id theProgram = [keepVariables objectForKey:key];
        [self.theBrain setVariable:key withValue:theProgram];
    }
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
        NSArray *theProgram = [self.theBrain program];
        // the entire currently entered program gets assigned to the specified variable
        if (NSNotFound != [theProgram indexOfObject:sender.currentTitle]) {
            // handle recursive variable expressions!
            NSArray *origVariableContent = [[self.theBrain variables] objectForKey:sender.currentTitle];
            theProgram = [self combinePrograms:theProgram and:origVariableContent forKey:sender.currentTitle];
            NSLog(@"redefined %@ to be %@", sender.currentTitle, theProgram);
        }
        // check for circular references that can't be resolved
        NSMutableDictionary *testVariables = [[self.theBrain variables] mutableCopy];
        [testVariables removeObjectForKey:sender.currentTitle];
        [testVariables setValue:theProgram forKey:sender.currentTitle];
        if (([self variableLoopsEquations:sender.currentTitle usingVariableValues:testVariables])
         || (! [self.theBrain setVariable:sender.currentTitle withValue:theProgram])) {
            [self disableAllButtonsExceptCLR_backspace];
            return;
        }
        // push the variable just set onto the display stack for convenience now
        [self variablePressed:sender]; // recursive
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
        NSArray *variableValue = [[self.theBrain variables] objectForKey:sender.currentTitle];
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

- (id)splitViewGraphViewController
{
    // determine if we are in the split-view
    id vc = [self.splitViewController.viewControllers lastObject];
    if ([vc isKindOfClass:[GraphViewController class]]) {
        [vc setDelegate:self];
    }
    else {
        vc = nil;
    }
    return vc;
}

- (IBAction)graphXY
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    NSString *description = [CalculatorBrain descriptionOfProgram:[self.theBrain program]];
    NSRange range = [description rangeOfString:@"?"];
    if (range.length || [self errorCondition]) {
        [self setTheBrain:nil];
        [self updateDisplayWithText:@"ERROR"];
    }
    else {
        if (! UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            NSLog(@"iPhone controller so we need to segue to the GraphView");
            [self performSegueWithIdentifier:@"ShowGraphView" sender:self];
        }
        else {
            NSLog(@"iPad controller, so just send a message to update the graph");
            [[self splitViewGraphViewController] doGraph:self];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowGraphView"]) {
        [segue.destinationViewController doGraph:self];
    }
}

@end
