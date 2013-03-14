//
//  ContentDirectoryContainer.h
//  UPnP
//
//  This is the object representation of a content directory container item. 
//  This would be used to represent a collection of items like a music album or a playlist.
//
//  Created by Patrick Denney on 8/21/11.
//

#import <Foundation/Foundation.h>
#import "ContentDirectoryObject.h"

@interface ContentDirectoryContainer : ContentDirectoryObject
{
    NSString *_searchClass;
    NSString *_createClass;
    
    BOOL _isSearchable;
    
    int _childCount;
}

@property (nonatomic, retain) NSString *searchClass;
@property (nonatomic, retain) NSString *createClass;

// When true, the ability to perform a Search() action under a container is enabled, otherwise a Search() under that container will return no results. The default value of this attribute when it is absent on a container is false
@property (nonatomic) BOOL isSearchable;

// Child count for number of elements.
@property (nonatomic) int childCount;

@end
