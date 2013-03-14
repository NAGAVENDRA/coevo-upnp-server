//
//  ContentDirectoryService.m
//  UPnP
//
//  Created by Patrick Denney on 8/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ContentDirectoryService.h"
#import "NSString+UPnP.h"
#import "NSString+HTML.h"
#import "SharedDefinitions.h"
#import "ContentDirectoryServiceErrorCodes.h"
#import "FileManager.h"
#import "DDLog.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"

#import "GDataXMLElement.h"

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_INFO;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@implementation ContentDirectoryService

static int systemUpdateID = 0;

- (id)init
{
    self = [super init];
    if (self) 
    {
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(systemUpdated) 
                                                     name:kSystemUpdated 
                                                   object:nil];
        _systemUpdateID = systemUpdateID++;
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (void)systemUpdated
{
    _systemUpdateID = systemUpdateID++;
}

// This action returns the searching capabilities that are supported by the device.
- (NSString *)getSearchCapabilities
{
    // Don't support searching for now
    NSMutableString *response = [NSMutableString string];
    [response appendFormat:@"<u:GetSearchCapabilitiesResponse xmlns:u=\"%@\">", [self serviceSchema]];
    [response appendString:@"<SearchCap></SearchCap>"];
    [response appendString:@"</u:GetSearchCapabilitiesResponse>"];
    
    return response;
}

// Returns a comma-seperated list of meta-data tags that can be used in sortCriteria
- (NSString *)getSortCapabilities
{
    // Don't support sorting for now
    NSMutableString *response = [NSMutableString string];
    [response appendFormat:@"<u:GetSortCapabilitiesResponse xmlns:u=\"%@\">", [self serviceSchema]];
    [response appendString:@"<SortCap></SortCap>"];
    [response appendString:@"</u:GetSortCapabilitiesResponse>"];
    
    return response;
}

// This action returns the current value of state variable SystemUpdateID. It can be used by clients that want to ‘poll’ 
// for any changes in the Content Directory (as opposed to subscribing to events)
- (NSString *)getSystemUpdateID
{
    NSMutableString *response = [NSMutableString string];
    [response appendFormat:@"<u:GetSystemUpdateIDResponse xmlns:u=\"%@\">", [self serviceSchema]];
    [response appendFormat:@"<Id>%d</Id>", _systemUpdateID];
    [response appendString:@"</u:GetSystemUpdateIDResponse>"];
    
    return response;
}

// This action allows the caller to incrementally browse the native hierarchy of the Content Directory objects exposed by 
// the Content Directory Service, including information listing the classes of objects available in any particular object 
// container.
//
// options should contain the following entries:
//      "￼￼ObjectID" = parameter to identify object within the Content Directory Service
//      "BrowseFlag" = BrowseMetadata - this indicates that the properties of the object specified by the ObjectID 
//                     parameter will be returned in the result. OR
//                     BrowseDirectChildren - this indicates that first level objects under the object specified by 
//                     ObjectID parameter will be returned in the result, as well as the metadata of all objects 
//                     specified.
//      "Filter" =     See 2.5.7. A_ARG_TYPE_Filter in the service specs (Ignored for now)
//      "StartingIndex" = This variable is used in conjunction with those actions that include an Index parameter. Index 
//                        parameters specify an offset into an arbitrary list of objects. Starts a 0.
//      "RequestedCount" = Count parameters specify an ordinal number of arbitrary objects.
//      "SortCriteria" = See 2.5.8. A_ARG_TYPE_SortCriteria in the service specs  (Ignored for now)
- (NSString *)browseWithOptions:(NSDictionary *)options
{
    // Fix nil bug?
    int intObjectID = [[options objectForKey:@"ObjectID"] integerValue];
    NSString *objectID = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%d", intObjectID]];
    int returnCount,totalCount;
    
    NSLog(@"browse options = %@", options);
    NSString *container = [[FileManager sharedInstance] browseWithObjectID:objectID
                                                        withDirectChildren:[[options objectForKey:@"BrowseFlag"] isEqualToString:@"BrowseDirectChildren"]
                                                         forRequestedCount:[[options objectForKey:@"RequestedCount"] intValue]
                                                         withStartingIndex:[[options objectForKey:@"StartingIndex"] intValue]
                                                               returnCount:&returnCount
                                                                totalCount:&totalCount];
    
    // TODO : totalCount for?
    totalCount = returnCount;
    
    // Response for the browse command should be in the format:
    // Browse (DIDL-Lite response, number returned, number matched, unique system ID (or container ID if supported))
    NSMutableString *response = [NSMutableString string];
    [response appendFormat:@"<u:BrowseResponse xmlns:u=\"%@\">", [self serviceSchema]];
    [response appendFormat:@"<Result>%@</Result>", [container stringByEncodingHTMLEntities]];
    [response appendFormat:@"<NumberReturned>%d</NumberReturned>", returnCount];
    [response appendFormat:@"<TotalMatches>%d</TotalMatches>", totalCount];
    [response appendFormat:@"<UpdateID>%d</UpdateID>", 1];
    [response appendString:@"</u:BrowseResponse>"];
    
    
//    NSLog(@"%@ container", container);
//    container = @"&lt;DIDL-Lite xmlns=&quot;urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/&quot; xmlns:dc=&quot;http://purl.org/dc/elements/1.1/&quot; xmlns:upnp=&quot;urn:schemas-upnp-org:metadata-1-0/upnp/&quot; xmlns:sec=&quot;http://www.sec.co.kr/&quot; xmlns:dlna=&quot;urn:schemas-dlna-org:metadata-1-0/&quot;&gt;&lt;container id=&quot;21&quot;  parentID=&quot;0&quot;  restricted=&quot;1&quot;&gt;&lt;dc:title&gt;音樂&lt;/dc:title&gt;&lt;upnp:class&gt;object.container&lt;/upnp:class&gt;&lt;/container&gt;&lt;container id=&quot;32&quot;  parentID=&quot;0&quot;  restricted=&quot;1&quot;&gt;&lt;dc:title&gt;照片&lt;/dc:title&gt;&lt;upnp:class&gt;object.container.storageFolder&lt;/upnp:class&gt;&lt;upnp:storageUsed&gt;-1&lt;/upnp:storageUsed&gt;&lt;/container&gt;&lt;container id=&quot;33&quot;  parentID=&quot;0&quot;  restricted=&quot;1&quot;&gt;&lt;dc:title&gt;影片&lt;/dc:title&gt;&lt;upnp:class&gt;object.container.storageFolder&lt;/upnp:class&gt;&lt;upnp:storageUsed&gt;-1&lt;/upnp:storageUsed&gt;&lt;/container&gt;&lt;/DIDL-Lite&gt;";
//    // Response for the browse command should be in the format:
//    // Browse (DIDL-Lite response, number returned, number matched, unique system ID (or container ID if supported))
//    NSMutableString *response = [NSMutableString string];
//    [response appendFormat:@"<u:BrowseResponse xmlns:u=\"%@\">", [self serviceSchema]];
//    [response appendFormat:@"<Result>%@</Result>", container];
//    [response appendFormat:@"<NumberReturned>%i</NumberReturned>", 3];
//    [response appendFormat:@"<TotalMatches>%i</TotalMatches>", 3];
//    [response appendFormat:@"<UpdateID>%d</UpdateID>", 1];
//    [response appendString:@"</u:BrowseResponse>"];
    
    return response;
}

// This action allows the caller to search the content directory for objects that match some search criteria. The search 
// criteria are specified as a query string operating on properties with comparison and logical operators.
//
// options should contain the following entries:
//      "ContainerID" = Unique identifier of the container in which to begin searching. A ContainerID value of zero 
//                      corresponds to the root object of the Content Directory.
//      "SearchCriteria" = See section 2.5.5. in the service specs.
//      "Filter" =     See 2.5.7. A_ARG_TYPE_Filter in the service specs
//      "StartingIndex" = This variable is used in conjunction with those actions that include an Index parameter. Index 
//                        parameters specify an offset into an arbitrary list of objects. Starts a 0.
//      "RequestedCount" = Count parameters specify an ordinal number of arbitrary objects.
//      "SortCriteria" = See 2.5.8. A_ARG_TYPE_SortCriteria in the service specs   
- (NSString *)searchWithOptions:(NSDictionary *)options
{
    return @"";
    // Not currently supposed
}

// This action creates a new object in the container identified by ContainerID. The new object is created with the 
// required id attribute set to "" and the required restricted attribute set to false. The actual value of the id 
// attribute is supplied by the Content Directory Service.
//
// options should contain the following entries:
//      "ContainerID" = Unique identifier of the container in which to create the object. A ContainerID value of zero 
//                      corresponds to the root object of the Content Directory.
//      "Elements" = Any child elements to be created along with the new object.
- (NSString *)createObjectWithOptions:(NSDictionary *)options
{
    return @"";
    // Not currently supposed
}

// This action destroys the specified object when permitted. If the object is a container, all of its child objects are 
// also deleted, recursively. Each deleted object becomes invalid and all references to it are also deleted.
- (NSString *)destroyObjectWithObjectID:(NSString *)objectID
{
    return @"";
    // Not currently supposed
}

// This action modifies, deletes or inserts object metadata.
//
// options should contain the following entries:
//      "ContainerID" = Unique identifier of the container in which to update. A ContainerID value of zero 
//                      corresponds to the root object of the Content Directory.
//      "CurrentTagValue" = Current value to replace.
//      "NewTagValue" = The new value to replace it with.
- (NSString *)updateObjectWithOptions:(NSDictionary *)options
{
    return @"";
    // Not currently supposed
}

// This action imports a resource at the specified location. Uses HTTP GET to import resource.
//
// options should contain the following entries:
//      "SourceURI" = The uniform resource identifier for the resource to import.
//      "DestinationURI" = The destination location for the new imported resource.
- (NSString *)importResourceWithOptions:(NSDictionary *)options
{
    return @"";
    // Not currently supposed
}

// This action exports a resource to the specified location. Uses HTTP POST to export the resource.
//
// options should contain the following entries:
//      "SourceURI" = The uniform resource identifier for the resource to export.
//      "DestinationURI" = The destination location for the exported resource.
- (NSString *)exportResourceWithOptions:(NSDictionary *)options
{
    return @"";
    // Not currently supposed
}

// Stops the specified transfer.
- (NSString *)stopTransferResourceWithTransferID:(NSString *)transferID
{
    return @"";
    // Not currently supposed
}

// Query the progress of a specified transfer.
- (NSString *)getTransferProgressFromTransferID:(NSString *)transferID
{
    return @"";
    // Not currently supposed
}

// Attempts to delete the specified resource.
- (NSString *)deleteResourceWithURI:(NSString *)resourceURI
{
    return @"";
    // Not currently supposed
}

// This action creates a reference to an existing item, specified by the ObjectID argument, in the parent container, 
// specified by the ContainerID argument
//
// options should contain the following entries:
//      "ContainerID" = The container for the new reference object.
//      "ObjectID" = The item to create a reference of.
- (NSString *)createReferenceOptions:(NSDictionary *)options
{
    return @"";
    // Not currently supposed
}

#pragma mark UPnPService

// The service schema (e.x. urn:schemas-upnp-org:service:WANPPPConnection:1)
- (NSString *)serviceSchema
{
   return @"urn:schemas-upnp-org:service:ContentDirectory:1";
}

// The control URL (<controlURL>) found in the device definition
// POST messages will query against the control URL to perform actions
- (NSString *)controlURL
{
   return @"/upnp/control/content_directory";
}

// The eventing URL (<eventSubURL>) found in the device definition 
// POST messages can subscribe to state variable changes using the event URL
- (NSString *)eventURL
{
    return @"/upnp/event/content_directory";
}

// Give a response for the specified SOAP action message. 
- (NSString *)responseForControlAction:(NSString *)action
{
    NSError *error = nil;
    DDXMLElement *soapMessage = [[DDXMLElement alloc] initWithXMLString:action error:&error];
    
    if (error) 
    {
        DDLogError(@"Received invalid soap control message. [Message:%@]", action);
        NSString *errorMessage = [NSString upnpErrorMessageWithCode:CANNOT_PROCESS
                                                     andDescription:CANNOT_PROCESS_DESC
                                                          forSchema:[self serviceSchema]];
        return [errorMessage stringAsSoapMessage];
    }
    
    // Get SOAP body element
    DDXMLElement *bodyElement = [soapMessage elementForName:@"Body"];
    if (!bodyElement) 
    {
        bodyElement = [soapMessage elementForName:@"s:Body"];
    }
    
    if (!bodyElement) 
    {
        DDLogError(@"Received invalid soap control message with no body. [Message:%@]", action);
        NSString *errorMessage = [NSString upnpErrorMessageWithCode:CANNOT_PROCESS
                                                     andDescription:CANNOT_PROCESS_DESC
                                                          forSchema:[self serviceSchema]];
        return [errorMessage stringAsSoapMessage];
    }
    
    DDXMLNode *functionElement = [bodyElement childAtIndex:0];
    if (!functionElement) 
    {
        DDLogError(@"Received invalid soap control message with no function. [Message:%@]", action);
        NSString *errorMessage = [NSString upnpErrorMessageWithCode:CANNOT_PROCESS
                                                     andDescription:CANNOT_PROCESS_DESC
                                                          forSchema:[self serviceSchema]];
        return [errorMessage stringAsSoapMessage];
    }
    
    NSString *functionName = [[functionElement localName] lowercaseString];
    
    if ( [functionName isEqualToString:@"browse"] ) 
    {
        
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithXMLString:[functionElement description] options:0 error:nil];
        GDataXMLElement *root = doc.rootElement;
        
        DDLogInfo(@"Content Directory XML %@", [root XMLString]);
        
        NSString *objectID = [root getValueByTagName:@"ObjectID" namespace:nil];
        NSString *startingIndex;
        @try {
            startingIndex = [root getValueByTagName:@"StartingIndex" namespace:nil];
        }
        @catch (NSException *exception) {
            startingIndex = @"0";
        }
        
        NSString *requestedCount;
        @try {
            requestedCount = [root getValueByTagName:@"RequestedCount" namespace:nil];
        }
        @catch (NSException *exception) {
            requestedCount = @"20";
        }
        
        NSString *filter;
        @try {
            filter = [root getValueByTagName:@"Filter" namespace:nil];
        }
        @catch (NSException *exception) {
            filter = @"";
        }
        
        NSString *searchCriteria;
        @try {
            searchCriteria = [root getValueByTagName:@"SearchCriteria" namespace:nil];
        }
        @catch (NSException *exception) {
            searchCriteria = @"";
        }
        
        NSString *sortCriteria;
        @try {
            sortCriteria = [root getValueByTagName:@"SortCriteria" namespace:nil];
        }
        @catch (NSException *exception) {
            sortCriteria = @"";
        }
        
        NSString *browseFlag;
        @try {
            browseFlag = [root getValueByTagName:@"BrowseFlag" namespace:nil];
        }
        @catch (NSException *exception) {
            browseFlag = @"BrowseDirectChildren";
        }
                
        NSDictionary *browseOptions = [NSDictionary dictionaryWithObjectsAndKeys:objectID, @"ObjectID",
                                        searchCriteria, @"SearchCriteria",
                                        filter, @"Filter",
                                        browseFlag, @"BrowseFlag",
                                        startingIndex, @"StartingIndex",
                                        requestedCount, @"RequestedCount",
                                        sortCriteria, @"SortCriteria", nil];
        
        return [[self browseWithOptions:browseOptions]  stringAsSoapMessage]; 
    }
    else if( [functionName isEqualToString:@"getsystemupdateid"] )
    {
        return [[self getSystemUpdateID] stringAsSoapMessage];
    }
    else if( [functionName isEqualToString:@"getsortcapabilities"] )
    {
        return [[self getSortCapabilities] stringAsSoapMessage];
    }
    else if( [functionName isEqualToString:@"getsearchcapabilities"] )
    {
        return [[self getSearchCapabilities] stringAsSoapMessage];
    }
    else
    {
        // currently unsupported functionality
        NSString *errorMessage = [NSString upnpErrorMessageWithCode:CANNOT_PROCESS
                                                     andDescription:CANNOT_PROCESS_DESC
                                                          forSchema:[self serviceSchema]];
        return [errorMessage stringAsSoapMessage];
    }

}

// Give a response for the specified SOAP event message.
- (NSString *)responseForEventVariable:(NSString *)event
{
   // Not currently supported
   return @""; 
}

@end
