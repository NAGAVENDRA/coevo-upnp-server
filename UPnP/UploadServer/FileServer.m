//
//  FileServer.m
//  UPnP
//
//  Created by Patrick Denney on 8/27/11.
//

#import "FileServer.h"
#import "DDLog.h"
#import "UIDevice+UPnP.h"
#import "FileServerDAVConnection.h"
#import "NSFileManager+UPnP.h"
#import "UIDevice+UPnP.h"
#import "SharedDefinitions.h"

// This string will be replaced with the web address of the file server in the index.html file
#define SERVER_MACRO @"?SERVER_ADDRESS?"

// This is the HTML comment macro that is a placement holder for the file list
#define FILE_LIST_MACRO @"?FILE_LIST?"

// A list of image files that need to be moved over to the shared directory
#define RESOURCE_LIST [NSArray arrayWithObjects:@"logo.png",nil];

// The names of the shared directories under /Documents
#define VIDEO_DIR @"/Video"
#define AUDIO_DIR @"/Music"
#define IMAGE_DIR @"/Pictures"
#define OTHER_DIR @"/Other"

// The port number that the file server runs on 
#define HTTP_PORT 8088

@interface FileServer (PrivateMethods)

/* Sets up index.html in the documents directory and inserts the file list table
 * If updateResources if YES, also updates CSS file and image files */
- (void)updateFiles:(BOOL)updateResources;

// Build an HTML table with download links to uploaded files to store in index.html
- (NSString *)fileListTable;

@end

@implementation FileServer

@synthesize fileServerAddress = _fileServerAddress;

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_INFO;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

static FileServer *sharedInstance;

+ (id)sharedInstance
{
    if (!sharedInstance) 
    {
        @synchronized(self)
        {
            sharedInstance = [[self alloc] init];  
        }
    }
    return sharedInstance;
}

- (void)startFileServer
{
    DDLogInfo(@"Starting file server on port %i.", HTTP_PORT);
    
    // Create server
    if (httpServer) 
    {
        [httpServer release];
        httpServer = nil;
    }
    
	httpServer = [[HTTPServer alloc] init];
	[httpServer setType:@"_http._tcp."];
    [httpServer setConnectionClass:[FileServerDAVConnection class]];
	[httpServer setPort:HTTP_PORT];
    
    // Creates the shared directories and updates index.html/index.css and moves the files into position
    [self updateFiles:YES];
    
    // Set the base web directory to pull from the shared documents directory
    NSString *filePath = [NSFileManager pathToSharedDocuments];
    DDLogInfo(@"Starting file server root document to:%@.", filePath);
    [httpServer setDocumentRoot:filePath];
	
    NSError *error = nil;
    [httpServer start:&error];
    if (error) 
    {
        DDLogError(@"An error occuring while attemping to start the file server.");
        NSException *fileServerStartError = [NSException exceptionWithName:@"File Server Error."
                                                                    reason:@"Unable to startup file server."
                                                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:        [NSNumber numberWithInt:SETUP_ERROR],
                                                                          @"ExceptionCode", error, @"Error", nil]];
        [fileServerStartError raise];
        return;
    }
    
    self.fileServerAddress = [NSString stringWithFormat:@"http://%@:%i", [UIDevice currentIPAddress], HTTP_PORT]; 
    DDLogInfo(@"Successfully started file server on %@.", self.fileServerAddress);
}

- (void)stopFileServer
{
    
    if (!httpServer) 
    {
        return;
    }
    
    DDLogInfo(@"Stopping file server.");
    [httpServer stop];
    [httpServer release];
    httpServer = nil;
    
}

- (NSString *)updatedFileList
{
    // refresh the index.html in the shared directory
    [self updateFiles:NO];
    return [self fileListTable];
    
    // Post the notification about the files begin updated
    [[NSNotificationCenter defaultCenter] postNotificationName:kSystemUpdated
                                                        object:nil];
}

#pragma mark private support methods

// Takes a list of directory paths and creates them if not already created
- (void)createDirectories:(NSArray *)directories
{
    for (NSString *directory in directories) 
    {
        DDLogInfo(@"Checking to see if directory %@ already exists.", directory);
        if (![[NSFileManager defaultManager] fileExistsAtPath:directory]) 
        {
            DDLogInfo(@"Directory is missing, creating directory %@.", directory);
            NSError *error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:directory 
                                      withIntermediateDirectories:NO
                                                       attributes:nil   
                                                            error:&error];
            
            if(error)
            {
                DDLogError(@"An error occuring while attempting to create the directory %@.", directory);
                NSString *failureReason = [NSString stringWithFormat:@"Cannot create the directory %@ for the following reason %@.", directory, error];
                NSException *noDirException = [NSException exceptionWithName:@"Cannot Create Directory"
                                                                      reason:failureReason
                                                                    userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:DIR_CREATE_ERROR] forKey:@"ExceptionCode"]];
                [noDirException raise];
            }
        }
    }
}

// Given the new file content, create the file if it doesn't already exist or overwrite the old one.
- (void)createOrOverwriteFileWithPath:(NSString *)path andContent:(NSString *)content
{
    NSError *writeError = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) 
    {
        DDLogInfo(@"Creating file at path %@.", path);
        if (![[NSFileManager defaultManager] createFileAtPath:path
                                                     contents:[content dataUsingEncoding:NSUTF8StringEncoding]
                                                   attributes:nil]) 
        {
            NSString *errorString = [NSString stringWithFormat:@"Error creating file at path: %@.", path];
            writeError = [NSError errorWithDomain:errorString code:4 userInfo:nil];
        }
    }
    else
    {
        DDLogInfo(@"Overwriting file at path %@.", path);
        [content writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:&writeError];
    }
    
    if (writeError) 
    {
        DDLogError(@"An error occured while creating or overwriting the file at path: ", path);
        NSException *writeFileException = [NSException exceptionWithName:@"File Write Error"
                                                                  reason:@"Unable to create new file or overwrite old one."
                                                                userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:FILE_WRITE_ERR]  forKey:@"ExceptionCode"]];
        [writeFileException raise];
    }
}

// Used in fileListTable to add a file and a download link to a pre-existing HTML table
- (void)addFileRowToTable:(NSString *)fileName withLink:(NSString *)downloadLink isFirstRow:(BOOL)firstRow isOddRow:(BOOL)oddRow toTable:(NSMutableString *)table
{
    NSString *rowType = oddRow ? @"odd-row" : @"even-row";
    NSString *firstRowClass = firstRow ? @"firstRowCol" : @"";
    [table appendFormat:@"<tr class='%@'><td class='fileNameCol %@'>%@</td>", rowType, firstRowClass, fileName];
    [table appendFormat:@"<td class='downloadCol'><form class='downloadButton %@'><input class='minimal' type='button' value='Download' onClick=\"window.location.href='%@';\"></form></td></tr>", firstRowClass, downloadLink];
}

// build file list HTML table
- (NSString *)fileListTable
{
    NSString *httpAddress = [NSString stringWithFormat:@"http://%@:%i", [UIDevice currentIPAddress], HTTP_PORT];
    NSMutableString *fileListTable = [NSMutableString stringWithString:@"<div class='directoryTitle'>Videos</div>"];
    NSArray *videos = [NSFileManager getSharedVideoFiles];
    NSString *videoBasePath = [httpAddress stringByAppendingFormat:@"%@/", VIDEO_DIR];
    
    // build a table with the list of just video files
    [fileListTable appendString:@"<table id='videos' cellspacing='0'>"];
    for (int count = 0; count < videos.count ; count++) 
    {
        NSString *video = [videos objectAtIndex:count];
        NSString *videoPath = [videoBasePath stringByAppendingString:video];
       [self addFileRowToTable:video 
                      withLink:videoPath 
                    isFirstRow:(count == 0)
                      isOddRow:((count%2)>0) 
                       toTable:fileListTable];
    }
    if (videos.count == 0 ) 
    {
        [fileListTable appendString:@"<tr><td  class='emptyDirectoryRow' colspan=2>No video files found.</td></tr>"];
    }
    [fileListTable appendString:@"</table>"];
    
    NSArray *audioFiles = [NSFileManager getSharedAudioFiles];
    NSString *audioBasePath = [httpAddress stringByAppendingFormat:@"%@/", AUDIO_DIR];
    
    // build a table with the list of just audio files
    [fileListTable appendString:@"<div class='directoryTitle'>Music</div>"];
    [fileListTable appendString:@"<table id='music' cellspacing='0'>"];
    for (int count = 0; count < audioFiles.count ; count++) 
    {
        NSString *audioFile = [audioFiles objectAtIndex:count];
        NSString *audioPath = [audioBasePath stringByAppendingString:audioFile];
        [self addFileRowToTable:audioFile 
                       withLink:audioPath 
                     isFirstRow:(count == 0) 
                       isOddRow:((count%2)>0) 
                        toTable:fileListTable];
    }

    if (audioFiles.count == 0 ) 
    {
        [fileListTable appendString:@"<tr><td  class='emptyDirectoryRow' colspan=2>No music files found.</td></tr>"];
    }
    [fileListTable appendString:@"</table>"];
    
    NSArray *imageFiles = [NSFileManager getSharedImageFiles];
    NSString *imageBasePath = [httpAddress stringByAppendingFormat:@"%@/", IMAGE_DIR];
    
    // build a table with the list of just picture files
    [fileListTable appendString:@"<div class='directoryTitle'>Pictures</div>"];
    [fileListTable appendString:@"<table id='pictures' cellspacing='0'>"];
    for (int count = 0; count < imageFiles.count ; count++) 
    {
        NSString *image = [imageFiles objectAtIndex:count];
        NSString *imagePath = [imageBasePath stringByAppendingString:image];
        [self addFileRowToTable:image 
                       withLink:imagePath 
                     isFirstRow:(count == 0) 
                       isOddRow:((count%2)>0) 
                        toTable:fileListTable];
    }

    if (imageFiles.count == 0 ) 
    {
        [fileListTable appendString:@"<tr><td  class='emptyDirectoryRow' colspan=2>No picture files found.</td></tr>"];
    }
    [fileListTable appendString:@"</table>"];
    
    NSArray *otherFiles = [NSFileManager getSharedOtherFiles];
    NSString *otherBasePath = [httpAddress stringByAppendingFormat:@"%@/", IMAGE_DIR];
    
    // build a table with the list of just picture files
    [fileListTable appendString:@"<div class='directoryTitle'>Other Files</div>"];
    [fileListTable appendString:@"<table id='other' cellspacing='0'>"];
    for (int count = 0; count < otherFiles.count ; count++) 
    {
        NSString *file = [otherFiles objectAtIndex:count];
        NSString *filePath = [otherBasePath stringByAppendingString:file];
        [self addFileRowToTable:file 
                       withLink:filePath 
                     isFirstRow:(count == 0) 
                       isOddRow:((count%2)>0) 
                        toTable:fileListTable];
    }
   
    if (otherFiles.count == 0 ) 
    {
        [fileListTable appendString:@"<tr><td class='emptyDirectoryRow' colspan=2>No other files found.</td></tr>"];
    }
    [fileListTable appendString:@"</table>"];
    
    return fileListTable;
}

- (void)moveOverImageFiles
{
    // moves all the image resource files files
    NSArray *imageFiles = RESOURCE_LIST;
    for (NSString *imageFile in imageFiles) 
    {
        NSString *readPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@", SERVER_BASE_DIR, imageFile]];
        NSString *savePath = [[NSFileManager pathToSharedDocuments] stringByAppendingPathComponent:imageFile];
        
        DDLogInfo(@"Moving image file %@ over to the shared directory.", imageFile);
        if ([[NSFileManager defaultManager] fileExistsAtPath:savePath]) 
        {
            DDLogInfo(@"Removing image file %@ from shared directory to replace it with a newer version.", imageFile); 
            
            // remove any old copies, we are going to move the new images in place
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:savePath error:&error];
            if (error) 
            {
                DDLogError(@"Unable to move image file %@ over to shared directory. Error: %@", imageFile, error);
                NSException *deleteFileException = [NSException exceptionWithName:@"File Delete Error"
                                                                           reason:@"Unable to delete an older image file from the shared directory."
                                                                         userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:FILE_DELETE_ERR] forKey:@"ExceptionCode"]];
                [deleteFileException raise];  
            }
        }
        
        // Move the newer version of the image over to the shared directory
        NSError *copyError = nil;
        if ([[NSFileManager defaultManager] fileExistsAtPath:savePath]) 
        {
            [[NSFileManager defaultManager] removeItemAtPath:savePath error:nil];
        }
        [[NSFileManager defaultManager] copyItemAtPath:readPath toPath:savePath error:&copyError];
        if (copyError) 
        {
            DDLogError(@"Unable to move image file %@ over to shared directory. Error: %@", imageFile, copyError);
            NSException *copyFileException = [NSException exceptionWithName:@"File Move Error"
                                                                     reason:@"Unable to move an image file from the shared directory."
                                                                   userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:FILE_MOVE_ERR] forKey:@"ExceptionCode"]];
            [copyFileException raise];  
        }
        
    }
    
}

- (void)updateFiles:(BOOL)updateResources
{
    // make sure our video/audio/images/other directories are already created in the shared documents directory.
    NSString *documentsDirectory = [NSFileManager pathToSharedDocuments];
    NSString *videoPath = [documentsDirectory stringByAppendingString:VIDEO_DIR];
    NSString *audioPath = [documentsDirectory stringByAppendingString:AUDIO_DIR];
    NSString *imagePath = [documentsDirectory stringByAppendingString:IMAGE_DIR];
    NSString *otherPath = [documentsDirectory stringByAppendingString:OTHER_DIR];
    NSArray *sharedDirectories = [NSArray arrayWithObjects:videoPath ,audioPath, imagePath, otherPath, nil];
    [self createDirectories:sharedDirectories];
    
    // Now we need to get the html file for the file server and update them and move them into the shared directory
    DDLogInfo(@"Attempting to open and read the index.html file for the file server.");
    NSError *fileReadError = nil;
    NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@", SERVER_BASE_DIR, BASE_HTML_FILE]];
    NSString *savePath = [[NSFileManager pathToSharedDocuments] stringByAppendingPathComponent:BASE_HTML_FILE];
    NSString *indexHTML = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&fileReadError];
    if (fileReadError) 
    {
        DDLogError(@"Unable to load index.html.");
        NSException *readFileException = [NSException exceptionWithName:@"File Read Error"
                                                                 reason:@"The index.html file for the file server cannot be read. Cannot continue."
                                                               userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:BAD_INDEX_FILE] forKey:@"ExceptionCode"]];
        [readFileException raise];  
    }
    
    DDLogInfo(@"Updating index.html and moving it to the shared directory.");
    NSString *httpAddress = [NSString stringWithFormat:@"http://%@:%i/", [UIDevice currentIPAddress], HTTP_PORT];
    NSString *updatedIndexHTML = [indexHTML stringByReplacingOccurrencesOfString:SERVER_MACRO withString:httpAddress];
    NSString *fileList = [self fileListTable];
    
    // replace the file list macro.  This list will have to be updated as we add files to the server.
    updatedIndexHTML = [updatedIndexHTML stringByReplacingOccurrencesOfString:FILE_LIST_MACRO withString:fileList];
    [self createOrOverwriteFileWithPath:savePath andContent:updatedIndexHTML];
    
    if (updateResources) 
    {
        // Now to move over the CSS file as well 
        NSString *cssPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@", SERVER_BASE_DIR, CSS_SUPPORT_FILE]];
        NSString *saveCssPath = [[NSFileManager pathToSharedDocuments] stringByAppendingPathComponent:CSS_SUPPORT_FILE];
        NSString *indexCSS = [NSString stringWithContentsOfFile:cssPath encoding:NSUTF8StringEncoding error:&fileReadError];
        
        DDLogInfo(@"Updating index.css and moving it to the shared directory.");
        if (fileReadError) 
        {
            DDLogError(@"Unable to load index.css.");
            NSException *readFileException = [NSException exceptionWithName:@"File Read Error"
                                                                     reason:@"The index.css file for the file server cannot be read. Cannot continue."
                                                                   userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:BAD_CSS_FILE] forKey:@"ExceptionCode"]];
            [readFileException raise];  
        }
        [self createOrOverwriteFileWithPath:saveCssPath andContent:indexCSS];
        [self moveOverImageFiles];
    }
}

- (void)dealloc
{
    self.fileServerAddress = nil;
    
    [super dealloc];
}
@end
