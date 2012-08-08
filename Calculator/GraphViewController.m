//
//  GraphViewController.m
//  Calculator
//
//  Created by Lee Hounshell on 7/14/12.
//  Copyright (c) 2012 Harlie All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"
#import "PopupCalculatorViewController.h"
#import "CalculatorProgramsTableViewController.h"


@interface GraphViewController () <CalculatorProgramsTableViewControllerDelegate>

@property (nonatomic, weak) IBOutlet GraphView *graphView;
@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property (nonatomic) UIInterfaceOrientation lastReportedOrientation;
@property (nonatomic, strong) UIPopoverController *myPopoverController;
@property (nonatomic, strong) UIBarButtonItem *calculatorButton;
@property (nonatomic) Boolean setupComplete;

@end


@implementation GraphViewController

@synthesize delegate = _delegate;
@synthesize graphView = _graphView;
@synthesize toolbar = _toolbar;
@synthesize lastReportedOrientation = _lastReportedOrientation;
@synthesize myPopoverController = _myPopoverController;
@synthesize calculatorButton = _calculatorButton;
@synthesize setupComplete = _setupComplete;


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    self.lastReportedOrientation = interfaceOrientation;
    if (! UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationIsPortrait(interfaceOrientation); // iPhone logic
    }
    if (self.delegate && self.setupComplete) {
        [self setupSplitViewBarButtonItemAtPosition:0]; // setup the calculator button, as appropriate
    }
    return YES; // iPad logic
}

- (void)setup
{
    //NSLog(@"GraphViewController setup");
    self.lastReportedOrientation = UIDeviceOrientationPortrait; // careful, iOS doesn't properly report initial orientation
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
    // Do any additional setup after loading the view.
    self.setupComplete = YES;
    [self.graphView moveToOriginWithDefaultScale];
    [self doGraph];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (BOOL) splitViewController:(UISplitViewController *)svc
    shouldHideViewController:(UIViewController *)vc
               inOrientation:(UIInterfaceOrientation)orientation
{
    NSLog(@"===> shouldHideViewController <===");
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    // tell the ViewController to display the button item.
    NSLog(@"===> GraphViewController splitViewController willHideViewController <===");
    [self showSplitViewCalculatorBarButton:YES];
    self.myPopoverController = pc;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // remove the bar button item as the hidden view will now be shown on right side
    NSLog(@"===> GraphViewController splitViewController willShowViewController <===");
    [self showSplitViewCalculatorBarButton:NO];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    NSLog(@"GraphViewController ROTATING");
    [self dismissPopover];
}


//----------------------------------------------------------------------------

- (id<CalculationControlProtocol>)brain;
{
    return [self.delegate brain];
}

- (void)setDelegate:(id)delegate
{
    if (! _delegate) {
        _delegate = delegate;
    }
    else {
        if (delegate != _delegate) {
            id old_delegate = _delegate;
            id<CalculationControlProtocol>theBrain = [old_delegate brain];
            id program = [theBrain program];
            id variables = [theBrain variables];
            _delegate = delegate;
            [self.delegate setProgram:program andVariables:variables];
        }
    }
}

- (void)setSplitViewBarButtonTitle:(NSString *)newTitle
{
    UILabel *newTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    newTitleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    newTitleLabel.textAlignment = UITextAlignmentCenter;
    newTitleLabel.backgroundColor = [UIColor clearColor];
    newTitleLabel.shadowOffset = CGSizeMake(0, 1);
    newTitleLabel.textColor = [UIColor grayColor];
    newTitleLabel.text = newTitle;
    newTitleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    UIBarButtonItem *toolBarTitle = [[UIBarButtonItem alloc] initWithCustomView:newTitleLabel];
    // toolbar indexes: 0=Calculator 1=spacer 2=TITLE 3=spacer 4=Favorites
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    int titleIndex = 2;
    [toolbarItems replaceObjectAtIndex:titleIndex withObject:toolBarTitle];
    NSArray *newToolbar = [toolbarItems copy];
    [self.toolbar setItems:newToolbar];
}

- (void)setGraphView:(GraphView *)graphView
{
    _graphView = graphView;
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc]
        initWithTarget:self.graphView action:@selector(pinchHandler:)]];
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc]
        initWithTarget:self.graphView action:@selector(panHandler:)]];
    // enable tap gestures using the GraphView tap: handler
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] 
                                      initWithTarget:self.graphView 
                                      action:@selector(tapHandler:)];
    tapper.numberOfTapsRequired = 3; // tripple tap
    [self.graphView addGestureRecognizer:tapper];
    self.graphView.delegate = self;
}

- (BOOL)isValidProgram
{
    return ! (([[self brain] program] == nil)
              || ([[[self brain] program] lastObject] == nil));
}

- (void)doGraph
{
    if (! self.setupComplete) return;
    NSLog(@"GraphViewController doGraph");
    NSString *newTitle = @"Graph";
    NSString *description = [[self brain] description];
    if (description && ! [description isEqualToString:@""]) {
        newTitle = [NSString stringWithFormat:@"Y=%@", description];
    }
    if (! UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSLog(@"iPhone: graph title=%@", newTitle);
        self.navigationItem.title = newTitle;
    }
    else {
        NSLog(@"iPad: splitView newTitle=%@", newTitle);
        [self setSplitViewBarButtonTitle:newTitle];
        if (self.delegate) {
            [self setupSplitViewBarButtonItemAtPosition:0]; // setup the back button, if needed
        }
    }
    [self.graphView setNeedsDisplay]; // draw the graph
}

- (double)calculateYResultForXValue:(CGFloat)x requestor:(GraphView *)graphView
{
    NSArray *programX = [[[[self brain] variables] objectForKey:@"X"] copy];
    NSArray *valueX = [[NSArray alloc] initWithObjects:[NSNumber numberWithDouble:(double)x], nil];
    [[self brain] setVariable:@"X" withValue:valueX]; // we temporarially replace X with the plot value
    NSArray *myProgram = [[self brain] program];
    NSDictionary *myVariables = [[self brain] variables];
    double result = [CalculatorBrain runProgram:myProgram usingVariableValues:myVariables];
    [[self brain] setVariable:@"X" withValue:programX]; // put back the original X program
    //NSLog(@"For x=%g calculateYResultForXValue=%g", x, result);
    return result;
}

- (void)setupSplitViewBarButtonItemAtPosition:(int)index
{
    UIInterfaceOrientation  orientation = [UIDevice currentDevice].orientation;
    // it seems very difficult to always get correct orientation when the program begins
    if (UIInterfaceOrientationIsPortrait(orientation)
     || UIDeviceOrientationIsPortrait(self.lastReportedOrientation)) {
        [self showSplitViewCalculatorBarButton:YES];
    }
    else {
        [self showSplitViewCalculatorBarButton:NO];
    }
}

- (void)showSplitViewCalculatorBarButton:(BOOL)displayIt
{
    if (! self.setupComplete) return;
    // toolbar indexes: 0=Calculator 1=spacer 2=TITLE 3=spacer 4=Favorites
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    int calculatorIndex = 0;
    if (displayIt) {
        [self setCalculatorButton:[[UIBarButtonItem alloc]
                                   initWithTitle:@"Calculator"
                                   style: UIBarButtonItemStyleBordered
                                   target: self
                                   action: @selector(DoCalculatorPopover:)]];
        [toolbarItems replaceObjectAtIndex:calculatorIndex withObject:self.calculatorButton];
    }
    else {
        UIBarButtonItem *fixedButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        [toolbarItems replaceObjectAtIndex:calculatorIndex withObject:fixedButton];
    }
    NSArray *newToolbar = [toolbarItems copy];
    [self.toolbar setItems:newToolbar];
}

- (void)DoCalculatorPopover:(id)sender // from a UIBarButtonItem
{
    NSLog(@"DoCalculatorPopover <---------");
    PopupCalculatorViewController *masterVC = [self.storyboard instantiateViewControllerWithIdentifier:@"popupCalculator"];
    [masterVC setGraphViewCtl:self];
    
    self.myPopoverController = [[UIPopoverController alloc] initWithContentViewController:masterVC];

    [self.myPopoverController presentPopoverFromBarButtonItem:[self calculatorButton]
                                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                                     animated:YES];
   
    NSMutableDictionary *commLinkup = [[NSMutableDictionary alloc] init];
    [commLinkup setValue:self forKey:@"GraphViewController"];
    [commLinkup setValue:[self brain] forKey:@"CalculatorBrain"];
    [masterVC remakeTheCalculator:commLinkup];
}

- (void)dismissPopover
{
    if (UIInterfaceOrientationIsPortrait(self.lastReportedOrientation))
    {
        NSLog(@"dismissPopover - portrait mode - DISPLAY the toolbar button");
        [self showSplitViewCalculatorBarButton:YES];
    }
    else {
        NSLog(@"dismissPopover - landscape mode - HIDE the toolbar button");
        [self showSplitViewCalculatorBarButton:NO];
    }
    if ([self.myPopoverController isPopoverVisible]) {
        [self.myPopoverController dismissPopoverAnimated:YES];
        [self.myPopoverController.delegate popoverControllerDidDismissPopover:self.myPopoverController];
        
        CalculatorViewController *masterVC = (CalculatorViewController *)[self.splitViewController.viewControllers objectAtIndex:0];
        [masterVC setGraphViewCtl:self];
        NSMutableDictionary *commLinkup = [[NSMutableDictionary alloc] init];
        [commLinkup setValue:self forKey:@"GraphViewController"];
        [commLinkup setValue:[self brain] forKey:@"CalculatorBrain"];
        NSLog(@"Transfer the program and variables to the CalculatorViewController");
        [masterVC remakeTheCalculator:commLinkup];
    }
}

//---------------------------
// from lecture 9

- (IBAction)addToFavorites:(id)sender
{
    NSLog(@"addToFavorites");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favorites = [[defaults objectForKey:FAVORITES_KEY] mutableCopy];
    if (!favorites) {
        favorites = [NSMutableArray array];
    }
    if ([self isValidProgram]) {
        id<CalculationControlProtocol> theBrain = [self brain];
        NSDictionary *programWithVariables = [[NSDictionary alloc] initWithObjectsAndKeys:
                                              [theBrain program], @"program",
                                              [theBrain variables], @"variables", nil];
        BOOL alreadyAdded = NO;
        for (NSDictionary *someFavorite in favorites) {
            if ([someFavorite isEqualToDictionary:programWithVariables]) {
                alreadyAdded = YES;
                break;
            }
        }
        if (! alreadyAdded) {
            [favorites addObject:programWithVariables];
            [defaults setObject:favorites forKey:FAVORITES_KEY];
            [defaults synchronize];
            NSLog(@"added graph to favorites.");
        }
        else {
            NSLog(@"this program is already in favorites");
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"GraphViewController prepareForSegue %@", segue.identifier);
    if ([segue.identifier isEqualToString:@"Show Favorite Graphs"]) {
        NSArray *programs = [[NSUserDefaults standardUserDefaults] objectForKey:FAVORITES_KEY];
        [segue.destinationViewController setPrograms:programs];
        [segue.destinationViewController setDelegate:self];
    }
    else if ([segue.identifier isEqualToString:@"Handle Calculator Popover"]) {
        NSMutableDictionary *commLinkup = [[NSMutableDictionary alloc] init];
        [commLinkup setValue:self forKey:@"GraphViewController"];
        [commLinkup setValue:[self brain] forKey:@"CalculatorBrain"];
        [segue.destinationViewController remakeTheCalculator:commLinkup];
    }
    else {
        NSLog(@"ERROR: unknown segue %@", segue.identifier);
    }
}

- (void)calculatorProgramsTableViewController:(CalculatorProgramsTableViewController *)sender choseProgramAndVariables:(id)programAndVariablesDict
{
    if ([programAndVariablesDict isKindOfClass:[NSDictionary class]]) {
        NSDictionary *aProgramWithVariables = (NSDictionary *)programAndVariablesDict;
        NSArray *aProgram = [aProgramWithVariables objectForKey:@"program"];
        NSDictionary *someVariables = [aProgramWithVariables objectForKey:@"variables"];
        [self.delegate setProgram:aProgram andVariables:someVariables];
    }
}

@end
