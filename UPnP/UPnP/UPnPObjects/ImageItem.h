//
//  ImageItem.h
//  UPnP
//
//  An ‘imageItem’ instance represents a piece of content that, when rendered, generates some still image.
//
//  Created by Patrick Denney on 8/23/11.
//

#import <Foundation/Foundation.h>
#import "ContentDirectoryItem.h"

@interface ImageItem : ContentDirectoryItem
{
    NSString *_description;
    NSString *_longDescription;
    NSString *_rating;
    NSString *_publisher;
    NSString *_storageMedium;
    NSString *_rights;
    NSString *_date;
}

// Item description
@property (nonatomic, retain) NSString *description;

// A longer description that may or may not be displayed
@property (nonatomic, retain) NSString *longDescription;

// Rating of the object’s resource, for ‘parental control’ filtering purposes, such as “R”, “PG-13”, “X”, etc.,.
@property (nonatomic, retain) NSString *rating;

// An entity responsible for making the resource available.
@property (nonatomic, retain) NSString *publisher;

// Indicates the type of storage medium used for the content. Potentially useful for user- interface purposes.
// Acceptable values are: 
// “UNKNOWN”,”DV”, “MINI-DV”, “VHS”, ”W-VHS”, “S-VHS”, “D-VHS”, “VHSC”, “VIDEO8”, “HI8”, “CD-ROM”, 
// “CD-DA”, “CD-R”, “CD-RW”, “VIDEO-CD”, ”SACD”, “MD-AUDIO”, “MD-PICTURE”, “DVD-ROM”, “DVD-VIDEO”, “DVD-R”, “DVD+RW”, 
// “DVD-RW”, “DVD-RAM”, “DVD-AUDIO”. “DAT”,“LD”, “HDD”
@property (nonatomic, retain) NSString *storageMedium;

// Information about rights held in and over the resource.
@property (nonatomic, retain) NSString *rights;

// ISO 8601, of the form "YYYY- MM-DD",
@property (nonatomic, retain) NSString *date;

// Returns true if file is an image file
+ (BOOL)isImageItem:(NSString *)filename;

@end
