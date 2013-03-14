//
//  Movie.h
//  UPnP
//
//  
// 
//  Created by Patrick Denney on 8/23/11.
//

#import <Foundation/Foundation.h>
#import "VideoItem.h"

@interface Movie : VideoItem
{
    NSString *_storageMedium;
    NSString *_channelName;
    NSString *_scheduledStartTime;
    NSString *_scheduledEndTime;
    
    int _dvdRegionCode;
}

// Indicates the type of storage medium used for the content. Potentially useful for user- interface purposes.
// Acceptable values are: 
// “UNKNOWN”,”DV”, “MINI-DV”, “VHS”, ”W-VHS”, “S-VHS”, “D-VHS”, “VHSC”, “VIDEO8”, “HI8”, “CD-ROM”, 
// “CD-DA”, “CD-R”, “CD-RW”, “VIDEO-CD”, ”SACD”, “MD-AUDIO”, “MD-PICTURE”, “DVD-ROM”, “DVD-VIDEO”, “DVD-R”, “DVD+RW”, 
// “DVD-RW”, “DVD-RAM”, “DVD-AUDIO”. “DAT”,“LD”, “HDD”
@property (nonatomic, retain) NSString *storageMedium;

// Used for identification of channels themselves, or information associated with a piece of recorded content
@property (nonatomic, retain) NSString *channelName;

// ISO 8601, of the form " yyyy- mm-ddThh:mm:ss". Used to indicate the start time of a schedule program, 
// indented for use by tuners
@property (nonatomic, retain) NSString *scheduledStartTime;

// ISO 8601, of the form " yyyy- mm-ddThh:mm:ss". Used to indicate the end time of a scheduled program, 
// indented for use by tuners
@property (nonatomic, retain) NSString *scheduledEndTime;

// Region code of the DVD disc
@property (nonatomic) int dvdRegionCode;

@end
