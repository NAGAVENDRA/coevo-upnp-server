//
//  ContentDirectoryServiceErrorCodes.h
//  UPnP
//
//  Created by Patrick Denney on 9/29/11.
//

/**********************************************************************
 Possible UPnP Content Directory Service errors that can be thrown
 *********************************************************************/

// No such object The specified ObjectID is invalid. 
#define INVALID_OBJECTID 701
#define INVALID_OBJECTID_DESC @"No such object"

// Invalid CurrentTagValue (The tag/value pair(s) listed in CurrentTagValue do not match the current 
// state of the CDS. The specified data is likely out of date.)
#define INVALID_CURTAG 702
#define INVALID_CURTAG_DESC @"Invalid CurrentTagValue"

// Invalid NewTagValue (The specified value for the NewTagValue parameter is invalid.)
#define INVALID_NEWTAG 703
#define INVALID_NEWTAG_DESC @"Invalid NewTagValue"

// Required tag (Unable to delete a required tag.)
#define REQUIRED_TAG 704
#define REQUIRED_TAG_DESC @"Required tag"

// Read only tag  (Unable to update a read only tag.) 
#define READONLY_TAG 705
#define READONLY_TAG_DESC @"Read only tag"

// Parameter Mismatch (The number of tag/value pairs (including empty placeholders) in
// CurrentTagValue and NewTagValue do not match.)
#define PARAM_MISMATCH 706
#define PARAM_MISMATCH_DESC @"Parameter Mismatch"

// Unsupported or invalid search criteria (The search criteria specified is not supported or is invalid)
#define INVALID_SEARCH 708  
#define INVALID_SEARCH_DESC @"Unsupported or invalid search criteria"

// No such container  (The specified ContainerID is invalid or identifies an object that is 
// not a container.)
#define INVALID_CONTAINER 710
#define INVALID_CONTAINER_DESC @"No such container"

// Restricted object (Operation failed because the restricted attribute of object is set to true.) 
#define OBJ_RESTRICTED 711 
#define OBJ_RESTRICTED_DESC @"Restricted object"

// Bad metadata (Operation fails because it would result in invalid or disallowed metadata in current object.)
#define BAD_METADATA 712  
#define BAD_METADATA_DESC @"Bad metadata"

// Restricted parent object (Operation failed because the restricted attribute of parent object
// is set to true.)
#define RESTRICTED_PARTENT 713 
#define RESTRICTED_PARTENT_DESC @"Restricted parent object"

// No such source resource (Cannot identify the specified source resource) 
#define INVALID_RESOURCE 714   
#define INVALID_RESOURCE_DESC @"No such source resource"

// Source resource access denied (Cannot access the specified source resource)
#define RESOURCE_DENIED 715
#define RESOURCE_DENIED_DESC @"Source resource access denied"

// Transfer busy (Another file transfer is not accepted) 
#define ALREADY_BUSY 716  
#define ALREADY_BUSY_DESC @"Transfer busy"

// No such file transfer (The file transfer specified by TransferID does not exist)
#define INVALID_TRANSFER 717
#define INVALID_TRANSFER_DESC @"No such file transfer"

// No such destination resource (Cannot identify the specified destination resource)
#define INVALID_DST 718  
#define INVALID_DST_DESC @"No such destination resource"

// Destination resource access denied (Cannot access the specified destination resource) 
#define DST_DENIED 719 
#define DST_DENIED_DEC @"Destination resource access denied"

// Cannot process the request
#define CANNOT_PROCESS 720
#define CANNOT_PROCESS_DESC @"Cannot process the request"
