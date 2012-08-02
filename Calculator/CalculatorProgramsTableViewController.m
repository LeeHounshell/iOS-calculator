//
//  CalculatorProgramsTableViewController.m
//  Calculator
//
//  Created by Lee Hounshell on 7/27/12.
//  Copyright (c) 2012 H.A.R.L.I.E. All rights reserved.
//

#import "CalculatorProgramsTableViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorProgramsTableViewController ()

@end

@implementation CalculatorProgramsTableViewController

@synthesize programs = _programs;
@synthesize delegate = _delegate;


- (NSArray *)programs
{
    if (! _programs) {
        NSArray *defaultPrograms = [[NSUserDefaults standardUserDefaults] objectForKey:FAVORITES_KEY];
        _programs = [[NSArray alloc] initWithArray:defaultPrograms];
    }
    return _programs;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
       
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.programs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Calculator Program Description";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    // Configure the cell...
    
    NSArray *allProgramsAndVariables = self.programs;
    NSDictionary *aProgramWithVariables = [allProgramsAndVariables objectAtIndex:indexPath.row];
    NSArray *aProgram = [aProgramWithVariables objectForKey:@"program"];
    //NSDictionary *someVariables = [aProgramWithVariables objectForKey:@"variables"];
    NSString *program = [CalculatorBrain descriptionOfProgram:aProgram];
    //NSString *vars = [CalculatorBrain descriptionOfVariables:someVariables forProgram:aProgram];
 
    cell.textLabel.text = [NSString stringWithFormat:@"Y = %@", program];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected tableView row for indexPath=%@", indexPath);
    NSDictionary *aProgramWithVariables = [self.programs objectAtIndex:indexPath.row];
    if (! self.delegate) {
        NSLog(@"ERROR: unable to locate program for indexPath=%@", indexPath);
    }
    [self.delegate calculatorProgramsTableViewController:self choseProgramAndVariables:aProgramWithVariables];
}

@end
