//
//  SSDP.h
//
//  This is an implementation of the Simple Service Discovery Protocol (SSDP).
//  SSDP is a part of the Universal Plug and Play (UPnP) protocol stack and used as the starting point
//  to broadcast out the availability of any device provided service over 239.255.255.250:1900 as a multicast
//  message.  More information about SSDP can be found here:
//  http://www.upnp.org/specs/arch/UPnP-arch-DeviceArchitecture-v1.1.pdf
//
//  Created by Patrick Denney on 8/7/11.
//  Copyright 2011 . All rights reserved.
//

#import <Foundation/Foundation.h>
#include "AsyncUdpSocket.h"
#include "HTTPServer.h"

// This is the resources directory that will service as the base directory for device definition file and service definitions. 
// It shoud be changed to reflect the current directory of the device definition.
#define DEV_DEF_DIR @"Definition"

// This is the device definition filename that is used for in the LOCATION: space for the broadcast request. It
// should be changed to reflect the current name of the device definition file
#define DEV_DEF_FILENAME @"device.xml"  

// *****************************************************************************************
// Error message codes found in the userInfo under "ExceptionCode" for any raised exceptions
// *****************************************************************************************
#define CONNECTION_ERROR  500    // Error making a socket connection
#define BINDING_ERROR     501    // Error binding to the multicast group to receive messages
#define MULTI_JOIN_ERROR  502    // Error while joining the multicast group
#define DEV_DEF_MISSING   503    // The device definition file is missing from the project or cannot be found
#define DEV_SER_MISSING   504    // The service definition files are missing
#define DEV_DEF_BAD       505    // The device definition is bad or malformed and cannot be read
#define DEV_DEF_WRITE_ERR 506    // There are permission problems with the device definition file and it cannot be overwritten.

// *****************************************************************************************
// Delegate Methods
// *****************************************************************************************
@protocol SSDPDelegate <NSObject>

@required 

// When a service request comes in that the delegate is able to handle, it should handle the request and reply with a YES.  If the service in unable to be handled by the dictionary, then it should response with a NO.
- (BOOL)handleServiceRequest:(NSString *)serviceRequest;

@optional

// Called when the services start broadcasting themselves out over SSDP
- (void)didStartBroadcastingServices;

// Called when the services are stopped from broadcasting
- (void)didStopBroadcastingServices;

// If the a client searches for services, this will return the X-AV-Client-Info: information from the HTTP header
- (void)didReceiveSearchFromClient:(NSString *)clientString;

// Called when an error occurs during the receiving of packets from the network
// These errors should be handled higher up in the application by notifying the user of 
// the lost packets.
- (void)errorReceivingPackets;

// Called when there was an error sending out some packets. 
// These errors should be handled higher up in the application by notifying the user of
// the error. 
- (void)errorSendingPackets;

@end

@interface SSDP : NSObject <AsyncUdpSocketDelegate>
{
    NSMutableArray *serviceBroadcastMessages;
    NSArray *_servicesProvided;
    NSString *_UUID;
    id<SSDPDelegate> _delegate;
    
    // This socket is used to sent a multicast message to 239.255.255.250:1900 over HTTPU for provided services
    AsyncUdpSocket *ssdpSocket;
    
    // This socket is used to register to the multicast group and recieve and respond to any request for services
    AsyncUdpSocket *multicastSsdpSocket;
    
    // This HTTP server is setup to contain the full device definition xml record that is listened in the service 
    // broadcast for each service
    HTTPServer *httpServer;
    
    BOOL serviceRunning;
}

// Delegate that can recieve notifications about the state of the service broadcaster.
@property (nonatomic, assign)  id<SSDPDelegate> delegate;

// This is a unique identifer used for the device inside of the device definition file. 
// Please see SSDP specs for information on the formatting but it must be unique for all the devices
// on the network. (e.x. cc93dae6-6b8b-4260-87c9-228c36b5b0e8)
@property (nonatomic, retain) NSString *UUID;

// This is a list of services provided by the device.
// e.x.
//   urn:schemas-upnp-org:service:ConnectionManager:1
//   urn:schemas-upnp-org:service:ContentDirectory:1
//   urn:schemas-upnp-org:device:MediaServer:1
@property (nonatomic, retain, readonly) NSArray *servicesProvided;

+ (id)sharedInstance;

// Starts broadcasting the SSDP services on 239.255.255.250:1900 over HTTPU
// connectionClass should be your subclass of HTTPConnection in which you are responsible
// for handling incoming request to the HTTP server for services.
- (void)startServiceBroadcastWithServices:(NSArray *)services withConnectionClass:(Class)connectionClass;

// Stops broadcasting the SSDP services
- (void)stopServiceBroadcast;

@end
