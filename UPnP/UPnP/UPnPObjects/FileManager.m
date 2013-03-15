//
//  FileManager.m
//  UPnP
//
//  Created by Patrick Denney on 9/20/11.
//

#import "FileManager.h"
#import "SharedDefinitions.h"
#import "ContentDirectoryServiceErrorCodes.h"
#import "NSString+UPnP.h"
#include "DDLog.h"
#import "ContentDirectoryItem.h"

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_INFO;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@interface FileManager()

- (void)buildFileList;

@end

@implementation FileManager

+ (id)sharedInstance
{
    static FileManager *sharedInstance = nil;
    if (!sharedInstance) 
    {
        sharedInstance = [[self alloc] init];
    }
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) 
    {
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(systemUpdated) 
                                                     name:kSystemUpdated 
                                                   object:nil];
        [self buildFileList];
    }
    
    return self;
}

- (void)dealloc
{
    [_baseDirectory release];
    _baseDirectory = nil;
    
    [super dealloc];
}

#pragma internal support functions

- (void)buildFileList
{
    if (_baseDirectory) 
    {
        [_baseDirectory release];
    }
    
    DDLogInfo(@"Building internal file list for file manager.");
    
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSFileManager pathToSharedDocuments] error:&error];
    if (error) 
    {
        DDLogError(@"Unable to get subdirectories for shared documents path at: %@", [NSFileManager pathToSharedDocuments]);
    }

    // get a count of the sub-directories, we ignore files at the shared documents level
    int directories = 0;
    for (NSString *file in files) 
    {
        NSString *fullPath = [[NSFileManager pathToSharedDocuments] stringByAppendingPathComponent:file];
        NSDictionary *fileMetaData = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&error];
        
        if (error) 
        {
            DDLogError(@"Received error while attempt to get metadata for file at path: %@", fullPath);
            continue;
        }
        
        NSString *fileType = [fileMetaData objectForKey:NSFileType];
        if (fileType == NSFileTypeDirectory) 
        {
            directories++;
        }
    }
    
    _baseDirectory = [[StorageFolder alloc] initObjectFromDictionary:
                      [NSDictionary dictionaryWithObjectsAndKeys:
                       @"-1", @"parentId",
                       self, @"parent",
                       [NSNumber numberWithBool:searchSupported], @"isSearchable",
                       [NSNumber numberWithBool:YES], @"isRestricted",
                       [NSNumber numberWithInt:directories], @"childCount",
                       @"Media", @"title",
                       [NSNumber numberWithLong:[NSFileManager folderSize:[NSFileManager pathToSharedDocuments]]], @"storageUsed",
                       [NSFileManager pathToSharedDocuments], @"relativePath", nil]];
    
    [_baseDirectory populateChildren];
    
     DDLogInfo(@"File list built for file manager.");
}

- (void)systemUpdated
{
    // The file system was updated, refresh the file system list
    [self buildFileList];
}

- (StorageFolder *)folderWithObjectID:(NSString *)objectID
{
    NSLog(@"folderWithObjectID = %@", objectID);    
    if ([_baseDirectory.id isEqualToString:objectID]) 
    {
        return _baseDirectory;
    }
    
    return [self folderWithObjectID:objectID storageFolder:_baseDirectory];
}

-(StorageFolder *)folderWithObjectID:(NSString *)objectID storageFolder:(StorageFolder *)storageFolder
{
    for (StorageFolder *subfolder in storageFolder.subfolders)
    {
        if ([subfolder.id isEqualToString:objectID]) {
            return subfolder;
        }
        
        StorageFolder *result = [self folderWithObjectID:objectID storageFolder:subfolder];
        if (result != nil) {
            return result;
        }
    }
    return nil;
}

#pragma internal public functions

// This should respond with a DIDL-Lite XML formatted string with the contents of the 
// folder container with or without meta data.  An example of the returned formatted would be:
// <DIDL-Lite xmlns:dc="http://purl.org/dc/elements/1.1/xmlns:upnp=”urn:schemas-upnp-org:metadata-1-0/upnp/” 
//  xmlns=”urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/”> 
//   <container id=”0” parentID=”-1” childCount=”2” restricted=”true” searchable="true"> 
//      <dc:title>My multimedia stuff</dc:title> 
//      <upnp:class>object.container.storageFolder</upnp:class> 
//      <upnp:storageUsed>907000</upnp:storageUsed> 
//      <upnp:writeStatus>WRITABLE</upnp:writeStatus> 
//      <upnp:searchClass includeDerived=”false” >   // Search classes are optional and not supported in this version
//           object.container.album.musicAlbum 
//      </upnp:searchClass> 
//      <upnp:searchClass includeDerived=”false” > 
//           object.container.album.photoAlbum 
//      </upnp:searchClass> 
//      <upnp:searchClass includeDerived=”false” > 
//           object.item.audioItem.musicTrack 
//      </upnp:searchClass> 
//      <upnp:searchClass includeDerived=”false” > 
//           object.item.imageItem.photo 
//      </upnp:searchClass> 
//      <upnp:searchClass name=”Vendor Album Art” includeDerived=”true”> 
//           object.item.imageItem.photo.vendorAlbumArt 
//      </upnp:searchClass> 
//    </container> 
//  </DIDL-Lite
- (NSString *)browseWithObjectID:(NSString *)objectID 
              withDirectChildren:(BOOL)showChildren
               forRequestedCount:(int)requestedCount
               withStartingIndex:(int)offset
                     returnCount:(int *)returnCount
                      totalCount:(int *)totalCount;
{
    *returnCount = 0;
    *totalCount = 0;
    
    // Make sure requested object exists...
    StorageFolder *folder = [self folderWithObjectID:objectID];
    if (!folder) 
    {
        DDLogError(@"Received request for invalid object ID %@", objectID);
        return [NSString errorWithCode:INVALID_OBJECTID andDescription:INVALID_OBJECTID_DESC];
    }
    
    NSMutableString *returnString = [NSMutableString string];
    
    if (showChildren) 
    {
        DDLogInfo(@"Received request for children of object %@", objectID);
        
        // Now get the list of children objects/containers in the folder
        *returnCount = 0;
        int startingIndex = offset;
        if (startingIndex < folder.subfolders.count)
        {
            for (int itemIndex = startingIndex; (itemIndex < folder.subfolders.count); itemIndex++) 
            {
                StorageFolder *subfolder = [folder.subfolders objectAtIndex:itemIndex];
                [returnString appendString:[subfolder xmlRepresentation:nil]];
                (*returnCount)++;
                
                if ((*returnCount) == requestedCount) 
                {
                    break;
                }
            }
        }
        else
        {
            startingIndex = startingIndex - (folder.subfolders.count-1);
        }
        
        if (startingIndex < 0) 
        {
            startingIndex = 0;
        }
        
        if ((*returnCount) == requestedCount)
        {
            return [returnString DIDLLiteResponseString];
        }
        
        for (int itemIndex = startingIndex; (itemIndex < folder.items.count); itemIndex++) 
        {
            ContentDirectoryItem *item = [folder.items objectAtIndex:itemIndex];
            [returnString appendString:[item xmlRepresentation:nil]];
            (*returnCount)++;
            
            if ((*returnCount) == requestedCount) 
            {
                break;
            }
        }
    }
    else
    {
        DDLogInfo(@"Received request for metadata of object %@", objectID);
        
        // Just show the object's metadata
        [returnString appendString:[folder xmlRepresentation:nil]];
    }
        
    return [returnString DIDLLiteResponseString];
}

@end
