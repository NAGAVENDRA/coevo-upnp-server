//
//  UPNPObject.h
//  UPnP
//
//  This is a Objective-C repesentation of the XML base content directory class defined in the 
//  UPnP standards that can be found here:
//  http://www.upnp.org/specs/av/UPnP-av-ContentDirectory-v1-Service.pdf
//  It is used by various resources to pass information back-and-forth between the client points
//  and the service providers. All client objects used in services should be derived from this
//  class.
//  
//  Created by Patrick Denney on 8/21/11.
//

#import <Foundation/Foundation.h>
#import "UPnPObject.h"

typedef enum {
    WRITABLE,
    PROTECTED, 
    NOT_WRITABLE, 
    UNKNOWN, 
    MIXED  
} write_status;

@interface ContentDirectoryObject : NSObject <UPnPObject>
{
    NSString *_id;
    NSString *_title;
    NSString *_creator;
    NSString *_resourceURI;
    NSString *_parentId;
    
    write_status _writeStatus;
    
    BOOL _isRestricted;

}

// An identifier for the object. The value of each object id property must be unique with respect to the Content Director.
@property (nonatomic, retain) NSString *id;

// id property of object’s parent. The parentID of the Content Directory ‘root’ container must be set to the reserved
// value of “-1”. No other parentID attribute of any other Content Directory object may take this value.
@property (nonatomic, retain) NSString *parentId;

// The object name
@property (nonatomic, retain) NSString *title;

// Primary content creator or owner of the object
@property (nonatomic, retain) NSString *creator;

// Resource, typically a media file, associated with the object. Values must be properly escaped URIs as described in [RFC 2396].
@property (nonatomic, retain) NSString *resourceURI;

// When true, ability to modify a given object is confined to the Content Directory Service. Control point
// metadata write access is disabled.
@property (nonatomic) BOOL isRestricted;

// When present, controls the modifiability of the resources of a
// given object. Ability of a Control Point to change writeStatus of a given resource(s) is implementation dependent.
@property (nonatomic) write_status writeStatus;

// Init with the a dictionary full of key-value pairs for the properties.
- (id)initObjectFromDictionary:(NSDictionary *)dictionary;

// Returns the XML representation of object would should be sent back to the client.
- (NSString *)xmlRepresentation:(NSString *)childElement;

@end
