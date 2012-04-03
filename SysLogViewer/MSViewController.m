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
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];    
    int portNumber = [userDefaults integerForKey:@"defaultPortNumber"];
    if(portNumber == 0){
        portNumber = 5122;
        [userDefaults setInteger:portNumber forKey:@"defaultPortNumber"];
        [userDefaults synchronize];
    }
	// Do any additional setup after loading the view, typically from a nib.
    self.logReceiver = [[MSSysLogReceiver alloc]initWithPort:portNumber];
    self.autoScrollSwitch.on = [userDefaults boolForKey:@"autoScrollDefault"];
    
    [self startWithPort:portNumber];
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

-(void)updateScroll:(BOOL)scroll
{
    //only update if the autoscroll value has changed
    if(self.autoScrollSwitch.on != scroll){
        self.autoScrollSwitch.on = scroll;
        [self autoScrollChanged:nil];
    }
}

-(void)updatePortNumber:(int)portNumber{
    //only update if the port number has changed
    if(portNumber != self.logReceiver.port){
        //save the default port number
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];    
        [userDefaults setInteger:portNumber forKey:@"defaultPortNumber"];
        [userDefaults synchronize];
        
        //stop receiving notifications
        [[NSNotificationCenter defaultCenter]removeObserver:self];
        
        //close the old one
        if(self.logReceiver){
            [self.logReceiver stopListening];
            [self.logReceiver release];
        }   
        
        //start listening    
        [self startWithPort:portNumber];
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier]isEqualToString:@"showSettings"]){
        MSSettingsTableViewController* dest = [segue destinationViewController];
        dest.portCounter.value = self.logReceiver.port;
        dest.autoScrollSwitch.on = self.autoScrollSwitch.on;
        dest.delegate = self;
    }
}

-(void)startWithPort:(int)portNumber
{
    //restart the listener    
    self.logReceiver = [[MSSysLogReceiver alloc]initWithPort:portNumber];
    
    //register for notifications again
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(newMessage) name:@"SysLogMessage" object:self.logReceiver];

    BOOL started = [self.logReceiver startListening];
    if(!started){
        //show Alert to user
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Could not bind to port - check Wifi connection" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}

- (void)dealloc {
    [_syslogTableView release];
    [_autoScrollSwitch release];
    [_autoScrollSwitch release];
    [super dealloc];
}
@end
