//
//  MSSysLogEntry.m
//  SysLogViewer
//
//  Created by Chris Mills on 03/04/2012.
//  Copyright (c) 2012 MillsySoft. All rights reserved.
//

#import "MSSysLogEntry.h"

@implementation MSSysLogEntry

@synthesize priority = _priority;
@synthesize severity = _severity;
@synthesize facility = _facility;
@synthesize timestamp = _timestamp;
@synthesize sender = _sender;
@synthesize tag = _tag;
@synthesize pid = _pid;
@synthesize msg = _msg;
@synthesize host = _host;
@synthesize port = _port;
@synthesize rawData = _rawData;

-(NSString*)description
{
    NSString* desc = [NSString stringWithFormat:@"%@ %@ %@", [self severityName], [self faciltyName], self.msg];
    return desc;
}

-(NSString*)severityName
{
switch (self.severity) {
    case kEMERGENCY:
        return @"Emergency";
        break;
    case kALERT:
        return @"Alert";
        break;
    case kCRITICAL:
        return @"Critical";
        break;
    case kERROR:
        return @"Error";
        break;
    case kWARNING:
        return @"Warning";
        break;
    case kNOTICE:
        return @"Notice";
        break;
    case kINFO:
        return @"Info";
        break;
    case kDEBUG:
        return @"Debug";
        break;
    default:
        return nil;
        break;
}
}

-(NSString*)faciltyName
{
switch (self.facility) {
    case kKERN:
        return @"Kernal messages";
        break;
    case kUSER:
        return @"User level messages";
        break;
    case kMAIL:
        return @"Mail System";
        break;
    case kDAEMON:
        return @"System Daemons";
        break;
    case kAUTH:
        return @"Security/Auth Messages";
        break;
    case kSYSLOG:
        return @"Syslog internal";
        break;
    case kLPR:
        return @"Line printer subsystem";
        break;
    case kNEWS:
        return @"Network news subsystem";
        break;
    case kUUCP:
        return @"UUCP subsystem";
        break;
    case kCRON:
        return @"Cron Daemon";
        break;
    case kAUTHPRIV:
        return @"Security/Auth Messages";
        break;
    case kFTP:
        return @"FTP Daemon";
        break;
    case kNTP:
        return @"NTP Daemon";
        break;
    case kLOGAUDIT:
        return @"Log Audit";
        break;
    case kLOGALERT:
        return @"Log Alert";
        break;
    case kCLOCK:
        return @"Clock Daemon";
        break;
    case kLOCAL0:
        return @"Local use 0";
        break;
    case kLOCAL1:
        return @"Local use 1";
        break;
    case kLOCAL2:
        return @"Local use 2";
        break;
    case kLOCAL3:
        return @"Local use 3";
        break;
    case kLOCAL4:
        return @"Local use 4";
        break;
    case kLOCAL5:
        return @"Local use 5";
        break;
    case kLOCAL6:
        return @"Local use 6";
        break;
    case kLOCAL7:
        return @"Local use 7";
        break;
    default:
        return nil;
        break;
}
}


@end
