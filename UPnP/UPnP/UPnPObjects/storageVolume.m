//
//  storageVolume.m
//  UPnP
//
//  Created by Patrick Denney on 8/25/11.
//

#import "StorageVolume.h"

@implementation StorageVolume

@synthesize storageTotal = _storageTotal;
@synthesize storageUsed = _storageUsed;
@synthesize storageFree = _storageFree;
@synthesize storageMedium = _storageMedium;

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
    
    [super dealloc];
}

@end
