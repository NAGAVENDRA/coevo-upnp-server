//
//  main.m
//  UPnP
//
//  Created by Patrick Denney on 8/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UPnPAppDelegate.h"

int main(int argc, char *argv[])
{
    int retVal = 0;
    @autoreleasepool {
        retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([UPnPAppDelegate class]));
    }
    return retVal;
}
