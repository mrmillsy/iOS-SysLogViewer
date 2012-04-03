//
//  MSSyslogEntryViewController.m
//  SysLogViewer
//
//  Created by Chris Mills on 03/04/2012.
//  Copyright (c) 2012 MillsySoft. All rights reserved.
//

#import "MSSyslogEntryViewController.h"

@interface MSSyslogEntryViewController ()

@end

@implementation MSSyslogEntryViewController

@synthesize syslogTable = _syslogTable;
@synthesize entry = _entry;
@synthesize priorityLabel = _priorityLabel;
@synthesize severityLabel = _severityLabel;
@synthesize faciltyLabel = _faciltyLabel;
@synthesize timestampLabel = _timestampLabel;
@synthesize processIDLabel = _processIDLabel;
@synthesize tagLabel = _tagLabel;
@synthesize msgLabel = _msgLabel;
@synthesize hostLabel = _hostLabel;
@synthesize portLabel = _portLabel;

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

-(void)viewWillAppear:(BOOL)animated
{
    if(self.entry){
        self.priorityLabel.text = [NSString stringWithFormat:@"%u", self.entry.priority];
        self.severityLabel.text = [self.entry severityName];
        self.faciltyLabel.text = [self.entry faciltyName];
        self.timestampLabel.text = self.entry.timestamp;
        self.processIDLabel.text = self.entry.pid;
        self.tagLabel.text = self.entry.tag;
        self.msgLabel.text = self.entry.msg;
        self.hostLabel.text = self.entry.host;
        self.portLabel.text = [NSString stringWithFormat:@"%u", self.entry.port];
    }
}

- (void)viewDidUnload
{
    [self setSyslogTable:nil];
    [self setPriorityLabel:nil];
    [self setSeverityLabel:nil];
    [self setFaciltyLabel:nil];
    [self setTimestampLabel:nil];
    [self setProcessIDLabel:nil];
    [self setTagLabel:nil];
    [self setMsgLabel:nil];
    [self setHostLabel:nil];
    [self setPortLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [_syslogTable release];
    [_priorityLabel release];
    [_severityLabel release];
    [_faciltyLabel release];
    [_timestampLabel release];
    [_processIDLabel release];
    [_tagLabel release];
    [_msgLabel release];
    [_hostLabel release];
    [_portLabel release];
    [super dealloc];
}
@end
