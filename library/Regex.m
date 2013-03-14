//
//  regex.m
//  library
//
//  Created by Chi-Cheng Lin on 11/11/6.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "Regex.h"

@implementation Regex

+(BOOL) isMatchingPattern:(NSString *)pattern string:(NSString *)string
{
    BOOL ismatch;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *firstMatch = [regex firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];

    ismatch = firstMatch ? YES : NO;
    return ismatch;
}

@end
