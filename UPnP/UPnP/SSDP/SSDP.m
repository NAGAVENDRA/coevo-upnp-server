//
//  SSDP.m
//
//  Created by Patrick Denney on 8/7/11.
//

#import "SSDP.h"
#include "NSString+UPnP.h"
#import "NSMutableString+UPnP.h"
#import "NSObject+UPnP.h"
#import "HTTPServer.h"
#import <libxml/parser.h>
#include "DDLog.h"
#include "HTTPConnection.h"
#include "UIDevice+UPnP.h"

#define NOTIFY_HEADER @"NOTIFY * HTTP/1.1\r\n"
#define HTTP_PORT 5055

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_INFO;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@interface SSDP()
@property (nonatomic, retain, readwrite) NSArray *servicesProvided;
@end

@implementation SSDP

@synthesize UUID = _UUID;
@synthesize servicesProvided = _servicesProvided;
@synthesize delegate = _delegate;

static SSDP *sharedInstance;

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

- (void)setupSocket
{
    // Setup a sending socket to 239.255.255.250 to broadcast any services
    if (ssdpSocket) 
    {
        [ssdpSocket release];
        ssdpSocket = nil;
    }
    ssdpSocket = [[AsyncUdpSocket alloc] init];
    [ssdpSocket setDelegate:self];
    
    // Bind to a multicast group on 239.255.255.250 to receive any service requests
    if (multicastSsdpSocket) 
    {
        [multicastSsdpSocket release];
        multicastSsdpSocket = nil;
    }
    multicastSsdpSocket = [[AsyncUdpSocket alloc] init];
    [multicastSsdpSocket setDelegate:self];
    
    NSError *connectionError = nil;
    [ssdpSocket connectToHost:@"239.255.255.250" onPort:1900 error:&connectionError];
    if (connectionError) 
    {
        DDLogError(@"An error occuring while attempting to open a connection on 239.255.255.250.");
        NSException *multicastException = [NSException exceptionWithName:@"SSDP Connecton Error"
                                                                  reason:@"Unable to connect to network at 239.255.255.250:1900."
                                                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:        [NSNumber numberWithInt:CONNECTION_ERROR],
                                                                          @"ExceptionCode", connectionError, @"Error", nil]];
        [multicastException raise];
    }
    
    DDLogInfo(@"Attempting to bind to 239.255.255.250:1900 to recieve SSDP communications...");
    NSError *bindError = nil;
    [multicastSsdpSocket bindToAddress:@"239.255.255.250" port:1900 error:&bindError];
    if (bindError) 
    {
        DDLogError(@"An error occuring while binding to 239.255.255.250:1900.");
        NSException *multicastException = [NSException exceptionWithName:@"SSDP Connecton Error"
                                                                  reason:@"Unable to bind to network at 239.255.255.250:1900."
                                                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:        [NSNumber numberWithInt:BINDING_ERROR],
                                                                          @"ExceptionCode", bindError, @"Error", nil]];
        [multicastException raise];
    }
    
    DDLogInfo(@"Binded to 239.255.255.250:1900 for SSDP communications.");
    
    // Join the multiple cast group to listen to SSDP queries
    NSError *multicastError = nil;
    [multicastSsdpSocket joinMulticastGroup:@"239.255.255.250" error:&multicastError];
    if (multicastError) 
    {
        DDLogError(@"An error occuring while attempting to open the device definition.");
        NSException *multicastException = [NSException exceptionWithName:@"Multicast Subscription Error"
                                                                  reason:@"Unable to join the SSDP multicast group."
                                                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:        [NSNumber numberWithInt:MULTI_JOIN_ERROR],
                                                                    @"ExceptionCode", multicastError, @"Error", nil]];
        [multicastException raise];
    }
}

- (void)tearDownSocket
{
    // Tear down any open sockets
    [ssdpSocket closeAfterSending];
    [ssdpSocket release];
    [multicastSsdpSocket closeAfterReceiving];
    [multicastSsdpSocket release];
    ssdpSocket = nil;
    multicastSsdpSocket = nil;
}

- (void)moveOverServiceDefinitions
{
    // Move over the remaining service definitions into the shared documents directory to be referenced by the web server.
    NSString *basePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DEV_DEF_DIR];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:basePath])
    {
        DDLogError(@"An error occuring while attempting to open the service definition folder.");
        NSException *noDirException = [NSException exceptionWithName:@"Missing Directory"
                                                              reason:@"Service definition folder used by SSDP is missing. Cannot continue."
                                                            userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:DEV_SER_MISSING] forKey:@"ExceptionCode"]];
        [noDirException raise];
        return;
    }
    
    NSError *error = nil;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:&error];
    if (error) 
    {
        NSLog(@"Error occured while attempting to get list of service definitions. %@", error);
        NSException *noServicesException = [NSException exceptionWithName:@"Missing Service Definitions"
                                                                   reason:@"Service definition files used by SSDP are missing. Cannot continue."
                                                                 userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:DEV_SER_MISSING] forKey:@"ExceptionCode"]];
        [noServicesException raise];
        return;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    for (NSString *definition in files) 
    {
        if ([[definition lowercaseString] isEqualToString:DEV_DEF_FILENAME]) 
        {
            continue;
        }
        
        DDLogInfo(@"Copying over service definition %@ to the shared directory.", definition);
        
        NSString *readPath = [basePath stringByAppendingPathComponent:definition];
        NSString *savePath = [documentsDirectory stringByAppendingPathComponent:definition];

        NSError *copyError = nil;
        if ([[NSFileManager defaultManager] fileExistsAtPath:savePath]) 
        {
            [[NSFileManager defaultManager] removeItemAtPath:savePath error:nil];
        }
        [[NSFileManager defaultManager] copyItemAtPath:readPath toPath:savePath error:&copyError];
        
        if (copyError) 
        {
            NSLog(@"Error occured while attempting to copy over service definition to shared directory. %@", copyError);
            NSException *fileException = [NSException exceptionWithName:@"Failed Service Definitions Copy"
                                                                 reason:@"Service definition files used by SSDP cannot be copied. Cannot continue."
                                                               userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:DEV_SER_MISSING] forKey:@"ExceptionCode"]];
            [fileException raise];
            return;
        }
    }
    
}

- (void)updateDocumentWithCurrentIPAddress
{
    [self moveOverServiceDefinitions];
    
    // Read device definition XML file
    NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@", DEV_DEF_DIR, DEV_DEF_FILENAME]];
    
    // Documents is a special folder we are allow to write to.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savePath = [documentsDirectory stringByAppendingPathComponent:DEV_DEF_FILENAME];
    
    DDLogInfo(@"Opening up device xml definition to document current IP address.");
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
       DDLogError(@"An error occuring while attempting to open the device definition.");
       NSException *noFileException = [NSException exceptionWithName:@"Missing File"
                                                              reason:@"Device definition used by SSDP is missing. Cannot continue."
                                                            userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:DEV_DEF_MISSING] forKey:@"ExceptionCode"]];
        [noFileException raise];
    }
    
    // Attempt to open the device definition
    NSError *fileReadError = nil;
    NSString *deviceDefinition = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&fileReadError];
    if (fileReadError) 
    {
        DDLogError(@"Unable to load device definition record.");
        NSException *readFileException = [NSException exceptionWithName:@"File Read Error"
                                                                 reason:@"Device definition used by SSDP cannot be read. Cannot continue."
                                                               userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:DEV_DEF_BAD] forKey:@"ExceptionCode"]];
        [readFileException raise];  
    }
    
    // Update file to reflect the current IP address
    NSString *currentIPAddress = [UIDevice currentIPAddress];
    NSRange locationOfTag = [deviceDefinition rangeOfString:@"<URLBase>"];
    NSRange locationOfEndTag = [deviceDefinition rangeOfString:@"</URLBase>"];
    if ((locationOfTag.location == NSNotFound) || (locationOfEndTag.location == NSNotFound)) 
    {
        DDLogError(@"Unable to find location of URLBase tag in device definition.");
        NSException *readFileException = [NSException exceptionWithName:@"File Read Error"
                                                                 reason:@"Device definition used by SSDP is corrupt and cannot be read. Cannot continue."
                                                               userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:DEV_DEF_BAD] forKey:@"ExceptionCode"]];
        [readFileException raise];
        // TODO: can do some recovery method here to see if the rest of the data is correct or not and maybe 
        // inject a new <URLBase> tag if not
    }
    
    NSString *httpAddress = [NSString stringWithFormat:@"http://%@:%i/", currentIPAddress, HTTP_PORT];
    DDLogInfo(@"Updating IP address in device definition to %@", httpAddress);
    NSRange replacementRange = NSMakeRange(locationOfTag.location+locationOfTag.length,
                                           locationOfEndTag.location-(locationOfTag.location+locationOfTag.length));
    NSString *updatedDeviceDefinition = [deviceDefinition stringByReplacingCharactersInRange:replacementRange
                                                                                  withString:httpAddress];
    DDLogInfo(@"Updated device definition to new device definition %@",updatedDeviceDefinition);
    
    // Write to the device definition file with the updated HTTP server URL
    NSError *writeError = nil;
    
    // Create the new device definition file if it doesn't already exists or update the old one.
    if (![[NSFileManager defaultManager] fileExistsAtPath:savePath]) 
    {
        if (![[NSFileManager defaultManager] createFileAtPath:savePath 
                                                     contents:[updatedDeviceDefinition dataUsingEncoding:NSUTF8StringEncoding]
                                                   attributes:nil]) 
        {
            writeError = [NSError errorWithDomain:@"Error creating device definition file." code:4 userInfo:nil];
        }
    }
    else
    {
        [updatedDeviceDefinition writeToFile:savePath atomically:NO encoding:NSUTF8StringEncoding error:&writeError];
    }

    if (writeError) 
    {
        DDLogError(@"Unable to save to device definition record.");
        NSException *writeFileException = [NSException exceptionWithName:@"File Write Error"
                                                                  reason:@"Unable to save update device definition record."
                                                                userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:DEV_DEF_WRITE_ERR]  forKey:@"ExceptionCode"]];
        [writeFileException raise];
    }
}

// Start up an HTTP server we can use to broadcase the XML definition of the device for SSDP
- (void)startHTTPServerWithConnectionClass:(Class)connectionClass
{
    // Create server
    if (httpServer) 
    {
        [httpServer release];
        httpServer = nil;
    }
	httpServer = [[HTTPServer alloc] init];
	[httpServer setType:@"_http._tcp."];
    [httpServer setConnectionClass:connectionClass];
	[httpServer setPort:5055];
	
	// Serve files from our shared documents folder
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *webPath = [paths objectAtIndex:0];
	DDLogInfo(@"Setting document root: %@", webPath);
	
	[httpServer setDocumentRoot:webPath];
	
	// Start the server (and check for problems)
	NSError *error = nil;
	if(![httpServer start:&error])
	{
		DDLogError(@"Error starting HTTP Server: %@", error);
	}
}

// Stop broadcasting the service device definition
- (void)stopHTTPServer
{
    DDLogInfo(@"Stopping SSDP HTTP server.");
    [httpServer stop];
    [httpServer release];
    httpServer = nil;
    
}

// This will build up a broadcast message for all services and publish them over HTTPU to 239.255.255.250:1900 
// Any clients that are listening for the services can respond with queries for each service provided by the device.
- (void)sendBroadcastMessage
{
    if (!serviceRunning) 
    {
        return;
    }

    //use HTTP NOTIFY multicast to notify clients of our presence
    if (!serviceBroadcastMessages) 
    {
        NSString *UUIDString = [NSString stringWithFormat:@"uuid:%@",self.UUID];
        NSString *broadcastURL = [NSString stringWithFormat:@"http://%@:%i/%@", [UIDevice currentIPAddress], HTTP_PORT,DEV_DEF_FILENAME];
        DDLogInfo(@"Broadcasting device defintion at %@.", broadcastURL);
        NSString *broadcastLocation = [NSString stringWithFormat:@"LOCATION: %@", broadcastURL];
        NSString *serverString = [NSString stringWithFormat:@"SERVER: iOS/%@ UPnP/1.0 UPnP-Device-Host/1.0", [[UIDevice currentDevice] systemVersion]];
        serviceBroadcastMessages = [[NSMutableArray alloc] initWithCapacity:5];

        // Root Device
        DDLogInfo(@"Adding root device info to broadcast message.");
        NSMutableString *serviceBroadcastMessage = [NSMutableString stringWithString:NOTIFY_HEADER];
        [serviceBroadcastMessage appendServerResponseString:@"HOST: 239.255.255.250:1900"];
        [serviceBroadcastMessage appendServerResponseString:@"NT: upnp:rootdevice"];
        [serviceBroadcastMessage appendServerResponseString:@"NTS: ssdp:alive"];
        [serviceBroadcastMessage appendServerResponseString:broadcastLocation];
        [serviceBroadcastMessage appendServerResponseString:[NSString stringWithFormat:@"USN: %@::upnp:rootdevice", UUIDString]];
        [serviceBroadcastMessage appendServerResponseString:@"CACHE-CONTROL: max-age=1800"];
        [serviceBroadcastMessage appendServerResponseString:serverString];
        [serviceBroadcastMessage appendString:@"\r\n"];
        [serviceBroadcastMessages  addObject:serviceBroadcastMessage];
        
        serviceBroadcastMessage = [NSMutableString stringWithString:NOTIFY_HEADER];
        [serviceBroadcastMessage appendServerResponseString:@"HOST: 239.255.255.250:1900"];
        [serviceBroadcastMessage appendServerResponseString:[NSString stringWithFormat:@"NT: %@", UUIDString]];
        [serviceBroadcastMessage appendServerResponseString:@"NTS: ssdp:alive"];
        [serviceBroadcastMessage appendServerResponseString:broadcastLocation];
        [serviceBroadcastMessage appendServerResponseString:[NSString stringWithFormat:@"USN: %@", UUIDString]];
        [serviceBroadcastMessage appendServerResponseString:@"CACHE-CONTROL: max-age=1800"];
        [serviceBroadcastMessage appendServerResponseString:serverString];
        [serviceBroadcastMessage appendString:@"\r\n"];
        [serviceBroadcastMessages  addObject:serviceBroadcastMessage];
        
        // Loop over provided services and add them to the broadcast message
        for (NSString *service in self.servicesProvided) 
        {
            DDLogInfo(@"Adding service %@ to broadcast message.", service);
            serviceBroadcastMessage = [NSMutableString stringWithString:NOTIFY_HEADER];
            [serviceBroadcastMessage appendServerResponseString:@"HOST: 239.255.255.250:1900"];
            [serviceBroadcastMessage appendServerResponseString:[NSString stringWithFormat:@"NT: %@", service]];
            [serviceBroadcastMessage appendServerResponseString:@"NTS: ssdp:alive"];
            [serviceBroadcastMessage appendServerResponseString:broadcastLocation];
            [serviceBroadcastMessage appendServerResponseString:[NSString stringWithFormat:@"USN: %@::%@", UUIDString, service]];
            [serviceBroadcastMessage appendServerResponseString:@"CACHE-CONTROL: max-age=1800"];
            [serviceBroadcastMessage appendServerResponseString:serverString];
            [serviceBroadcastMessage appendString:@"\r\n"];
            [serviceBroadcastMessages  addObject:serviceBroadcastMessage];
        }
    }
    
    DDLogInfo(@"Sending SSDP broadcast messages.");
    for (NSString *serviceBroadcastMessage in serviceBroadcastMessages) 
    {
        NSData *broadcastData = [serviceBroadcastMessage dataUsingEncoding:NSUTF8StringEncoding];
        [ssdpSocket sendData:broadcastData withTimeout:900 tag:0];
    }
    [multicastSsdpSocket receiveWithTimeout:1800 tag:0];
    [self performSelector:@selector(sendBroadcastMessage) withObject:nil afterDelay:900];
}

// This will broadcast a message notifying all listeners that the device will no longer be providing the aforementioned services.
- (void)sendCancelBroadcastMessage
{
    if (!serviceBroadcastMessages || !ssdpSocket) 
    {
        DDLogWarn(@"Attempting to send byebye broadcast SSDP message with invalid socket or invalid broadcast messages.");
        return;
    } 
    
    // Resend all the broadcast messages but with a SSDP of byebye to notify clients that we are shutting down
    DDLogInfo(@"Broadcasting ssdp:byebye message before terminating services.");
    for (NSString *serviceBroadcastMessage in serviceBroadcastMessages) 
    {
        serviceBroadcastMessage = [serviceBroadcastMessage stringByReplacingOccurrencesOfString:@"ssdp:alive" withString:@"ssdp:byebye"];
        NSData *broadcastData = [serviceBroadcastMessage dataUsingEncoding:NSUTF8StringEncoding];
        [ssdpSocket sendData:broadcastData withTimeout:900 tag:0];
    }
}

// Provided with a set of services, setup any socket connections and start broadcasting them.
- (void)startServiceBroadcastWithServices:(NSArray *)services withConnectionClass:(Class)connectionClass
{
    if (!connectionClass) 
    {
        connectionClass = [HTTPConnection class];
    }
    
    // Update the base URL used for querying the services
    [self updateDocumentWithCurrentIPAddress];
    
    self.servicesProvided = services;
    DDLogInfo(@"Start broadcasting SSDP message.");
    
    // Setup the multicast send/receive sockets
    [self setupSocket];
    
    // Starts up the HTTP server used to give the device definition to the client
    [self startHTTPServerWithConnectionClass:connectionClass];
    serviceRunning = YES;
    [self sendBroadcastMessage];
    
    if ([self.delegate respondsToSelector:@selector(didStartBroadcastingServices)]) 
    {
        [self.delegate didStartBroadcastingServices];
    }
}

// Stop broadcasting any services and tear down any open sockets.
- (void)stopServiceBroadcast
{
    DDLogInfo(@"Stop broadcasting SSDP message.");
    serviceRunning = NO;
    @try 
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
    @catch (NSException *exception) 
    {
        //Ignore any exceptions
    }
    [self sendCancelBroadcastMessage];
    [self tearDownSocket];
    serviceBroadcastMessages = nil;
    
    if ([self.delegate respondsToSelector:@selector(didStopBroadcastingServices)]) 
    {
        [self.delegate didStopBroadcastingServices];
    }
}

- (id)init
{
    self = [super init];
    if (self) 
    {
        self.servicesProvided = [NSArray array];
        self.UUID = @"";
    }
    
    return self;
}

- (void)respondToQuery:(NSDictionary *)headerInformation
{
    //response to query to services (M-SEARCH request)
    // This is a service request, we should respond if we have the service they are looking for.
    NSString *requestedService = [headerInformation objectForKey:@"ST"];
    if (requestedService) 
    {
        // Search our broadcasting services for one requested
        for (NSString *service in self.servicesProvided) 
        {
            if ([service isEqualToString:requestedService]) 
            {
                // We have the service they are requesting. Rebroadcast out services
                [self sendBroadcastMessage];
                break;
            }
        }
    }
    
    // Notify the delegate about the client requesting the information
    if ([self.delegate respondsToSelector:@selector(didReceiveSearchFromClient:)]) 
    {
        [self.delegate didReceiveSearchFromClient:[headerInformation objectForKey:@"X-AV-Client-Info"]];
    }
}

- (void)dealloc
{
    [serviceBroadcastMessages release];
    self.servicesProvided = nil;
    self.UUID = nil;
    
    [super dealloc];
}

// ************************************************************************************************
#pragma mark Async-UDP socket delegate methods
// ************************************************************************************************

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    DDLogInfo(@"Sent broadcast message.");
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    DDLogError(@"Error sending broadcast message.");
    //TODO: Add error handling here to check wifi status and reschedule a broadcast
    
    if ([self.delegate respondsToSelector:@selector(errorSendingPackets)]) 
    {
        [self.delegate errorSendingPackets];
    }
}

// Called when we recieve information from the multicast group.  Return NO to identicate that we ignored the packet.
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    BOOL usedPacket = NO;
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    DDLogInfo(@"Received the following response: %@", dataString);
    
    // Parse out the HTTP header information and check to see if we should respond to the request
    NSDictionary *headerInformation = [dataString parseHTTTPHeaderInformation];
    if ([[headerInformation objectForKey:@"Response Method"] isEqualToString:@"M-SEARCH"]) 
    {
        [self respondToQuery:headerInformation];
        usedPacket = YES;
    }
    
    [dataString release];
    return usedPacket;
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{
    DDLogWarn(@"Error receiving data: %@", error.localizedDescription);
    //TODO: Add error handling here.
    
    if ([self.delegate respondsToSelector:@selector(errorReceivingPackets)]) 
    {
        [self.delegate errorReceivingPackets];
    }
}

- (void)onUdpSocketDidClose:(AsyncUdpSocket *)sock
{
    if (serviceRunning) 
    {
        DDLogError(@"UDP socket closed too early.");
    }
}

@end
