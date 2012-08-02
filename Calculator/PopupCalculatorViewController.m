//
//  PopupCalculatorViewController.m
//  Calculator
//
//  Created by Lee Hounshell on 8/1/12.
//  Copyright (c) 2012 H.A.R.L.I.E. All rights reserved.
//

#import "PopupCalculatorViewController.h"

@interface PopupCalculatorViewController ()

@end

@implementation PopupCalculatorViewController

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
