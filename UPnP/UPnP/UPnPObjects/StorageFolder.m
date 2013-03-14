//
//  storageFolder.m
//  UPnP
//
//  Created by Patrick Denney on 8/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StorageFolder.h"
#import "NSFileManager+UPnP.h"
#import "NSString+UPnP.h"
#import "Movie.h"
#import "MusicTrack.h"
#import "Photo.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVMetadataItem.h>
#include "DDLog.h"

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_INFO;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@implementation StorageFolder

@synthesize items = _items;
@synthesize storageUsed = _storageUsed;
@synthesize subfolders = _subfolders;
@synthesize relativePath = _relativePath;

- (id)init
{
    self = [super init];
    if (self) 
    {
        self.items = [NSMutableArray arrayWithCapacity:4];
        self.subfolders = [NSMutableArray arrayWithCapacity:4];
        self.createClass = @"object.container.storageFolder";
    }
    
    return self;
}

- (id)initObjectFromDictionary:(NSDictionary *)dictionary
{
    self = [super initObjectFromDictionary:dictionary];
    [self init];
    if (self)
    {
        self.relativePath = [dictionary objectForKey:@"relativePath"];
    }
    
    return self;
}

- (void)dealloc
{
    self.items = nil;
    self.subfolders = nil;
    self.relativePath = nil;
    
    [super dealloc];
}

- (NSString *)xmlRepresentation:(NSString *)childElement
{
    NSMutableString *myAttributes = [NSMutableString stringWithFormat:@"<upnp:storageUsed>%lu</upnp:storageUsed>", self.storageUsed];
//    [myAttributes appendString:@"<upnp:writeStatus>PROTECTED</upnp:writeStatus>"];
    [myAttributes appendFormat:@"<upnp:storageUsed>%ld</upnp:storageUsed>", self.storageUsed];
    [myAttributes appendString:@"<upnp:class>object.container.storageFolder</upnp:class>"];
    
    if (childElement) 
    {
        [myAttributes appendString:childElement];
    }
    
    return [super xmlRepresentation:myAttributes];
}

- (void)populateChildren
{
    if (!self.relativePath)
    {
        DDLogError(@"Attempted to populate folder children without fist setting relative path.");
        return;
    }
    
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.relativePath error:&error];
//    if (error) 
//    {
//        DDLogError(@"Received error while attempt to find files at relative path: %@", self.relativePath);
//        return;
//    }
    
    NSLog(@"files = %@", files);
    
    for (NSString *file in files) 
    {
        NSString *fullPath = [self.relativePath stringByAppendingPathComponent:file];
        NSDictionary *fileMetaData = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&error];
        
        if (error)
        {
            DDLogError(@"Received error while attempt to get metadata for file at path: %@", fullPath);
            DDLogError(@"fileMetaData: %@", fileMetaData);
        }
        
        NSString *fileType = [fileMetaData objectForKey:NSFileType];
        
        if (fileType == NSFileTypeDirectory) {
            fullPath = [fullPath stringByAppendingString:@"/"];
            StorageFolder *subfolder = [[StorageFolder alloc] initObjectFromDictionary:
                                        [NSDictionary dictionaryWithObjectsAndKeys:
                                         self.id, @"parentId",
                                         [NSNumber numberWithBool:self.isSearchable], @"isSearchable",
                                         [NSNumber numberWithBool:self.isRestricted], @"isRestricted", 
                                         [NSNumber numberWithInt:files.count], @"childCount", 
                                         file, @"title", 
                                         [NSNumber numberWithLong:[NSFileManager folderSize:fullPath]], @"storageUsed",  
                                         fullPath, @"relativePath", nil]];
            
            [subfolder populateChildren];
            [self.subfolders addObject:subfolder];
            
            [subfolder release];
        } else if(fileType == NSFileTypeRegular) {
            NSString *extension = [file getExtension];
            NSObject *item;
            
            BOOL isItem = YES;
            
            if ([VideoItem isVideoItem:extension]) {
                item = [[Movie alloc] initObjectFromDictionary:
                        [NSDictionary dictionaryWithObjectsAndKeys:
                        self.id, @"parentId",
                        file, @"title",
                        [NSNumber numberWithBool:self.isRestricted], @"isRestricted", nil]];
                
                // We need to figure out how to get metadata from videos at some point

            } else if([AudioItem isAudioItem:extension]) {
                item = [[MusicTrack alloc] initObjectFromDictionary:
                        [NSDictionary dictionaryWithObjectsAndKeys:
                         self.id, @"parentId",
                         file, @"title",
                         [NSNumber numberWithBool:self.isRestricted], @"isRestricted", nil]];
                
                // Attempt to get metadata for the music track
                NSURL *url = [NSURL fileURLWithPath:fullPath];
                AVURLAsset *asset = [[AVURLAsset alloc]initWithURL:url options:nil]; 
                
                NSArray *formatArray = asset.availableMetadataFormats; 
                NSArray *array = [asset metadataForFormat:[formatArray objectAtIndex:0]]; 

                for(AVMetadataItem *metadata in array) 
                { 
                    if ([metadata.commonKey isEqualToString:@"artist"]) 
                    { 
                        ((MusicTrack *)item).artist = (NSString *)metadata.value;
                    }
                    else if([metadata.commonKey isEqualToString:@"album"])
                    {
                        ((MusicTrack *)item).album = (NSString *)metadata.value;
                    }
                    else if([metadata.commonKey isEqualToString:@"genre"])
                    {
                        ((MusicTrack *)item).genre = (NSString *)metadata.value;
                    }
                }
                
            } else if([ImageItem isImageItem:extension]) {
                item = [[Photo alloc] initObjectFromDictionary:
                        [NSDictionary dictionaryWithObjectsAndKeys:
                        self.id, @"parentId",
                        file, @"title",
                        [NSNumber numberWithBool:self.isRestricted], @"isRestricted", nil]];
                
                // Same here, how do we get metadata from image files?
            } else {
                isItem = NO;
            }
            
            if (isItem) {
                [self.items addObject:item];
                [item release];
            }
            
        }
    }
    NSLog(@"======================");
    NSLog(@"self = %@", self.title);
    for (StorageFolder *sf in self.subfolders) {
        NSLog(@"folder = %@", sf.title);
    }
    for (ImageItem *item in self.items) {
        NSLog(@"item = %@", item.title);
    }
}

@end
