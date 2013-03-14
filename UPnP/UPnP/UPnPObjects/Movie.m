//
//  Movie.m
//  UPnP
//
//  Created by Patrick Denney on 8/23/11.
//

#import "Movie.h"

@implementation Movie

@synthesize storageMedium = _storageMedium;
@synthesize channelName = _channelName;
@synthesize scheduledStartTime = _scheduledStartTime;
@synthesize scheduledEndTime = _scheduledEndTime;
@synthesize dvdRegionCode = _dvdRegionCode;

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
    self.storageMedium = nil;
    self.channelName = nil;
    self.scheduledStartTime = nil;
    self.scheduledEndTime = nil;
    
    [super dealloc];
}

@end
