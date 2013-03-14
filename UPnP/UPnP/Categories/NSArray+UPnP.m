//
//  NSArray+UPnP.m
//  UPnP
//
//  Created by Patrick Denney on 9/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSArray+UPnP.h"

@implementation NSArray (NSArray_UPnP)

- (BOOL)containsString:(NSString *)string
{
    BOOL (^predicate)(id obj, NSUInteger idx, BOOL *stop) = ^ BOOL(id obj, NSUInteger idx, BOOL *stop)
    {
        return [obj isEqualToString:string];
    };
    
    return ([self indexOfObjectPassingTest:predicate] != NSNotFound);
}

@end
