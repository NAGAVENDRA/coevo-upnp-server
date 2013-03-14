//
//  NSMutableString+UPnP.h
//  UPnP
//
//  Created by Patrick Denney on 8/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (NSMutableString_UPnP)

// Appends \r\n onto the end of the string for proper response message
- (void)appendServerResponseString:(NSString *)string;

@end
