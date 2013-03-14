//
//  MusicTrack.m
//  UPnP
//
//  Created by Patrick Denney on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MusicTrack.h"

@implementation MusicTrack

@synthesize artist = _artist;
@synthesize album = _album;
@synthesize playlist = _playlist;
@synthesize contributor = _contributor;
@synthesize date = _date;
@synthesize storageMedium = _storageMedium;
@synthesize originalTrackNumber = _originalTrackNumber;

- (id)initObjectFromDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) 
    {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    
    return self;
}

- (NSString *)xmlRepresentation:(NSString *)childElement
{
    // Will be built in subclasses. 
    return @"";
}

- (void)dealloc
{
    self.artist = nil;
    self.album = nil;
    self.playlist = nil;
    self.contributor = nil;
    self.date = nil;
    self.storageMedium = nil;
    
    [super dealloc];
}

@end
