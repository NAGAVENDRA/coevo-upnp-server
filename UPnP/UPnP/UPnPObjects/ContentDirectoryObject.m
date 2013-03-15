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
@synthesize parent = _parent;
@synthesize title = _title;
@synthesize creator = _creator;
@synthesize resourceURI = _resourceURI;
@synthesize isRestricted = _isRestricted;
@synthesize writeStatus = _writeStatus;
@synthesize objectClass = _objectClass;

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

-(NSString *) getFullPath
{
    ContentDirectoryObject *current;
    NSMutableArray *parents = [NSMutableArray new];
    current = self;
    while (YES) {
        NSLog(@"ppp  %@", current.title);
        if ([current.id isEqualToString:@"0"]) {
            break;
        }
        current = current.parent;
        [parents addObject:current];
    }
    
    NSString *result = @"";
    for (ContentDirectoryObject *p in parents) {
        NSString *title = @"";
        if (![p.title isEqualToString:@"Media"]) {
            title = p.title;
        }
        result = [NSString stringWithFormat:@"%@/%@", title, result];
    }
    
    return [NSString stringWithFormat:@"%@%@", result, self.title];
}

- (void)dealloc
{
    self.id = nil;
    self.parentId = nil;
    self.parent = nil;
    self.title = nil;
    self.creator = nil;
    self.resourceURI = nil;

    [super dealloc];
}
@end
