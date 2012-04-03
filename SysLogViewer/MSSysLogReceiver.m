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

@end

@implementation MSSysLogReceiver

@synthesize logEntries = _logEntries;
@synthesize port = _port;

//private properties
static UInt16 defaultPort = 5122;
@synthesize UdpSocket1 = _UdpSocket1;

-(id)init
{
    return [self initWithPort:defaultPort];
}

-(id)initWithPort:(UInt16)port
{
    self = [super init];
    if(self){
        self.port = port;
        self.logEntries = [[[NSMutableArray alloc]init]autorelease];
    }
    
    return self;
}

-(BOOL)startListening
{
    NSLog(@"Creating UDP socket");
    self.UdpSocket1 = [[[AsyncUdpSocket alloc] initWithDelegate:self]autorelease];
    if (![self.UdpSocket1 bindToPort:self.port error:nil])
    {
        NSLog(@"Bind error");
        return NO;
    }
    [self.UdpSocket1 receiveWithTimeout:-1 tag:1];
    return YES;

}

-(void)stopListening
{
    if(![self.UdpSocket1 isClosed])
    {
        [self.UdpSocket1 close];
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
                
        [self.logEntries addObject:syslog];

        [[NSNotificationCenter defaultCenter]postNotificationName:@"SysLogMessage" object:self];
    }
    
	[self.UdpSocket1 receiveWithTimeout:-1 tag:1];			//Setup to receive next UDP packet
	return YES;			//Signal that we didn't ignore the packet.
}

-(void)dealloc
{
    [_UdpSocket1 release];
    [_logEntries release];
    [super dealloc];
}

@end
