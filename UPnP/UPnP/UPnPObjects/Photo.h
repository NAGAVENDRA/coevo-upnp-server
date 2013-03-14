//
//  Photo.h
//  UPnP
//
//  A ‘photo’ instance is an image that should be interpreted as a photo (as opposed to, for example, an icon).
//
//  Created by Patrick Denney on 8/23/11.
//

#import <Foundation/Foundation.h>
#import "ImageItem.h"

@interface Photo : ImageItem
{
    NSString *_album;
}

// Title of the album to which the item belongs.
@property (nonatomic, retain) NSString *album;

@end
