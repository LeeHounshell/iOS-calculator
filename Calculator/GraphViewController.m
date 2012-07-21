//
//  GraphViewController.m
//  Calculator
//
//  Created by Lee Hounshell on 7/14/12.
//  Copyright (c) 2012 H.A.R.L.I.E. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"

@interface GraphViewController ()

@property (nonatomic, weak) IBOutlet GraphView *graphView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic) UIInterfaceOrientation lastReportedOrientation;

@end



@implementation GraphViewController

@synthesize delegate = _delegate;
@synthesize brain = _brain;
@synthesize graphView = _graphView;
@synthesize toolbar = _toolbar;
@synthesize myPopoverController = _myPopoverController;
@synthesize lastReportedOrientation = _lastReportedOrientation;


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    self.lastReportedOrientation = [UIDevice currentDevice].orientation;
    NSString *orientation =  UIInterfaceOrientationIsPortrait(self.lastReportedOrientation) ? @"PORTRAIT" : @"LANDSCAPE";
    //NSLog(@"GraphViewController shouldAutorotateToInterfaceOrientation orientation=%@", orientation);
    if (! UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationIsPortrait(interfaceOrientation); // iPhone logic
    }
    if (self.delegate) {
        BOOL displayIt = [@"PORTRAIT" isEqualToString:orientation];
        [self setupSplitViewBarButtonItemAtPosition:0 doDisplay:displayIt]; // setup the back button, if needed
    }
    return YES; // iPad logic
}

- (void)setup
{
    NSLog(@"GraphViewController setup");
    [self setBrain:nil]; // NOTE: nil will display "Graph" in the title
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

- (id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if (! [detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]) {
        detailVC = nil;
    }
    return detailVC;
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    // if we implement the protocol then allow the left side to hide in portrait mode
    BOOL rc = [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(self.lastReportedOrientation) : NO;
    NSLog(@"LEE: GraphViewController splitViewController shouldHideViewController.  rc=%d", rc);
    return rc;
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    // tell the ViewController to display the button item.
    [[self splitViewBarButtonItemPresenter] setupSplitViewBarButtonItemAtPosition:0 doDisplay:YES];
    NSLog(@"LEE: GraphViewController splitViewController willHideViewController");
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // remove the bar button item as the hidden view will now be shown on right side
    [[self splitViewBarButtonItemPresenter] setupSplitViewBarButtonItemAtPosition:0 doDisplay:NO];
    NSLog(@"LEE: GraphViewController splitViewController willShowViewController");
}


//----------------------------------------------------------------------------


- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem atPosition:(int)index
{
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    if (splitViewBarButtonItem) {
        // indexes: 0=Calculator 1=spacer 2=TITLE 3=spacer
        [toolbarItems replaceObjectAtIndex:index withObject:splitViewBarButtonItem];
        self.toolbar.items = toolbarItems;
    }
}

- (void)setupSplitViewBarButtonItemAtPosition:(int)index doDisplay:(BOOL)displayItHint
{
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    NSObject *item = [toolbarItems objectAtIndex:index];
    BOOL isPortrait = UIInterfaceOrientationIsPortrait(self.interfaceOrientation);
    //NSLog(@"FOOBAR INITIAL ORIENTATION: displayItHint=%d isPortrait=%d", displayItHint, isPortrait);
    if (displayItHint || isPortrait) {
        if (item && [item isKindOfClass:[UIBarButtonItem class]]) {
            UIBarButtonItem *button = (UIBarButtonItem *)item;
            if (0 == index) {
                button = [[UIBarButtonItem alloc]
                          initWithTitle:@"Calculator"
                          style: UIBarButtonItemStyleBordered
                          target: self
                          action: @selector(DoCalculatorPopover)];
            }
            [self setSplitViewBarButtonItem:button atPosition:index];
        }
    }
    else {
        // hide the back-button
        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
        NSObject *item = [toolbarItems objectAtIndex:index];
        if (item && [item isKindOfClass:[UIBarButtonItem class]]) {
            UIBarButtonItem *button = (UIBarButtonItem *)item;
            if (0 == index) {
                button = [[UIBarButtonItem alloc] init];
            }
            [self setSplitViewBarButtonItem:button atPosition:index];
        }
    }
}

- (void)DoCalculatorPopover // segway from a UIBarButtonItem
{
    NSLog(@"DoCalculatorPopover");
    UIViewController *theViewC = (UIViewController *)self.delegate;
    [self.myPopoverController presentPopoverFromRect:theViewC.view.frame 
                                              inView:self.view 
                            permittedArrowDirections:UIPopoverArrowDirectionDown
                                            animated:YES];    
}

- (void)setBrain:(CalculatorBrain *)brain
{
    if (nil == _brain && brain == nil) {
        return;
    }
    NSLog(@"GraphViewController setBrain");
    _brain = brain;
    NSString *newTitle = @"Graph";
    NSString *description = [self.brain description];
    if (description && ! [description isEqualToString:@""]) {
        newTitle = [NSString stringWithFormat:@"Y=%@", description];
    }
    NSLog(@"the splitViewBarButtonItem has changed.  newTitle=%@", newTitle);
    UILabel *newTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    newTitleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    newTitleLabel.textAlignment = UITextAlignmentCenter;
    newTitleLabel.backgroundColor = [UIColor clearColor];
    newTitleLabel.shadowOffset = CGSizeMake(0, 1);
    newTitleLabel.textColor = [UIColor grayColor];
    newTitleLabel.text = newTitle;
    newTitleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    UIBarButtonItem *toolBarTitle = [[UIBarButtonItem alloc] initWithCustomView:newTitleLabel];
    [self setSplitViewBarButtonItem:toolBarTitle atPosition:2];
    BOOL displayIt = UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation);
    if (self.delegate) {
        [self setupSplitViewBarButtonItemAtPosition:0 doDisplay:displayIt]; // setup the back button, if needed
    }
    [self.graphView setNeedsDisplay]; // draw the graph every time brain is set
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
    tapper.numberOfTapsRequired = 3; 
    [self.graphView addGestureRecognizer:tapper];
    self.graphView.delegate = self;
}

- (BOOL)isValidProgram
{
    return ! (([[self brain] program] == nil)
              || ([[[self brain] program] lastObject] == nil));
}

- (double)calculateYResultForXValue:(CGFloat)x requestor:(GraphView *)graphView
{
    NSArray *programX = [[[self.brain variables] objectForKey:@"X"] copy];
    NSArray *valueX = [[NSArray alloc] initWithObjects:[NSNumber numberWithDouble:(double)x], nil];
    [self.brain setVariable:@"X" withValue:valueX]; // we temporarially replace X with the plot value
    NSArray *myProgram = [self.brain program];
    NSDictionary *myVariables = [self.brain variables];
    double result = [CalculatorBrain runProgram:myProgram usingVariableValues:myVariables];
    [self.brain setVariable:@"X" withValue:programX]; // put back the original X program
    //NSLog(@"For x=%g calculateYResultForXValue=%g", x, result);
    return result;
}

@end
