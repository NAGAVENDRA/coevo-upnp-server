//
//  Youtube.h
//  library
//
//  Created by Chi-Cheng Lin on 11/12/4.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLElement.h"
#import "Http.h"

@interface Youtube : NSObject

/**
 * @brief Get youtube playlists by account.
 * @param account Account.
 * @retval The Play list array.
 */

+(NSArray *) getYoutubePlaylistsByAccount:(NSString *)account;

/**
 * @brief Get youtube playlist by playlistId.
 * @param account Account.
 * @retval The Play list array.
 */

+(NSArray *) getYoutubePlaylistByPlaylistId:(NSString *)playlistId;

@end
