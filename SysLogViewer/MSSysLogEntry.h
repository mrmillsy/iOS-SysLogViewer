//
//  MSSysLogEntry.h
//  SysLogViewer
//
//  Created by Chris Mills on 03/04/2012.
//  Copyright (c) 2012 MillsySoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSSysLogEntry : NSObject

typedef enum {
kDEBUG = 7,//                   -- ^ Debug messages
kINFO = 6,//                    -- ^ Information
kNOTICE = 5,//                  -- ^ Normal runtime conditions
kWARNING = 4,//                 -- ^ General Warnings
kERROR = 3,//                   -- ^ General Errors
kCRITICAL = 2,//                -- ^ Severe situations
kALERT = 1,//                   -- ^ Take immediate action
kEMERGENCY = 0//               -- ^ System is unusable
} Severity;

typedef enum {
    kKERN = 0,
    kUSER = 1,
    kMAIL = 2,
    kDAEMON = 3,
    kAUTH = 4,//                    -- ^ Authentication or security messages
    kSYSLOG = 5,//                  -- ^ Internal syslog messages
    kLPR = 6,//                     -- ^ Printer messages
    kNEWS = 7,//                    -- ^ Usenet news
    kUUCP = 8,//                    -- ^ UUCP messages
    kCRON = 9,//                    -- ^ Cron messages
    kAUTHPRIV = 10,//                -- ^ Private authentication messages
    kFTP = 11,//                     -- ^ FTP messages
    kNTP = 12,
    kLOGAUDIT = 13,
    kLOGALERT = 14,
    kCLOCK = 15,
    kLOCAL0 = 16,//                  
    kLOCAL1 = 17,//
    kLOCAL2 = 18,//
    kLOCAL3 = 19,//
    kLOCAL4 = 20,//
    kLOCAL5 = 21,//
    kLOCAL6 = 22,//
    kLOCAL7 = 23
} Facility;


@property (assign, nonatomic) uint priority;
@property (assign, nonatomic) Severity severity;
@property (assign, nonatomic) Facility facility;
@property (retain, nonatomic) NSString* timestamp;
@property (retain, nonatomic) NSString* sender;
@property (retain, nonatomic) NSString* tag;
@property (retain, nonatomic) NSString* pid;
@property (retain, nonatomic) NSString* msg;
@property (retain, nonatomic) NSString* host;
@property (assign, nonatomic) UInt16 port;
@property (retain, nonatomic) NSData* rawData;

-(NSString*)severityName;
-(NSString*)faciltyName;

@end
