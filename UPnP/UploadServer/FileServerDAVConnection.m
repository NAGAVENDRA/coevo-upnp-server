//
//  FileServerDAVConnection.m
//  UPnP
//
//  Created by Patrick Denney on 9/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FileServerDAVConnection.h"
#import "FileServer.h"
#import "HTTPDataResponse.h"

@implementation FileServerDAVConnection

- (id)init
{
    self = [super init];
    if (self) 
    {

    }
    
    return self;
}

- (NSObject<HTTPResponse>*) httpResponseForMethod:(NSString*)method URI:(NSString*)path
{
    if ([method isEqualToString:@"GET"]) 
    {
        if ([path isEqualToString:UPDATE_FILE_COMMAND]) 
        {
            // Client requested an updated file list
            NSString *htmlFileList = [[FileServer sharedInstance] updatedFileList];
            NSData *htmlReponseData = [htmlFileList dataUsingEncoding:NSUTF8StringEncoding];
            return [[[HTTPDataResponse alloc] initWithData:htmlReponseData] autorelease];
        }
    }
    
    return [super httpResponseForMethod:method URI:path];
}

@end
