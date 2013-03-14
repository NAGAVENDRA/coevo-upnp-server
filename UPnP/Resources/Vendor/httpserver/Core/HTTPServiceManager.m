//
//  HTTPServiceManager.m
//  UPnP
//
//  Created by Patrick Denney on 10/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HTTPServiceManager.h"

@implementation HTTPServiceManager

+ (id)sharedInstance
{
    static HTTPServiceManager *sharedInstance = nil;
    if (!sharedInstance) 
    {
        sharedInstance = [[HTTPServiceManager alloc] init];
    }
    
    return  sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) 
    {
        _registeredServices = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [_registeredServices release];
    _registeredServices = nil;
    
    [super dealloc];
}

#pragma mark private API

- (NSUInteger)indexOfServiceURL:(NSString *)serviceURL inService:(id<HTTPService> *)service
{
    BOOL (^predicate)(id obj, NSUInteger idx, BOOL *stop) = ^(id obj, NSUInteger idx, BOOL *stop)
    {
        if ([obj isEqualToString:serviceURL]) 
        {
            return YES;
        }
        return NO;
    };
    
    for (id<HTTPService> _service in _registeredServices) 
    {
        NSUInteger serviceIndex = [[_service serviceURLs] indexOfObjectPassingTest:predicate];
        if(serviceIndex != NSNotFound)
        {
            if (service) 
            {
                *service = _service;
            }

            return serviceIndex;
        }
    }
    
    return NSNotFound;
}

#pragma mark public API

- (void)registerService:(id<HTTPService>)service
{
    [_registeredServices addObject:service];
}

- (void)unRegisterService:(id<HTTPService>)service
{
    [_registeredServices removeObject:service];
}

- (BOOL)serviceURLIsSupported:(NSString *)serviceURL
{
    if ([self indexOfServiceURL:serviceURL inService:nil] != NSNotFound) 
    {
        return YES;
    }
    return NO;
}

- (NSString *)SOAPresponseForServiceRequest:(NSString *)SOAPrequest forServiceURL:(NSString *)serviceURL
{
    id<HTTPService> service = nil;
    NSUInteger serviceIndex = [self indexOfServiceURL:serviceURL inService:&service];
    
    if (serviceIndex != NSNotFound) 
    {
        return [service responseForSeviceRequestURL:serviceURL withPayload:SOAPrequest];
    }
    return @"";
}

@end
