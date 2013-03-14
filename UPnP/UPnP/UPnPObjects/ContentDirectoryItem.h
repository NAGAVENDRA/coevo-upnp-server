//
//  ContentDirectoryItem.h
//  UPnP
//
//  This is the object representation of a content directory item. 
//  This would be used to represent a solitary item in search results like a 
//  cd track or a video file.
//
//  Created by Patrick Denney on 8/21/11.
//

#import <Foundation/Foundation.h>
#import "ContentDirectoryObject.h"

@interface ContentDirectoryItem : ContentDirectoryObject
{
    NSString *_referenceId;
}

// id property of the item being referred to.
@property (nonatomic, retain) NSString *referenceId;

@end
