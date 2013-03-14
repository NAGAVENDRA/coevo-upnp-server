//
//  storageVolume.h
//  UPnP
//
//  A ‘storageVolume’ instance represents all, or a partition of, some physical storage unit of a single type.
//
//  Created by Patrick Denney on 8/25/11.
//

#import <Foundation/Foundation.h>
#import "ContentDirectoryContainer.h"

@interface StorageVolume : ContentDirectoryContainer
{
    NSString *_storageMedium;
    
    long _storageTotal;
    long _storageUsed;
    long _storageFree;
}

// Indicates the type of storage medium used for the content. Potentially useful for user- interface purposes.
// Acceptable values are: 
// “UNKNOWN”,”DV”, “MINI-DV”, “VHS”, ”W-VHS”, “S-VHS”, “D-VHS”, “VHSC”, “VIDEO8”, “HI8”, “CD-ROM”, 
// “CD-DA”, “CD-R”, “CD-RW”, “VIDEO-CD”, ”SACD”, “MD-AUDIO”, “MD-PICTURE”, “DVD-ROM”, “DVD-VIDEO”, “DVD-R”, “DVD+RW”, 
// “DVD-RW”, “DVD-RAM”, “DVD-AUDIO”. “DAT”,“LD”, “HDD”
@property (nonatomic, retain) NSString *storageMedium;

// Total bytes
@property (nonatomic) long storageTotal;

// Total used bytes
@property (nonatomic) long storageUsed;

// Total free bytes
@property (nonatomic) long storageFree;

@end
