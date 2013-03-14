#import "PUTResponse.h"
#import "HTTPLogging.h"
#import "SharedContentBuffer.h"

// HTTP methods: http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html
// HTTP headers: http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html
// HTTP status codes: http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html

static const int httpLogLevel = HTTP_LOG_LEVEL_WARN;

@interface PUTResponse(private)
- (BOOL) writeFileToPath:(NSString *)path withBody:(id)body didOverwrite:(BOOL*)overwrite;
@end

@implementation PUTResponse

- (id) initWithFilePath:(NSString*)path headers:(NSDictionary*)headers body:(id)body 
{
  if ((self = [super init])) 
  {
    
    BOOL didOverwrite = NO;
    BOOL success = NO;
    if ([headers objectForKey:@"Content-Range"]) 
    {
      // should be in the format "bytes 0-200/400"
      NSString *contentRange = [headers objectForKey:@"Content-Range"];
      NSArray *components = [contentRange componentsSeparatedByString:@" "];
    
      _status = 400;
      if (components.count < 2) 
      {
          HTTPLogError(@"Content-Range is invalid.");
          return self;
      }
        
      NSArray *splitComponents = [((NSString *)[components objectAtIndex:1]) componentsSeparatedByString:@"/"];
      if (splitComponents.count < 2) 
      {
        HTTPLogError(@"Content-Range is invalid.");
        return self;
      }
      
      NSString *range = [splitComponents objectAtIndex:0];
      NSArray *startEndRange = [range componentsSeparatedByString:@"-"];
      if (startEndRange.count < 2) 
      {
        HTTPLogError(@"Content-Range is invalid.");
        return self;
      }
        
      NSUInteger startRange = [[startEndRange objectAtIndex:0] intValue];
      NSUInteger endRange = [[startEndRange objectAtIndex:1] intValue];
      NSUInteger fullLength = [[splitComponents objectAtIndex:1] intValue];
        
      if ((endRange < startRange) || (fullLength == 0)) 
      {
        HTTPLogError(@"Content-Range is invalid.");
        return self;
      }
    
      if ([body isKindOfClass:[NSData class]]) 
      {
        [[SharedContentBuffer sharedInstance] appendDataToBuffer:body
                                                 withOffsetStart:startRange
                                                    andOffsetEnd:endRange];
      }
 
      if (endRange == fullLength) 
      {
        NSData *fileData = [[SharedContentBuffer sharedInstance] contentBuffer];
        success = [self writeFileToPath:path withBody:fileData didOverwrite:&didOverwrite];
        [[SharedContentBuffer sharedInstance] clearBuffer];
      }
      else  
      {
        success = YES;
      }
    } 
    else 
    {
        success = [self writeFileToPath:path withBody:body didOverwrite:&didOverwrite];
    }
      
    if (success) 
    {
      _status = didOverwrite ? 200 : 201;
    } 
    else 
    {
      HTTPLogError(@"Failed writing upload to \"%@\"", path);
      _status = 403;
    }
  }
  return self;
}

- (id) initWithFilePath:(NSString*)path headers:(NSDictionary*)headers bodyData:(NSData*)body 
{
  return [self initWithFilePath:path headers:headers body:body];
}

- (id) initWithFilePath:(NSString*)path headers:(NSDictionary*)headers bodyFile:(NSString*)body 
{
  return [self initWithFilePath:path headers:headers body:body];
}

- (BOOL) writeFileToPath:(NSString *)path withBody:(id)body didOverwrite:(BOOL*)overwrite 
{
    
    BOOL success = false;
    *overwrite = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if ([body isKindOfClass:[NSString class]]) 
    {
        [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
        success = [[NSFileManager defaultManager] moveItemAtPath:body toPath:path error:NULL];
    } 
    else 
    {
        success = [body writeToFile:path atomically:YES];
    }

    return success;
}

- (UInt64) contentLength 
{
  return 0;
}

- (UInt64) offset 
{
  return 0;
}

- (void) setOffset:(UInt64)offset 
{

}

- (NSData*) readDataOfLength:(NSUInteger)length 
{
  return nil;
}

- (BOOL) isDone 
{
  return YES;
}

- (NSInteger) status 
{
  return _status;
}

- (void)dealloc 
{
  [super dealloc];
}

@end
