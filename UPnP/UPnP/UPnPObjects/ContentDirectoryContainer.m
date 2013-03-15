//
//  ContentDirectoryContainer.m
//  UPnP
//
//  Created by Patrick Denney on 8/21/11.
//

#import "ContentDirectoryContainer.h"
#import "NSString+UPnP.h"

@implementation ContentDirectoryContainer

@synthesize searchClass = _searchClass;
@synthesize createClass = _createClass;
@synthesize isSearchable = _isSearchable;
@synthesize childCount = _childCount;

- (id)initObjectFromDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) 
    {
        self.isRestricted = [[dictionary objectForKey:@"isRestricted"] boolValue];
        self.title = [dictionary objectForKey:@"title"];
        self.isSearchable = [[dictionary objectForKey:@"isSearchable"] boolValue];
        self.parentId = [dictionary objectForKey:@"parentId"];
        self.parent = [dictionary objectForKey:@"parent"];
    }
    
    return self;
}

- (NSString *)xmlRepresentation:(NSString *)childElement
{
    NSString *containerTag = [NSString stringWithFormat:@"<container id=\"%@\" parentID=\"%@\" childCount=\"%d\" restricted=\"%@\">",
                              self.id,
                              self.parentId,
                              self.childCount,
                              [NSString convertFromBool:self.isRestricted]];
    
    NSString *titleTag = [NSString stringWithFormat:@"<dc:title>%@</dc:title>", self.title];
    return [NSString stringWithFormat:@"%@%@%@</container>",containerTag, titleTag, childElement];
}

- (void)dealloc
{
    self.searchClass = nil;
    self.createClass = nil;
    
    [super dealloc];
}

@end
