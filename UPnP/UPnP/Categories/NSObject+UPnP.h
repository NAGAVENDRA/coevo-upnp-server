//
//  NSObject+UPnP.h
//  UPnP
//
//  Created by Patrick Denney on 8/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (NSObject_UPnP)

// Perform the passed in block after the designated delay.
- (void)performBlock:(void(^)(void))block afterDelay:(NSTimeInterval)delay;

@end
