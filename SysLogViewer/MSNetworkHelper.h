//
//  MSNetworkHelper.h
//  SysLogViewer
//
//  Created by Chris Mills on 03/04/2012.
//  Copyright (c) 2012 MillsySoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSSysLogEntry.h"

@interface MSNetworkHelper : NSObject

+(NSString *)GetWifiIpAddress;
+(MSSysLogEntry*)parseSyslogData:(NSData*)data
              fromHost:(NSString *)host
                  port:(UInt16)port;

@end
