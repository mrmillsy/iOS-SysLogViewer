//
//  MSNetworkHelper.m
//  SysLogViewer
//
//  Created by Chris Mills on 03/04/2012.
//  Copyright (c) 2012 MillsySoft. All rights reserved.
//

#import "MSNetworkHelper.h"
#import <ifaddrs.h>
#import <arpa/inet.h>


@implementation MSNetworkHelper

+(NSString *)GetWifiIpAddress
{
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

+(MSSysLogEntry*)parseSyslogData:(NSData*)data
		  fromHost:(NSString *)host
			  port:(UInt16)port
{   
    MSSysLogEntry* result;
    
    UInt8 *bytes = (UInt8 *)data.bytes;
    
    if(bytes[0] == '<')
    {
        int priority = 0;
        uint position = 1;
        //valid < start to msg
        for(; position <= 5; position++)
        {
            if(bytes[position] == '>'){
                //found a > character
                UInt8* priorityChar[position-1];
                memcpy(priorityChar, bytes+1, (position-1));
                NSString* t = [[NSString alloc]initWithBytes:priorityChar length:(position-1) encoding:NSASCIIStringEncoding];
                priority = [t intValue];
                
                position++;
                break;
            }
        }
        //priority = 41;
        UInt8 facility =  priority >> 3;
        UInt8 severity = priority - (facility << 3);
        
        UInt8* timestampBytes[15];
        memcpy(timestampBytes, bytes + position, 15);
        
        NSString* timestamp = [[NSString alloc]initWithBytes:timestampBytes length:15 encoding:NSASCIIStringEncoding];
        
        position += 15;
        
        position++; //whitespace before machine name
        
        uint lengthOfName = 0;
        char current = bytes[position];
        while(current != ' '){
            lengthOfName++;
            current = bytes[position + lengthOfName];
        }
        
        UInt8* nameChars[lengthOfName];
        memcpy(nameChars, bytes+position, lengthOfName);
        NSString* nameOrIPAddr = [[NSString alloc]initWithBytes:nameChars length:lengthOfName encoding:NSASCIIStringEncoding];
        
        position += lengthOfName +1;//+1 for the whitespace at the end before the msg
        
        int tagEnd = position;
        
        for(int i = 0; position < data.length && i < 32; i++){
            //tag has a max of 32 chars and only A-Za-z0-9 allowed
            char c = bytes[position+i];
            if((c >= '0' && c <= '9')||
               (c >= 'A' && c <= 'Z') ||
               (c >= 'a' && c <= 'z') || c == '.')
            {
                //acceptable character found
                tagEnd++;
            }else{
                break;
            }
        }
        
        UInt8* tagChar[position + tagEnd];
        memcpy(tagChar, bytes+position, tagEnd-position);        
        NSString* tag = [[NSString alloc]initWithBytes:tagChar length:tagEnd-position encoding:NSASCIIStringEncoding];
        
        position = tagEnd;
        
        int pidEnd = position;
        if(bytes[position] == '['){
            //we have a pid in square brackets
            while(bytes[pidEnd] != ']'){
                pidEnd += 1;
            }
        }
        
        NSString* pid = nil;
        if(pidEnd > position){
            int s = position + 1;
            int e = pidEnd;
            UInt8* pidChar[e-s];
            memcpy(pidChar, bytes+s, e-s);        
            pid = [[NSString alloc] initWithBytes:pidChar length:e-s encoding:NSASCIIStringEncoding];
            
            position = pidEnd + 1;
            
            if(bytes[position] == ':'){
                //increase position further
                position++;
            }
            
            if(bytes[position] == ' '){
                //increase position further
                position++;                
            }
        }
        
        UInt8* msgChar[data.length - position];
        memcpy(msgChar, bytes+position, data.length - position);        
        NSString* msg = [[NSString alloc]initWithBytes:msgChar length:data.length - position encoding:NSASCIIStringEncoding];
        
        
        result = [[MSSysLogEntry alloc]init];
        result.priority = priority;
        result.severity = severity;
        result.facility = facility;
        result.timestamp = timestamp;
        result.sender = nameOrIPAddr;
        result.tag = tag;
        result.pid = pid;
        result.msg = msg;
        result.host = host;
        result.port = port;
        result.rawData = data;
    }
    
    return result;
    
	//[self.UdpSocket1 receiveWithTimeout:-1 tag:1];			//Setup to receive next UDP packet
	//return YES;			//Signal that we didn't ignore the packet.
}

@end
