//
//  MediaServerManager.m
//  UPnP
//
//  Created by Patrick Denney on 8/13/11.
//

#import "MediaServerManager.h"
#import "DDLog.h"
#import "ContentDirectoryService.h"
#import "ConnectionManagerService.h"
#import "UPnPService.h"
#import "HTTPServiceManager.h"
#import "ContentDirectoryServiceErrorCodes.h"
#import "NSString+UPnP.h"

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_INFO;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@implementation MediaServerManager

static MediaServerManager *sharedInstance;

+ (id)sharedInstance
{
    if (!sharedInstance) 
    {
        @synchronized(self)
        {
            sharedInstance = [[self alloc] init];  
        }
    }
    return sharedInstance;
}

- (id)init
{
    if ((self = [super init])) 
    {
        ConnectionManagerService *connectionService = [[ConnectionManagerService alloc] init];
        ContentDirectoryService *directoryService = [[ContentDirectoryService alloc] init];
        
        _upnpServices = [[NSArray alloc] initWithObjects:connectionService, directoryService, nil];
    }
    
    return self;
}
- (void)startMediaServer
{
    DDLogInfo(@"Registering media server as a web service...");
    [[HTTPServiceManager sharedInstance] registerService:self];
    
    DDLogInfo(@"Starting media server...");
    [[SSDP sharedInstance] setUUID:@"cc93dae6-6b8b-4260-87c9-228c36b5b0e8"];
    NSArray *services = [NSArray arrayWithObjects:@"urn:schemas-upnp-org:device:MediaServer:1",
                                                  @"urn:schemas-upnp-org:service:ConnectionManager:1",
                                                  @"urn:schemas-upnp-org:service:ContentDirectory:1",nil];
    [[SSDP sharedInstance] startServiceBroadcastWithServices:services withConnectionClass:nil];
    DDLogInfo(@"Media server started.");
}

- (void)stopMediaServer
{
    DDLogInfo(@"Stoping media server...");
    [[SSDP sharedInstance] stopServiceBroadcast];
    DDLogInfo(@"Media server stopped.");
    
    DDLogInfo(@"Unregistering media server as a web service...");
    [[HTTPServiceManager sharedInstance] unRegisterService:self];
}

// ************************************************************************************************
#pragma mark SSDPDelegate
// ************************************************************************************************

- (BOOL)handleServiceRequest:(NSString *)serviceRequest
{
    return NO;
}

- (void)didStartBroadcastingServices
{
    //TODO: update the UI
}

- (void)didStopBroadcastingServices
{
    //TODO: update the UI
}

- (void)errorReceivingPackets
{
    //TODO: update the UI with the error
}

- (void)errorSendingPackets
{
    //TODO: update the UI with the error
}

- (void)didReceiveSearchFromClient:(NSString *)clientString
{
    
}

// ************************************************************************************************
#pragma mark HTTPService
// ************************************************************************************************

- (NSArray *)serviceURLs
{
    // Collect up and return the URLs of our UPnP web services
    NSMutableArray *serviceURLs = [[NSMutableArray alloc] initWithCapacity:(_upnpServices.count*2)];
    
    for (id<UPnPService> service in _upnpServices) 
    {
        [serviceURLs addObject:[service controlURL]];
        [serviceURLs addObject:[service eventURL]];
    }
    
    return serviceURLs;
}

- (NSString *)responseForSeviceRequestURL:(NSString *)url withPayload:(NSString *)soapMessage
{
    NSString *response = @"";
    for (id<UPnPService> service in _upnpServices) 
    {
        if ([[service controlURL] isEqualToString:url])
        {
            response = [service responseForControlAction:soapMessage];
            break;
        }
        else if([[service eventURL] isEqualToString:url])
        {
            response = [service responseForEventVariable:soapMessage];
            break;
        }
    }
    
    if (!response) 
    {
        NSString *errorMessage = [NSString upnpErrorMessageWithCode:CANNOT_PROCESS
                                                     andDescription:CANNOT_PROCESS_DESC
                                                          forSchema:@"urn:schemas-upnp-org:device:MediaServer:1"];
        return [errorMessage stringAsSoapMessage];
    }
    return response;
}

@end
