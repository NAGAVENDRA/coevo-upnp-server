//
//  FileServerDAVConnection.h
//  UPnP
//
//  This is an implementation of the DAVConnection class included in the cocoa http server project found here:
//  http://code.google.com/p/cocoahttpserver/
// 
//  It includes an update for GET request to respond to certain AJAX request to update the content
//  dynamically on the file server page.
// 
//  Created by Patrick Denney on 9/11/11.
//

#import <Foundation/Foundation.h>
#import "DAVConnection.h"

// This is the commad used to request an updated file list. Performed after an upload.
#define UPDATE_FILE_COMMAND @"/updateFileList"

@interface FileServerDAVConnection : DAVConnection

@end
