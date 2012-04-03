//
//  MSViewController.m
//  SysLogViewer
//
//  Created by Chris Mills on 02/03/2012.
//  Copyright (c) 2012 MillsySoft. All rights reserved.
//

#import "MSViewController.h"
#import "MSSysLogReceiver.h"
#import "MSSysLogEntry.h"

@interface MSViewController()

@property (retain, nonatomic) MSSysLogReceiver* logReceiver;

@end

@implementation MSViewController
@synthesize syslogTableView = _syslogTableView;
@synthesize autoScrollSwitch = _autoScrollSwitch;

@synthesize logReceiver = _logReceiver;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (IBAction)autoScrollChanged:(id)sender {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:self.autoScrollSwitch.on forKey:@"autoScrollDefault"];
    [userDefaults synchronize];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.logReceiver = [[MSSysLogReceiver alloc]init];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];    
    self.autoScrollSwitch.on = [userDefaults boolForKey:@"autoScrollDefault"];
    
    //register for updates
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(newMessage) name:@"SysLogMessage" object:self.logReceiver];
    
    [self.logReceiver startListening];
}

- (void)viewDidUnload
{
    [self setSyslogTableView:nil];
    [self setAutoScrollSwitch:nil];
    [self setAutoScrollSwitch:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [self.logReceiver stopListening];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

-(void)newMessage
{
    [self.syslogTableView reloadData];
    if(self.autoScrollSwitch.on){
        //if autoscroll is on then scroll
        NSIndexPath* lastEntry = [NSIndexPath indexPathForRow:[self.logReceiver.logEntries count]-1 inSection:0];
        [self.syslogTableView scrollToRowAtIndexPath:lastEntry atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //playerCell
    static NSString *CellIdentifier = @"syslogcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    MSSysLogEntry* entry = [self.logReceiver.logEntries objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ [%@] [%@]", [entry faciltyName], [entry severityName], entry.tag];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"[%@] : %@", entry.pid, entry.msg];
    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"black" ofType:@"png"];
    if(entry.severity <= kCRITICAL){
        imagePath = [[NSBundle mainBundle] pathForResource:@"red" ofType:@"png"];
    }else if(entry.severity <= kWARNING){
        imagePath = [[NSBundle mainBundle] pathForResource:@"orange" ofType:@"png"];
    }
    
    UIImage *icon = [UIImage imageWithContentsOfFile: imagePath];
    cell.imageView.image = icon;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.logReceiver.logEntries count];
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSSysLogEntry* entry = [self.logReceiver.logEntries objectAtIndex:indexPath.row];
    if(entry.severity <= kWARNING){
        //cell.backgroundColor = [UIColor redColor];
    }    
}

- (void)dealloc {
    [_syslogTableView release];
    [_autoScrollSwitch release];
    [_autoScrollSwitch release];
    [super dealloc];
}
@end
