//
//  FileServer.h
//
//  File server will setup an http file server that users can direct their browser to
//  to upload files and store them under the application's shared "Documents" folder.
//
//  Uploaded files will be placed into either the Video, Audio, Image or Other sub-directory
//  
//  Users interact with the file server by going to the http server address stored in 
//  'fileServerAddress'. Because the IP address (and files can change) we have to move the
//  html files and resources over to a dynamic file environment so we move them all over to 
//  the base shared documents directory.
//
//  Created by Patrick Denney on 8/27/11.
//

// *****************************************************************************************
// Error message codes found in the userInfo under "ExceptionCode" for any raised exceptions
// *****************************************************************************************
#define SETUP_ERROR 500          // Error starting the file server
#define DIR_CREATE_ERROR 501     // Error creating one of the shared directories
#define BAD_INDEX_FILE 502       // The index.css file could not be read or created the shared directory
#define BAD_CSS_FILE 503         // The index.css file could not be read or created the shared directory
#define FILE_WRITE_ERR 504       // Error creating or overwriting file.
#define FILE_DELETE_ERR 505      // Error deleting a file from the shared directory
#define FILE_MOVE_ERR 506        // Error moving a file from a resource directory over to the shared directory

#import <Foundation/Foundation.h>
#import "HTTPServer.h"

/* This is the resources directory that will service as the base directory for the index.html page
 * for file uploading.  Change this if you are not using the default directory. */
#define SERVER_BASE_DIR @"FileServer"

/* These are the html files that is how the user interacts with the file server.
 * They should be stored under the SERVER_BASE_DIR */
#define BASE_HTML_FILE @"index.html"
#define CSS_SUPPORT_FILE @"index.css"

@interface FileServer : NSObject
{
    NSString *_fileServerAddress;
    HTTPServer *httpServer;
}

// Display address for the file server
@property (nonatomic, retain) NSString *fileServerAddress;

+ (id)sharedInstance;

// Starts up HTTP file server service and sets the fileServerAddress.
- (void)startFileServer;

// Stops the HTTP file server service.
- (void)stopFileServer;

// Returns an updated list of files for the media server (in HTML)
- (NSString *)updatedFileList;

@end
