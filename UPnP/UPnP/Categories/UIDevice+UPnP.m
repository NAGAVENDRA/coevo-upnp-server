//
//  UIDevice+UPnP.m
//  UPnP
//
//  Created by Patrick Denney on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIDevice+UPnP.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

@implementation UIDevice (UIDevice_UPnP)

+ (NSString *)currentIPAddress
{
    NSString *address = @"127.0.0.1";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"] ||
                   ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en1"]))
                {
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

@end
