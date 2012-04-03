//
//  MSSysLogReceiver.h
//  SysLogViewer
//
//  Created by Chris Mills on 03/04/2012.
//  Copyright (c) 2012 MillsySoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSSysLogReceiver : NSObject

@property (strong, nonatomic) NSMutableArray* logEntries;
@property (assign, nonatomic) UInt16 port;

//init methods
-(id)init;
-(id)initWithPort:(UInt16)port; //primary

-(BOOL)startListening;
-(void)stopListening;

@end
