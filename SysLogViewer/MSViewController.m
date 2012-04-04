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
#import "MSSyslogEntryViewController.h"

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
    
    //register for background notifications
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appStateChange:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    //register for foreground notifications
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appStateChange:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self start];
}

-(void)appStateChange:(NSNotification*)notification
{
    if([[notification name]isEqualToString:UIApplicationDidEnterBackgroundNotification]){
        //stop connections
        [[NSNotificationCenter defaultCenter]removeObserver:self name:@"SysLogMessage" object:self.logReceiver];
        [self.logReceiver stopListening];
        NSLog(@"Network connections closed");
    }else if([[notification name]isEqualToString:UIApplicationWillEnterForegroundNotification]){
        //restart connection
        [self start];
        NSLog(@"Network connections opened");
    }
}

- (void)viewDidUnload
{
    [self.logReceiver stopListening];
    [[NSNotificationCenter defaultCenter]removeObserver:self];

    [self setSyslogTableView:nil];
    [self setAutoScrollSwitch:nil];
    [self setAutoScrollSwitch:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
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
    if(self.autoScrollSwitch.on && self.logReceiver.logEntries.count > 0){
        //if autoscroll is on then scroll
        NSIndexPath* lastEntry = [NSIndexPath indexPathForRow:[self.logReceiver.logEntries count]-1 inSection:0];
        [self.syslogTableView scrollToRowAtIndexPath:lastEntry atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

-(void)updateSeverity:(Severity)sev
{
    if(self.logReceiver.severity != sev){
        self.logReceiver.severity = sev;
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setInteger:sev forKey:@"defaultSeverityLevel"];
        [userDefaults synchronize];
        //refresh with new filter applied
        [self.syslogTableView reloadData];
    }
}

-(void)updateScroll:(BOOL)scroll
{
    //only update if the autoscroll value has changed
    if(self.autoScrollSwitch.on != scroll){
        self.autoScrollSwitch.on = scroll;
        [self autoScrollChanged:nil];
    }
}

- (IBAction)clearRecords:(id)sender {
    [self.logReceiver clearEntries];
    [self.syslogTableView reloadData];
}

-(void)updatePortNumber:(int)portNumber{
    //only update if the port number has changed
    if(portNumber != self.logReceiver.port){
        //save the default port number
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];    
        [userDefaults setInteger:portNumber forKey:@"defaultPortNumber"];
        [userDefaults synchronize];
        
        //stop receiving notifications
        [[NSNotificationCenter defaultCenter]removeObserver:self name:@"SysLogMessage" object:self.logReceiver];
        
        //close the old one
        if(self.logReceiver){
            [self.logReceiver stopListening];
        }
        
        //start listening    
        [self start];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //playerCell
    static NSString *CellIdentifier = @"syslogcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier]autorelease];
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier]isEqualToString:@"showSettings"]){
        MSSettingsTableViewController* dest = [segue destinationViewController];
        dest.portCounter.value = self.logReceiver.port;
        dest.autoScrollSwitch.on = self.autoScrollSwitch.on;
        dest.severityCounter.value = self.logReceiver.severity;
        dest.delegate = self;
    }else if([[segue identifier]isEqualToString:@"showEntry"]){
        MSSyslogEntryViewController* dest = [segue destinationViewController];
        dest.entry = [self.logReceiver.logEntries objectAtIndex:[self.syslogTableView indexPathForSelectedRow].row];
        [self.syslogTableView deselectRowAtIndexPath:[self.syslogTableView indexPathForSelectedRow] animated:NO];
    }
}

-(void)start
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];    
    
    int portNumber = [userDefaults integerForKey:@"defaultPortNumber"];
    
    if(!self.logReceiver){
        self.logReceiver = [[[MSSysLogReceiver alloc]initWithPort:portNumber]autorelease];
    }
    
    self.logReceiver.port = portNumber;
    self.logReceiver.severity = [userDefaults integerForKey:@"defaultSeverityLevel"];    
    self.autoScrollSwitch.on = [userDefaults boolForKey:@"autoScrollDefault"];    
    
    //register for notifications again
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(newMessage) name:@"SysLogMessage" object:self.logReceiver];

    BOOL started = [self.logReceiver startListening];
    if(!started){
        //show Alert to user
        UIAlertView* alert = [[[UIAlertView alloc]initWithTitle:@"Error" message:@"Could not bind to port - check Wifi connection" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] autorelease];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}



- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [_logReceiver stopListening];    
    [_logReceiver release];
    [_syslogTableView release];
    [_autoScrollSwitch release];
    [_autoScrollSwitch release];
    [super dealloc];
}
@end
