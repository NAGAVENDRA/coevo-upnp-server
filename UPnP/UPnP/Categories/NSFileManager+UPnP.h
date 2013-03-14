//
//  NSFileManager+UPnP.h
//  UPnP
//
//  Created by Patrick Denney on 9/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    VideoDirectory,
    MusicDirectory,
    PicturesDirectory,
    OtherDirectory  
} fileDirectory;

@interface NSFileManager (NSFileManager_UPnP)

// Returns the path to the shared documents directory
+ (NSString *)pathToSharedDocuments; 

// Retrieve the path to one of the shared directories
+ (NSString *)pathToDirectory:(fileDirectory)directory;

// Returns the paths for all videos in the shared directory under Documents/Video
+ (NSArray *)getSharedVideoFiles;

// Returns the paths for all audio files in the shared directory under Documents/Music
+ (NSArray *)getSharedAudioFiles;

// Returns the paths for all image files in the shared directory under Documents/Pictures
+ (NSArray *)getSharedImageFiles;

// Returns the paths for all other files list in the shared directory under Documents/Other
+ (NSArray *)getSharedOtherFiles;

// Returns the size (in bytes) of the folder at the specified path
+ (unsigned long int)folderSize:(NSString *)folderPath;

@end
