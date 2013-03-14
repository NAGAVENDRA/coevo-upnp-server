//
//  NSFileManager+UPnP.m
//  UPnP
//
//  Created by Patrick Denney on 9/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSFileManager+UPnP.h"

@implementation NSFileManager (NSFileManager_UPnP)

+ (NSString *)pathToSharedDocuments
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+ (NSString *)pathToDirectory:(fileDirectory)directory
{
    switch (directory) 
    {
        case VideoDirectory:
            return [NSString stringWithFormat:@"%@/Video/", [self pathToSharedDocuments]];
            break;
        case MusicDirectory:
            return [NSString stringWithFormat:@"%@/Music/", [self pathToSharedDocuments]];
            break;
        case PicturesDirectory:
            return [NSString stringWithFormat:@"%@/Pictures/", [self pathToSharedDocuments]];
            break;
        case OtherDirectory:
        default:
            return [NSString stringWithFormat:@"%@/Other/", [self pathToSharedDocuments]];
            break;
    }
}

+ (NSArray *)getSharedVideoFiles
{
    NSString *sharedVideoPath = [self pathToDirectory:VideoDirectory];
    
    NSError *error = nil;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sharedVideoPath error:&error];
    if (error) 
    {
        NSLog(@"Error occured while attempting to get shared video files. %@",error);
        return nil;
    }
    
    return files;
}

+ (NSArray *)getSharedAudioFiles
{
    NSString *sharedAudioPath = [self pathToDirectory:MusicDirectory];
    
    NSError *error = nil;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sharedAudioPath error:&error];
    if (error) 
    {
        NSLog(@"Error occured while attempting to get shared music files. %@",error);
        return nil;
    }
    
    return files;
}

+ (NSArray *)getSharedImageFiles
{
    NSString *sharedImagePath = [self pathToDirectory:PicturesDirectory];
    
    NSError *error = nil;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sharedImagePath error:&error];
    if (error) 
    {
        NSLog(@"Error occured while attempting to get shared picture files. %@",error);
        return nil;
    }
    
    return files;
}

+ (NSArray *)getSharedOtherFiles
{
    NSString *sharedOtherPath = [self pathToDirectory:OtherDirectory];
    
    NSError *error = nil;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sharedOtherPath error:&error];
    if (error) 
    {
        NSLog(@"Error occured while attempting to get shared other files. %@",error);
        return nil;
    }
    
    return files;
}

+ (unsigned long int)folderSize:(NSString *)folderPath 
{
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    unsigned long int fileSize = 0;
    
    while (fileName = [filesEnumerator nextObject]) 
    {
        NSString *path = [folderPath stringByAppendingPathComponent:fileName];
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        fileSize += [[fileDictionary objectForKey:NSFileSystemSize] longValue];
    }
    
    return fileSize;
}
@end
