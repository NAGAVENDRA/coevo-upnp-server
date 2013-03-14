//
//  Photo.m
//  UPnP
//
//  Created by Patrick Denney on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Photo.h"

@implementation Photo

@synthesize album = _album;

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
    self.album = nil;
    
    [super dealloc];
}

@end
