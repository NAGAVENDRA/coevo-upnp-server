//
//  VideoItem.h
//  UPnP
//
//  A ‘videoItem’ instance represents a piece of content that, when rendered, generates some video.
// 
//  Created by Patrick Denney on 8/23/11.
//

#import <Foundation/Foundation.h>
#import "ContentDirectoryItem.h"

@interface VideoItem : ContentDirectoryItem
{
    NSString *_genre; 
    NSString *_description;
    NSString *_longDescription;
    NSString *_producer;
    NSString *_director;
    NSString *_actor;
    NSString *_rating;
    NSString *_publisher;
    NSString *_language;
    NSString *_relation;
}

// Name of the genre to which an object belongs.
@property (nonatomic, retain) NSString *genre;

// Item description
@property (nonatomic, retain) NSString *description;

// A longer description that may or may not be displayed
@property (nonatomic, retain) NSString *longDescription;

// The video producer
@property (nonatomic, retain) NSString *producer;

// The video director
@property (nonatomic, retain) NSString *director;

// Name of an actor appearing in a video item
@property (nonatomic, retain) NSString *actor;

// Rating of the object’s resource, for ‘parental control’ filtering purposes, such as “R”, “PG-13”, “X”, etc.,.
@property (nonatomic, retain) NSString *rating;

// An entity responsible for making the resource available.
@property (nonatomic, retain) NSString *publisher;

// Language of the resource. RFC 1766, e.g. of the form "en-US".
@property (nonatomic, retain) NSString *language;

// 	A related resource. Values must be properly escaped URIs as described in [RFC 2396].
@property (nonatomic, retain) NSString *relation;

// Returns true if file is a video file
+ (BOOL)isVideoItem:(NSString *)filename;

@end
