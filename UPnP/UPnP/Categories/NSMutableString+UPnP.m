//
//  NSMutableString+UPnP.m
//  UPnP
//
//  Created by Patrick Denney on 8/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSMutableString+UPnP.h"

@implementation NSMutableString (NSMutableString_UPnP)

- (void)appendServerResponseString:(NSString *)string
{
    [self appendFormat:@"%@\r\n",string];
}

@end
