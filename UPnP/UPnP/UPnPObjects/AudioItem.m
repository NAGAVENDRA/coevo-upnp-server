//
//  AudioItem.m
//  UPnP
//
//  Created by Patrick Denney on 8/22/11.
//

#import "AudioItem.h"
#import "NSArray+UPnP.h"

@implementation AudioItem

// supported audio formats
static NSArray *audioTypes = nil;

@synthesize genre = _genre;
@synthesize description = _description;
@synthesize longDescription = _longDescription;
@synthesize publisher = _publisher;
@synthesize language = _language;
@synthesize relation = _relation;
@synthesize rights = _rights;

- (id)initObjectFromDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) 
    {
        if (!audioTypes) 
        {
            audioTypes = [[NSArray alloc] initWithObjects:@"aiff", @"au", @"cdda", @"wav", @"mp3", @"flacc", @"la", @"pac", @"m4a", @"wma", @"mp2", @"speex", @"aac", @"ra", @"vox", @"voc", @"asf", nil];
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
    self.rights = nil;
    
    [super dealloc];
}

- (NSString *)xmlRepresentation:(NSString *)childElement
{
    // Will be built in subclasses. 
    return @"";
}

+ (BOOL)isAudioItem:(NSString *)filename
{
    return [audioTypes containsString:[filename lowercaseString]];
}

@end
