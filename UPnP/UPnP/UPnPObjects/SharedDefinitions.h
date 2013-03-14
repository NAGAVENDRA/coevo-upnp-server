//
//  SharedDefinitions.h
//  UPnP
//
//  Shared definitions and notifications that can be used between modules
//
//  Created by Patrick Denney on 9/20/11.
//

/**********************************************************************
 Notifications Received
 *********************************************************************/

// Should be triggered when an update even occurs (like a file upload)
#define kSystemUpdated @"SystemUpdated"

// Currently, search is not support. 
#define searchSupported NO

/**********************************************************************
 Possible UPnP Shared errors that can be thrown
 *********************************************************************/

// Invalid Action
#define INVALID_ACTION 401
#define INVALID_ACTION_DESC @"Invalid Action"

// Invalid args
#define INVALID_ARGS 402
#define INVALID_ARGS_DESC @"Invalid args"

// Invalid Var
#define INVALID_VAR 403
#define INVALID_VAR_DESC @"Invalid Var"

// Action failed 
#define ACTION_FAILED 501
#define ACTION_FAILED_DESC @"Action failed"
