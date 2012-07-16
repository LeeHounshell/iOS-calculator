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

@end



@implementation GraphViewController

@synthesize brain = _brain;
@synthesize graphView = _graphView;


- (void)setBrain:(CalculatorBrain *)brain
{
    NSLog(@"GraphViewController setBrain");
    _brain = brain;
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    self.navigationItem.title = [NSString stringWithFormat:@"Y=%@", [self.brain description]];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    NSLog(@"For x=%g calculateYResultForXValue=%g", x, result);
    return result;
}

@end
