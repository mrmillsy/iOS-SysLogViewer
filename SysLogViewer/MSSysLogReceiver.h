//
//  MSSysLogReceiver.h
//  SysLogViewer
//
//  Created by Chris Mills on 03/04/2012.
//  Copyright (c) 2012 MillsySoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSSysLogEntry.h"

@interface MSSysLogReceiver : NSObject

@property (strong, nonatomic, readonly) NSArray* logEntries;
@property (assign, nonatomic) UInt16 port;
@property (assign, nonatomic) Severity severity;

//init methods
-(id)init;
-(id)initWithPort:(UInt16)port; //primary

-(BOOL)startListening;
-(void)stopListening;
-(void)clearEntries;

@end
