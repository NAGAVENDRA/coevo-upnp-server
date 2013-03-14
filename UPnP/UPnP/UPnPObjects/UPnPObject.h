//
//  UPnPObject.h
//  UPnP
//
//  Created by Patrick Denney on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UPnPObject <NSObject>

- (NSString *)xmlRepresentation:(NSString *)childElement;

@end
