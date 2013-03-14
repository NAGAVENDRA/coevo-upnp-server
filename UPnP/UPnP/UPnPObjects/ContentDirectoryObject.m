//
//  UPNPObject.m
//  UPnP
//
//  Created by Patrick Denney on 8/21/11.
//

#import "ContentDirectoryObject.h"

@implementation ContentDirectoryObject

@synthesize id = _id;
@synthesize parentId = _parentId;
@synthesize title = _title;
@synthesize creator = _creator;
@synthesize resourceURI = _resourceURI;
@synthesize isRestricted = _isRestricted;
@synthesize writeStatus = _writeStatus;

- (id)initObjectFromDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) 
    {
        [self setValuesForKeysWithDictionary:dictionary];
        [self id];  // Sets ID
    }
    
    return self;
}

- (NSString *)xmlRepresentation:(NSString *)childElement
{
    // Will be built in subclasses. 
    return @"";
}

- (NSString *)id
{
    // Object IDs must be unique so this will increment an from the ID pool each time you query for an object ID
    static int idPool = 0;
    if(!_id)
    {
        [self setId:[NSString stringWithFormat:@"%i", idPool++]];
    }
    
    return _id;
}

- (void)dealloc
{
    self.id = nil;
    self.parentId = nil;
    self.title = nil;
    self.creator = nil;
    self.resourceURI = nil;

    [super dealloc];
}
@end
