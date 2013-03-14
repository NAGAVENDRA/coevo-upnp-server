//
//  ContentDirectoryService.h
//  UPnP
//
//  This is an objective-c representation of the UPnP content directory service.
//  Client points use this service to determine what files are available on the server
//  and execute commands to retrieve the files for use. The service is queried and
//  executed using XML commands and returns a SOAP XML message to the client.
//  The service specifications can be found here:
//  http://www.upnp.org/specs/av/UPnP-av-ContentDirectory-v1-Service.pdf
// 
//  Created by Patrick Denney on 8/7/11.
//

#import <Foundation/Foundation.h>
#import "UPnPService.h"

@interface ContentDirectoryService : NSObject <UPnPService>
{
    // When a file transfer starts, its transfer id is added to the TransferIDs list.  When the transfer ends,
    //  its id is removed from TransferIDs
    NSString *_transferIDs;
    
    // Contains an array of transfer information for clients
    NSMutableDictionary *_transferInformation;
    
    // This number is updated every time a change occurs to the directory.  
    // It is evented at a max rate of once every 2 seconds.
    int _systemUpdateID;
}

// All functions below return a properly formatted XML response to be return to the client.

// This action returns the searching capabilities that are supported by the device.
- (NSString *)getSearchCapabilities;

// Returns a comma-seperated list of meta-data tags that can be used in sortCriteria
- (NSString *)getSortCapabilities;

// This action returns the current value of state variable SystemUpdateID. It can be used by clients that want to ‘poll’ 
// for any changes in the Content Directory (as opposed to subscribing to events)
- (NSString *)getSystemUpdateID;

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
//      "Filter" =     See 2.5.7. A_ARG_TYPE_Filter in the service specs
//      "StartingIndex" = This variable is used in conjunction with those actions that include an Index parameter. Index 
//                        parameters specify an offset into an arbitrary list of objects. Starts a 0.
//      "RequestedCount" = Count parameters specify an ordinal number of arbitrary objects.
//      "SortCriteria" = See 2.5.8. A_ARG_TYPE_SortCriteria in the service specs
- (NSString *)browseWithOptions:(NSDictionary *)options;

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
- (NSString *)searchWithOptions:(NSDictionary *)options;

// This action creates a new object in the container identified by ContainerID. The new object is created with the 
// required id attribute set to "" and the required restricted attribute set to false. The actual value of the id 
// attribute is supplied by the Content Directory Service.
//
// options should contain the following entries:
//      "ContainerID" = Unique identifier of the container in which to create the object. A ContainerID value of zero 
//                      corresponds to the root object of the Content Directory.
//      "Elements" = Any child elements to be created along with the new object.
- (NSString *)createObjectWithOptions:(NSDictionary *)options;

// This action destroys the specified object when permitted. If the object is a container, all of its child objects are 
// also deleted, recursively. Each deleted object becomes invalid and all references to it are also deleted.
- (NSString *)destroyObjectWithObjectID:(NSString *)objectID;

// This action modifies, deletes or inserts object metadata.
//
// options should contain the following entries:
//      "ContainerID" = Unique identifier of the container in which to update. A ContainerID value of zero 
//                      corresponds to the root object of the Content Directory.
//      "CurrentTagValue" = Current value to replace.
//      "NewTagValue" = The new value to replace it with.
- (NSString *)updateObjectWithOptions:(NSDictionary *)options;

// This action imports a resource at the specified location. Uses HTTP GET to import resource.
//
// options should contain the following entries:
//      "SourceURI" = The uniform resource identifier for the resource to import.
//      "DestinationURI" = The destination location for the new imported resource.
- (NSString *)importResourceWithOptions:(NSDictionary *)options;

// This action exports a resource to the specified location. Uses HTTP POST to export the resource.
//
// options should contain the following entries:
//      "SourceURI" = The uniform resource identifier for the resource to export.
//      "DestinationURI" = The destination location for the exported resource.
- (NSString *)exportResourceWithOptions:(NSDictionary *)options;

// Stops the specified transfer.
- (NSString *)stopTransferResourceWithTransferID:(NSString *)transferID;

// Query the progress of a specified transfer.
- (NSString *)getTransferProgressFromTransferID:(NSString *)transferID;

// Attempts to delete the specified resource.
- (NSString *)deleteResourceWithURI:(NSString *)resourceURI;

// This action creates a reference to an existing item, specified by the ObjectID argument, in the parent container, 
// specified by the ContainerID argument
//
// options should contain the following entries:
//      "ContainerID" = The container for the new reference object.
//      "ObjectID" = The item to create a reference of.
- (NSString *)createReferenceOptions:(NSDictionary *)options;
@end
