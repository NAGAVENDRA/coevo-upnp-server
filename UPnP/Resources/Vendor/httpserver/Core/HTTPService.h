//
//  HTTPService.h
//  
//  Created by Patrick Denney on 10/4/11.
//

#import <Foundation/Foundation.h>

@protocol HTTPService <NSObject>

@required

// The URLs supported by the registered web service
- (NSArray *)serviceURLs;

// Given a supported service URL, and SOAP message, provide the service return information
- (NSString *)responseForSeviceRequestURL:(NSString *)url withPayload:(NSString *)soapMessage;

@end
