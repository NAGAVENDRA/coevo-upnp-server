//
//  AudioItem.h
//  UPnP
//
//  An ‘audioItem’ instance represents a piece of content that, when rendered, generates some audio.
//
//  Created by Patrick Denney on 8/22/11.
//

#import <Foundation/Foundation.h>
#import "ContentDirectoryItem.h"

@interface AudioItem : ContentDirectoryItem
{
    NSString *_genre; 
    NSString *_description;
    NSString *_longDescription;
    NSString *_publisher;
    NSString *_language;
    NSString *_relation;
    NSString *_rights;
}

// Name of the genre to which an object belongs.
@property (nonatomic, retain) NSString *genre;

// Item description
@property (nonatomic, retain) NSString *description;

// A longer description that may or may not be displayed
@property (nonatomic, retain) NSString *longDescription;

// An entity responsible for making the resource available.
@property (nonatomic, retain) NSString *publisher;

// Language of the resource. RFC 1766, e.g. of the form "en-US".
@property (nonatomic, retain) NSString *language;

// 	A related resource. Values must be properly escaped URIs as described in [RFC 2396].
@property (nonatomic, retain) NSString *relation;

// Information about rights held in and over the resource.
@property (nonatomic, retain) NSString *rights;

// Returns true if file is an audio file
+ (BOOL)isAudioItem:(NSString *)filename;

@end
