//
//  HTTPServiceManager.h
//
//  You can register your HTTP service with the service manager
//  and HTTPConnection will query your registered service URL for
//  a response.
//
//  Created by Patrick Denney on 10/4/11.
//

#import <Foundation/Foundation.h>
#import "HTTPService.h"

@interface HTTPServiceManager : NSObject
{
    NSMutableArray *_registeredServices;
}

+ (id)sharedInstance;

// Register your service with the service manager
- (void)registerService:(id<HTTPService>)service;

// Unregister your service from receiving events
- (void)unRegisterService:(id<HTTPService>)service;

// Check to see if the service manager supports the service URL
- (BOOL)serviceURLIsSupported:(NSString *)serviceURL;

// If the service is supported, retrieve the response message
- (NSString *)SOAPresponseForServiceRequest:(NSString *)SOAPrequest forServiceURL:(NSString *)serviceURL;

@end
