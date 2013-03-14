//
//  ConnectionManagerService.h
//  UPnP
//
//  This is an objective-c representation of the UPnP connection directory service.
//  Clients use this service on both ends as either the stream receiver or sender.
//  Both clients must support information about which stream protocols they support
//  and what state they are in. 
//  The service specifications can be found here:
//  http://upnp.org/specs/av/UPnP-av-ConnectionManager-v1-Service.pdf
// 
//  Created by Patrick Denney on 9/28/11.
//

#import <Foundation/Foundation.h>
#import "UPnPService.h"

@interface ConnectionManagerService : NSObject <UPnPService>

// Returns the protocol-related info that this ConnectionManager supports in its current state
- (NSString *)getProtocolInfo;

// This action is used to allow the device to prepare itself  to connect to the  
// network for  the  purposes  of sending or receiving media content (e.g. a video stream).
//
// options should contain the following entries:
//      "RemoteProtocolInfo"    = the protocol, network, and format that should be used to transfer the content
//      "PeerConnectionManager" = A ConnectionManager reference takes the form of a UDN/Service-Id pair (the slash is the delimiter). 
//                                A control point can use UPnP discovery (SSDP) to obtain a ConnectionManager’s description 
//                                document from the UDN.
//      "PeerConnectionID"      = identifies the specific connection on that ConnectionManager service
//      "Direction"             = Content direction either  “Output” or “Input”
- (NSString *)prepareForConnectionWithOptions:(NSDictionary *)options;

// A control point should call the ConnectionComplete action for all connections that it created  via 
// PrepareForConnection to ensure that all resources associated with the connection are freed up
- (void)ConnectionCompleteForConnectionID:(NSString *)connectionID;

// Returns a comma-separated list of ConnectionIDs of currently ongoing Connections
- (NSString *)GetCurrentConnectionIDs;

// Returns associated information of the connection referred to by the ‘ConnectionID’ parameter.
- (NSString *)GetCurrentConnectionInfoForConnectionID:(NSString *)connectionID;

@end
