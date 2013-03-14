//
//  FileManager.h
//  UPnP
//
//  This is a support manager used to build the file directory objects for use in UPnP
//  responses.  It will build the StorageFolder and StorageVolumes in the from the respected
//  set directories.
//
//  Created by Patrick Denney on 9/20/11.
//

#import <Foundation/Foundation.h>
#import "StorageFolder.h"
#import "NSFileManager+UPnP.h"

@interface FileManager : NSObject
{
    StorageFolder *_baseDirectory;
}

+ (id)sharedInstance;

// Given an object ID, and the number of items to return, give an DIDL-Lite response
// string back that is ready to be wrapped up and returned to the client.
- (NSString *)browseWithObjectID:(NSString *)objectID 
              withDirectChildren:(BOOL)showChildren
               forRequestedCount:(int)requestedCount
               withStartingIndex:(int)offset
                     returnCount:(int *)returnCount
                      totalCount:(int *)totalCount;
@end
