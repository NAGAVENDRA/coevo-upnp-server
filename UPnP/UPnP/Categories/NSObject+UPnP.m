//
//  NSObject+UPnP.m
//  UPnP
//
//  Created by Patrick Denney on 8/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSObject+UPnP.h"

@implementation NSObject (NSObject_UPnP)

-(void)performBlock:(void(^)(void))block afterDelay:(NSTimeInterval)delay
{
	int64_t nanoseconds=(int64_t)(1.0e9 *delay);
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW,nanoseconds),
				   dispatch_get_main_queue(),
				   block);
}

@end
