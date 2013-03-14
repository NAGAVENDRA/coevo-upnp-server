//
//  UIDevice+UPnP.h
//  UPnP
//
//  Created by Patrick Denney on 8/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIDevice (UIDevice_UPnP)

// Get the current IP address of the device
+ (NSString *)currentIPAddress;

@end
