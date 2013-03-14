//
//  SharedContentBuffer.h
//  UPnP
//
//  The shared content buffer is used to store temporary PUT information 
//  to support broken up files using the Content-Length HTTP header property.
//  It currently only supports uploads of a single file at a time. 
//  Which should be sufficient for just the iPhone but needs to handle
//  multiple files in the future.
//
//  Created by Patrick Denney on 9/17/11.
//

#import <Foundation/Foundation.h>

@interface SharedContentBuffer : NSObject
{
    NSUInteger _lastContentOffset;
    
    NSMutableData *_contentBuffer;
}

@property (nonatomic, retain) NSMutableData *contentBuffer;

+ (SharedContentBuffer *)sharedInstance;

/* Append data to the buffer with the offset byte start and offset byte end.
 * If the start offset byte is 1, then any previous contents of the buffer
 * if thrown away. */
- (void)appendDataToBuffer:(NSData *)data withOffsetStart:(NSUInteger)start andOffsetEnd:(NSUInteger)end;

// Clear out the buffer
- (void)clearBuffer;

@end
