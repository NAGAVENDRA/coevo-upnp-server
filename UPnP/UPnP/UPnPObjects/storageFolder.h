//
//  storageFolder.h
//  UPnP
//
//  A ‘storageFolder’ instance represents a collection of objects stored on some storage medium.
//
//  Created by Patrick Denney on 8/25/11.
//

#import <Foundation/Foundation.h>
#import "ContentDirectoryContainer.h"

@interface StorageFolder : ContentDirectoryContainer
{
    NSMutableArray *_items;
    NSMutableArray *_subfolders;
    NSString *_relativePath;
    
    long _storageUsed;
}

// An array of ContentDirectoryItems found within the folder
@property (nonatomic, retain) NSMutableArray *items;

// A list of subfolders as Storage Folder objects
@property (nonatomic, retain) NSMutableArray *subfolders;

// Path that in the file system that this object represents
@property (nonatomic, retain) NSString *relativePath;

// The amount of storage used in the folder
@property (nonatomic) long storageUsed;

// Must be called to populate the items property with folder's children
- (void)populateChildren;

@end
