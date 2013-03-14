//
//  ContentDirectoryItem.m
//  UPnP
//
//  Created by Patrick Denney on 8/21/11.
//

#import "ContentDirectoryItem.h"
#import "NSString+UPnP.h"

@implementation ContentDirectoryItem

@synthesize referenceId = _referenceId;

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
    NSString *containerTag = [NSString stringWithFormat:@"<item id=\"%@\" parentID=\"%@\" restricted=\"%@\">",
                              self.id,
                              self.parentId,
                              [NSString convertFromBool:self.isRestricted]];
    
    NSString *titleTag = [NSString stringWithFormat:@"<dc:title>%@</dc:title>", self.title];
    return [NSString stringWithFormat:@"%@%@%@</item>",containerTag, titleTag, childElement];
}

- (void)dealloc
{
    self.referenceId = nil;
    
    [super dealloc];
}
@end
