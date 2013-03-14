//
//  ImageItem.m
//  UPnP
//
//  Created by Patrick Denney on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageItem.h"
#import "NSArray+UPnP.h"

@implementation ImageItem

// support image formats
static NSArray *imageTypes = nil;

@synthesize description = _description;
@synthesize longDescription = _longDescription;
@synthesize rating = _rating;
@synthesize rights = _rights;
@synthesize publisher = _publisher;
@synthesize storageMedium = _storageMedium;
@synthesize date = _date;

- (id)initObjectFromDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) 
    {
        if (!imageTypes) 
        {
            imageTypes = [[NSArray alloc] initWithObjects:@"jpg", @"bmp", @"png", @"gif", @"ico", @"jpeg", @"raw", @"tga", @"tiff", @"tif", @"svg", nil];
        }
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
    self.description = nil;
    self.longDescription = nil;
    self.publisher = nil;
    self.rating = nil;
    self.rights = nil;
    self.storageMedium = nil;
    self.date = nil;
    
    [super dealloc];
}

+ (BOOL)isImageItem:(NSString *)filename
{
    return [imageTypes containsString:[filename lowercaseString]];
}

@end
