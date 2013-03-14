//
//  http.m
//  utility
//
//  Created by Chi-Cheng Lin on 11/11/4.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "Http.h"

@implementation Http

+(NSString *) posturl:(NSString *)url body:(NSString *)body encoding:(NSStringEncoding)encoding headers:(NSDictionary *)headers
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSURL *connection = [[NSURL alloc] initWithString:[url stringByAddingPercentEscapesUsingEncoding:encoding]];
    [request setURL:connection];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    // append to http header
    for (NSString *key in headers) {
        NSString *value = [headers objectForKey:key];
        [request setValue:value forHTTPHeaderField:key];
    }
    
    if (body != nil) {
        [request setHTTPMethod:@"POST"];
    }
    
    [request setHTTPBody:[body dataUsingEncoding:encoding]];
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    return [[NSString alloc] initWithData:response encoding:encoding];
}

@end
