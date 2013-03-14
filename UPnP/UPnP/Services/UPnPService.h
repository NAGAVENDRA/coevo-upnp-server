//
//  UPnPService.h
//  UPnP
//
//  Created by Patrick Denney on 10/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UPnPService <NSObject>

@required

// The service schema (e.x. urn:schemas-upnp-org:service:WANPPPConnection:1)
- (NSString *)serviceSchema;

// The control URL (<controlURL>) found in the device definition
// POST messages will query against the control URL to perform actions
- (NSString *)controlURL;

// The eventing URL (<eventSubURL>) found in the device definition 
// POST messages can subscribe to state variable changes using the event URL
- (NSString *)eventURL;

// Give a response for the specified SOAP action
- (NSString *)responseForControlAction:(NSString *)action;

// Give a response for the specified eventing variable
- (NSString *)responseForEventVariable:(NSString *)event;

@end
