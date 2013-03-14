//
//  ConnectionManagerServiceErrorCodes.h
//  UPnP
//
//  Created by Patrick Denney on 9/29/11.
//

/**********************************************************************
  Possible UPnP Connection Manager Service errors that can be thrown
 *********************************************************************/

// Invalid args ( One of following: not enough IN arguments, too many IN 
//                arguments, no IN argument by that name, one or  more  IN 
//                arguments are of the wrong data type )
#define INVALID_ARGS 402
#define INVALID_ARGS_DESC @"Invalid args"

// Not in network ( The connection cannot be established because  the ConnectionManagers 
//                  are not part of the same physical network )
#define NOT_IN_NETWORK 707 
#define NOT_IN_NETWORK_DESC @"ConnectionManagers are not in the same physical network."

// Incompatible protocol info ( The  connection cannot be established because the protocol 
//                              info parameter is incompatible )
#define INC_PROTO_INFO 701
#define INC_PROTO_INFO_DESC @"Incompatible protocol info"

// Incompatible direction ( The connection cannot be established because the directions of the 
//                          involved ConnectionManagers (source/sink) are incompatible )
#define INC_DIRECTION 702
#define INC_DIRECTION_DESC @"Incompatible direction"

// Insufficient network resources ( The connection cannot be established because there  are 
//                                  insufficient network resources (bandwidth, channels, etc.) )
#define NO_RESOURCES 703
#define NO_RESOURCES_DESC @"Insufficient network resources"

// Local restriction (  The connection cannot be established because of local restrictions 
//                      in the device. This might happen, for  example,  when  physical
//                      resources on the device are already in use by other connections )
#define LOCAL_RESTRICTION 704
#define LOCAL_RESTRICTION_DESC @"Local device restriction"

// Access denied ( The connection cannot be  established because the client is not 
//                 permitted to access the specified ConnectionManager )
#define ACCESS_DENIED 705 
#define ACCESS_DENIED_DESC @"Access denied"

// Invalid connection reference ( The  connection  reference  argument does not refer to a valid
//                                connection established by this service )
#define INVALID_REF 706
#define INVALID_REF_DESC @"Unknown connectionID"

