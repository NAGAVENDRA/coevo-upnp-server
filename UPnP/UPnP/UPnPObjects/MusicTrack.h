//
//  MusicTrack.h
//  UPnP
//
//  A ‘musicTrack’ instance is a discrete piece of audio that should be interpreted as music (as opposed to, for example, a news broadcast or an audio book)
//
//  Created by Patrick Denney on 8/22/11.
//

#import <Foundation/Foundation.h>
#import "AudioItem.h"

@interface MusicTrack : AudioItem
{
    NSString *_artist;
    NSString *_album;
    NSString *_playlist;
    NSString *_contributor;
    NSString *_date;
    NSString *_storageMedium;
    
    int _originalTrackNumber;
}

// The artist name
@property (nonatomic, retain) NSString *artist;

// The music track album name
@property (nonatomic, retain) NSString *album;

// Name of a playlist to which the item belongs
@property (nonatomic, retain) NSString *playlist;

// It is recommended that contributor includes the name of the primary content creator or owner.
@property (nonatomic, retain) NSString *contributor;

// ISO 8601, of the form "YYYY-MM-DD",
@property (nonatomic, retain) NSString *date;

// Indicates the type of storage medium used for the content. Potentially useful for user- interface purposes.
// Acceptable values are: 
// “UNKNOWN”,”DV”, “MINI-DV”, “VHS”, ”W-VHS”, “S-VHS”, “D-VHS”, “VHSC”, “VIDEO8”, “HI8”, “CD-ROM”, 
// “CD-DA”, “CD-R”, “CD-RW”, “VIDEO-CD”, ”SACD”, “MD-AUDIO”, “MD-PICTURE”, “DVD-ROM”, “DVD-VIDEO”, “DVD-R”, “DVD+RW”, 
// “DVD-RW”, “DVD-RAM”, “DVD-AUDIO”. “DAT”,“LD”, “HDD”
@property (nonatomic, retain) NSString *storageMedium;

// Original track number on an audio CD or other medium.
@property (nonatomic) int originalTrackNumber;

@end
