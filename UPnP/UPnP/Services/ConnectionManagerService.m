//
//  ConnectionManagerService.m
//  UPnP
//
//  Created by Patrick Denney on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConnectionManagerService.h"
#import "SharedDefinitions.h"
#import "ConnectionManagerServiceErrorCodes.h"

@implementation ConnectionManagerService

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

#pragma mark Public API

#pragma mark UPnPService

// The service schema (e.x. urn:schemas-upnp-org:service:WANPPPConnection:1)
- (NSString *)serviceSchema
{
    return @"urn:schemas-upnp-org:service:ConnectionManager:1";
}

// The control URL (<controlURL>) found in the device definition
// POST messages will query against the control URL to perform actions
- (NSString *)controlURL
{
    return @"/upnp/control/connection_manager";
}

// The eventing URL (<eventSubURL>) found in the device definition 
// POST messages can subscribe to state variable changes using the event URL
- (NSString *)eventURL
{
    return @"/upnp/event/connection_manager";
}

- (NSString *)getProtocolInfo
{
    return nil;
}

// Give a response for the specified SOAP action. 
- (NSString *)responseForControlAction:(NSString *)action
{
    return nil;
}

// Give a response for the specified SOAP event message.
- (NSString *)responseForEventVariable:(NSString *)event
{
    return nil;
}

- (NSString *)prepareForConnectionWithOptions:(NSDictionary *)options
{
    return nil;
}

// A control point should call the ConnectionComplete action for all connections that it created  via
// PrepareForConnection to ensure that all resources associated with the connection are freed up
- (void)ConnectionCompleteForConnectionID:(NSString *)connectionID
{
    
}

// Returns a comma-separated list of ConnectionIDs of currently ongoing Connections
- (NSString *)GetCurrentConnectionIDs
{
    return nil;
}

// Returns associated information of the connection referred to by the ‘ConnectionID’ parameter.
- (NSString *)GetCurrentConnectionInfoForConnectionID:(NSString *)connectionID
{
    return nil;
}

@end
