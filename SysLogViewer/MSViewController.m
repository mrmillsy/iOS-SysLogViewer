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
#import "MSNetworkHelper.h"
#import "MSSettingsTableViewController.h"
#import "Reachability.h"

@interface MSViewController()

@property (retain, nonatomic) MSSysLogReceiver* logReceiver;
@property (retain, nonatomic) Reachability* wifiReach;

@end

@implementation MSViewController
@synthesize syslogTableView = _syslogTableView;
@synthesize autoScrollSwitch = _autoScrollSwitch;
@synthesize toolbarMessage = _toolbarMessage;

@synthesize logReceiver = _logReceiver;
@synthesize wifiReach = _wifiReach;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (IBAction)autoScrollChanged:(id)sender {
    [self updateScroll:self.autoScrollSwitch.on];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //register for background notifications
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appStateChange:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    //register for foreground notifications
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appStateChange:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];  
    
    self.wifiReach = [[[Reachability reachabilityForLocalWiFi]retain]autorelease];
    [self.wifiReach startNotifier];
    
    if([self.wifiReach currentReachabilityStatus] == ReachableViaWiFi){
        [self start];
    }
}

- (void) reachabilityChanged: (NSNotification* )note
{
    Reachability* curReach = [note object];
    if([curReach isKindOfClass: [Reachability class]]){
        if([curReach currentReachabilityStatus] == ReachableViaWiFi){
            [self start];
        }else{
            [self stop];
            [self networkLost];
        }
    }
    
}

-(void)appStateChange:(NSNotification*)notification
{
    if([[notification name]isEqualToString:UIApplicationDidEnterBackgroundNotification]){
        //stop connections
        [self stop];
    }else if([[notification name]isEqualToString:UIApplicationWillEnterForegroundNotification]){
        //restart connection
        [self start];
    }
}

- (void)viewDidUnload
{
    [self.logReceiver stopListening];
    [[NSNotificationCenter defaultCenter]removeObserver:self];

    [self setSyslogTableView:nil];
    [self setAutoScrollSwitch:nil];
    [self setAutoScrollSwitch:nil];
    [self setToolbarMessage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (!isPad()) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

-(void)newMessage
{
    [self.syslogTableView reloadData];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"autoScrollDefault"] && self.logReceiver.logEntries.count > 0){
        //if autoscroll is on then scroll
        NSIndexPath* lastEntry = [NSIndexPath indexPathForRow:[self.logReceiver.logEntries count]-1 inSection:0];
        [self.syslogTableView scrollToRowAtIndexPath:lastEntry atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

-(void)networkLost
{
    UIAlertView* alert = [[[UIAlertView alloc]initWithTitle:@"Error" message:@"Network connection lost - check Wifi connection" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] autorelease];
    [alert show];
    
    [self.toolbarMessage setTitle:@"Wifi Error"];
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
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    //only update if the autoscroll value has changed
    if([userDefaults boolForKey:@"autoScrollDefault"] != scroll){
        if(self.autoScrollSwitch && self.autoScrollSwitch.on != scroll) self.autoScrollSwitch.on = scroll;

        [userDefaults setBool:scroll forKey:@"autoScrollDefault"];
        [userDefaults synchronize];
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
        [self stop];
        
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
    
    if(isPad()){
        cell.textLabel.text = [NSString stringWithFormat:@"%@ [%@] [%@]", [entry faciltyName], [entry severityName], entry.tag];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"[%@] : %@", entry.pid, entry.msg];
    }else{
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [entry shortFaciltyName]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", entry.msg];
    }
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
        if([dest view]){
        dest.portCounter.value = self.logReceiver.port;
        dest.autoScrollSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"autoScrollDefault"];
        dest.severityCounter.value = self.logReceiver.severity;
        dest.delegate = self;
        }
    }else if([[segue identifier]isEqualToString:@"showEntry"]){
        MSSyslogEntryViewController* dest = [segue destinationViewController];
        if([dest view]){
            dest.entry = [self.logReceiver.logEntries objectAtIndex:[self.syslogTableView indexPathForSelectedRow].row];
            dest.datasource = self;
            //[self.syslogTableView deselectRowAtIndexPath:[self.syslogTableView indexPathForSelectedRow] animated:NO];
        }
    }
}

-(MSSysLogEntry*)previousEntry{
    int selected = [self.syslogTableView indexPathForSelectedRow].row;
    if(selected > 0){
        [self.syslogTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selected-1 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        return [self.logReceiver.logEntries objectAtIndex:[self.syslogTableView indexPathForSelectedRow].row];
    }
    
    return nil;
}

-(MSSysLogEntry*)nextEntry{
    int selected = [self.syslogTableView indexPathForSelectedRow].row;
    if(selected < self.logReceiver.logEntries.count-1){
        [self.syslogTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selected+1 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        return [self.logReceiver.logEntries objectAtIndex:[self.syslogTableView indexPathForSelectedRow].row];
    }
    
    return nil;
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
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(networkLost) name:@"NetworkLost" object:self.logReceiver];
    
    BOOL started = [self.logReceiver startListening];
    if(!started){
        //show Alert to user
        UIAlertView* alert = [[[UIAlertView alloc]initWithTitle:@"Error" message:@"Could not bind to port - check Wifi connection" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] autorelease];
        [alert show];
        
        [self.toolbarMessage setTitle:@"Error connecting"];
    }else{
        NSString* msg = [NSString stringWithFormat:@"%@:%u", [MSNetworkHelper GetWifiIpAddress], self.logReceiver.port];
        if(isPad()){
            msg = [NSString stringWithFormat:@"Listening on %@:%u", [MSNetworkHelper GetWifiIpAddress], self.logReceiver.port];
        }
        [self.toolbarMessage setTitle:msg];
    }
}

-(void)stop{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"SysLogMessage" object:self.logReceiver];
    //[[NSNotificationCenter defaultCenter]removeObserver:self name:@"NetworkLost" object:self.logReceiver];
    if(self.logReceiver){
        [self.logReceiver stopListening];
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
    [_toolbarMessage release];
    [_wifiReach release];
    [super dealloc];
}
@end
