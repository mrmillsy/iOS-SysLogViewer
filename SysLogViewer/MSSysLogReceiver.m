//
//  MSSysLogReceiver.m
//  SysLogViewer
//
//  Created by Chris Mills on 03/04/2012.
//  Copyright (c) 2012 MillsySoft. All rights reserved.
//

#import "MSSysLogReceiver.h"
#import "AsyncUdpSocket.h"
#import "MSNetworkHelper.h"

@interface MSSysLogReceiver()

@property (nonatomic, strong) AsyncUdpSocket *UdpSocket1;
@property (nonatomic, strong) NSMutableArray* internalLogEntries;

@end

@implementation MSSysLogReceiver

@synthesize logEntries = _logEntries;
@synthesize port = _port;
@synthesize severity = _severity;
@synthesize internalLogEntries = _internalLogEntries;

//private properties
static UInt16 defaultPort = 5122;
@synthesize UdpSocket1 = _UdpSocket1;

-(id)init
{
    return [self initWithPort:defaultPort];
}

-(id)initWithPort:(UInt16)port
{
    return [self initWithPort:port severity:7];//default is Debug i.e. show everything
}

-(id)initWithPort:(UInt16)port severity:(Severity)severity
{
    self = [super init];
    if(self){
        self.port = port;
        self.internalLogEntries = [[[NSMutableArray alloc]init]autorelease];
        self.severity = severity;
    }
    
    return self;
}

-(BOOL)startListening
{
    //check if still listening first
    if(self.UdpSocket1)
    {
        [self stopListening];
    }
    
    NSString* wifiAddress = [MSNetworkHelper GetWifiIpAddress];
    if(!wifiAddress)
        return NO;
    
    self.UdpSocket1 = [[[AsyncUdpSocket alloc] initWithDelegate:self]autorelease];
    //if (![self.UdpSocket1 bindToPort:self.port error:nil])
    if (![self.UdpSocket1 bindToAddress:wifiAddress port:self.port error:nil])
    {
        return NO;
    }
    [self.UdpSocket1 receiveWithTimeout:-1 tag:1];
    return YES;

}

-(void)stopListening
{
    if(![self.UdpSocket1 isClosed])
    {
        self.UdpSocket1.delegate = nil;
        [self.UdpSocket1 close];
        self.UdpSocket1 = nil;
    }
}

-(BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data
		   withTag:(long)tag
		  fromHost:(NSString *)host
			  port:(UInt16)port
{
    MSSysLogEntry* syslog = [MSNetworkHelper parseSyslogData:data fromHost:host port:port];
    if(syslog){
        
        //NSLog(@"Msg %@", syslog);
                
        [self.internalLogEntries addObject:syslog];

        [[NSNotificationCenter defaultCenter]postNotificationName:@"SysLogMessage" object:self];
    }
    
	[self.UdpSocket1 receiveWithTimeout:-1 tag:1];			//Setup to receive next UDP packet
	return YES;			//Signal that we didn't ignore the packet.
}

- (void)onUdpSocketDidClose:(AsyncUdpSocket *)sock
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"NetworkLost" object:self];
}

-(void)clearEntries
{
    if(self.internalLogEntries){
        [self.internalLogEntries removeAllObjects];
    }
}

-(NSArray*)logEntries
{
    NSPredicate* filterPred = [NSPredicate predicateWithFormat:@"severity <= %u", self.severity];
    NSMutableArray* copy = [self.internalLogEntries mutableCopy];
    [copy filterUsingPredicate:filterPred];
    return [copy autorelease]; 
}

-(void)dealloc
{
    [_UdpSocket1 release];
    [_logEntries release];
    [super dealloc];
}

@end
