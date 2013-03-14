//
//  SharedContentBuffer.m
//  UPnP
//
//  Created by Patrick Denney on 9/17/11.
//

#import "SharedContentBuffer.h"
#import "HTTPLogging.h"

// HTTP methods: http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html
// HTTP headers: http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html
// HTTP status codes: http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html

static const int httpLogLevel = HTTP_LOG_LEVEL_WARN;

@implementation SharedContentBuffer

@synthesize contentBuffer = _contentBuffer;

+ (SharedContentBuffer *)sharedInstance
{
    static SharedContentBuffer *sharedInstance = nil;
    
    if (!sharedInstance) 
    {
        sharedInstance = [[SharedContentBuffer alloc] init];
    }
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) 
    {
        self.contentBuffer = [NSMutableData dataWithCapacity:1024];
    }
    
    return self;
}

- (void)dealloc
{
    self.contentBuffer = nil;
    
    [super dealloc];
}

- (void)appendDataToBuffer:(NSData *)data withOffsetStart:(NSUInteger)start andOffsetEnd:(NSUInteger)end
{
    if (start < 2) 
    {
        // reset the buffer 
        [self clearBuffer];
    }
    
    if ((start > 2) && (_lastContentOffset != (start-1))) 
    {
        /* We don't support uploading from multiple clients at the same time.
         * Or could happen during some awkward loss of connection scenarios */
        HTTPLogError(@"Multiple asynchronous uploads not supported.");
    }
    
    _lastContentOffset = end;
    [self.contentBuffer appendData:data];
}

- (void)clearBuffer
{
    self.contentBuffer = [NSMutableData dataWithCapacity:1024];
}

@end
