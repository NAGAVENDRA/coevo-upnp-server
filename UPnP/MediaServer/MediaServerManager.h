//
//  MediaServerManager.h
//  This is a media server implementation that uses Universal Plug and Play (UPnP) to announce itself over the network using HTTPU multicasting. 
//  It provides the following 3 services as defined by UPnP standards:
//      urn:schemas-upnp-org:service:ConnectionManager:1
//      urn:schemas-upnp-org:service:ContentDirectory:1
//      urn:schemas-upnp-org:device:MediaServer:1
//
//  More information about these services can be found at:
//  http://www.upnp.org
// 
//  Created by Patrick Denney on 8/13/11.
//

#import <Foundation/Foundation.h>
#import "SSDP.h"
#import "HTTPService.h"

@interface MediaServerManager : NSObject <SSDPDelegate, HTTPService>
{
    // Array of services conforming to the UPnPService protocol
    NSArray *_upnpServices;
}

+ (id)sharedInstance;

// Loads up the protocol stack and starts broadcasting the media server.
- (void)startMediaServer;

// Breaks down the protocol stack and sends the appropriate messages, stopping the media server.
- (void)stopMediaServer;

@end
