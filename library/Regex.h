//
//  regex.h
//  library
//
//  Created by Chi-Cheng Lin on 11/11/6.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

@interface Regex : NSObject

/**
 * @brief Compare string by regular expressions.
 * @param pattern Regular expressions.
 * @param string Matching string.
 * @retval BOOL Matching result.
 */

+(BOOL) isMatchingPattern:(NSString *)pattern string:(NSString *)string;

@end
