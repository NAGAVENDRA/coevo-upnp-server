//
//  VideoItem.m
//  UPnP
//
//  Created by Patrick Denney on 8/23/11.
//

#import "VideoItem.h"
#import "NSArray+UPnP.h"

@implementation VideoItem

// supported video formats
static NSArray *videoTypes = nil;

@synthesize genre = _genre;
@synthesize description = _description;
@synthesize longDescription = _longDescription;
@synthesize publisher = _publisher;
@synthesize language = _language;
@synthesize relation = _relation;
@synthesize producer = _producer;
@synthesize director = _director;
@synthesize actor = _actor;
@synthesize rating = _rating;

- (id)initObjectFromDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) 
    {
        if(!videoTypes)
        {
            videoTypes = [[NSArray alloc] initWithObjects:@"3gp", @"asf", @"avchd", @"avi", @"dat", @"flv", @"m1v", @"m2v", @"m4v", @"mkv", @"mov", @"mpeg", @"mpg", @"mpe", @"ogg", @"rm", @"swf", @"wmv", nil];
        }
        [self setValuesForKeysWithDictionary:dictionary];
    }
    
    return self;
}

- (void)dealloc
{
    self.genre = nil;
    self.description = nil;
    self.longDescription = nil;
    self.publisher = nil;
    self.language = nil;
    self.relation = nil;
    self.producer = nil;
    self.director = nil;
    self.actor = nil;
    self.rating = nil;
    
    [super dealloc];
}

- (NSString *)xmlRepresentation:(NSString *)childElement
{
    // Will be built in subclasses. 
    return @"";
}

+ (BOOL)isVideoItem:(NSString *)filename
{
    return [videoTypes containsString:[filename lowercaseString]];
}

@end
