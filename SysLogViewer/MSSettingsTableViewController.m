//
//  MSSettingsTableViewControllerViewController.m
//  SysLogViewer
//
//  Created by Chris Mills on 03/04/2012.
//  Copyright (c) 2012 MillsySoft. All rights reserved.
//

#import "MSSettingsTableViewController.h"
#import "MSNetworkHelper.h"


@interface MSSettingsTableViewController ()

@end

@implementation MSSettingsTableViewController
@synthesize portCounter;
@synthesize portLabel;
@synthesize ipLabel;
@synthesize autoScrollSwitch;
@synthesize severityCounter;
@synthesize severityLabel;
@synthesize delegate = _delegate;

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
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller
    
    self.portCounter.minimumValue = 1024;
    self.portCounter.maximumValue = 65535;
    //self.portCounter.value = 5122;
    
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.ipLabel.text = [MSNetworkHelper GetWifiIpAddress];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.portLabel.text = [NSString stringWithFormat:@"%g", self.portCounter.value];
    
    MSSysLogEntry* entry = [[MSSysLogEntry alloc]init];
    entry.severity = self.severityCounter.value;
    self.severityLabel.text = [entry severityName];
    [entry release];
}

- (void)viewDidUnload
{
    [self setPortCounter:nil];
    [self setPortLabel:nil];
    [self setIpLabel:nil];
    [self setAutoScrollSwitch:nil];
    [self setSeverityCounter:nil];
    [self setSeverityLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (!isPad()) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    //update the delegate when we're done
    [self.delegate updatePortNumber:self.portCounter.value];
    [self.delegate updateScroll:self.autoScrollSwitch.on];
    [self.delegate updateSeverity:self.severityCounter.value];
}

- (IBAction)portNumberValueChanged:(id)sender {
    self.portLabel.text = [NSString stringWithFormat:@"%g", self.portCounter.value];
}

- (IBAction)severityValueChanged:(id)sender {
    
    MSSysLogEntry* entry = [[MSSysLogEntry alloc]init];
    entry.severity = self.severityCounter.value;
    self.severityLabel.text = [entry severityName];
    
    [entry release];
}


- (void)dealloc {
    [portCounter release];
    [portLabel release];
    [ipLabel release];
    [autoScrollSwitch release];
    [severityCounter release];
    [severityLabel release];
    [super dealloc];
}
@end
