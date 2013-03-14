//
//  Youtube.m
//  library
//
//  Created by Chi-Cheng Lin on 11/12/4.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "Youtube.h"

@implementation Youtube

+(NSArray *) getYoutubePlaylistsByAccount:(NSString *)account
{
    NSString *url = [NSString stringWithFormat:@"http://gdata.youtube.com/feeds/api/users/%@/playlists?v=2", account];
    NSString *response = [Http posturl:url body:nil encoding:NSUTF8StringEncoding headers:nil];
    
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithXMLString:response options:0 error:nil];
    GDataXMLElement *root = doc.rootElement;
    
    NSMutableArray *result = [NSMutableArray new];
    for (GDataXMLElement *element in [root elementsForName:@"entry"]) {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        
        [dict addEntriesFromDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:
                                        [element getValueByXPath:@"ns:title" namespace:@"http://www.w3.org/2005/Atom"], @"title",
                                        [element getValueByXPath:@"ns:summary" namespace:@"http://www.w3.org/2005/Atom"], @"summary",
                                        [element getValueByXPath:@"ns:playlistId" namespace:@"http://gdata.youtube.com/schemas/2007"], @"playlistId",
                                        [element getValueByXPath:@"ns:countHint" namespace:@"http://gdata.youtube.com/schemas/2007"], @"countHint",
                                        nil]];
        [result addObject:dict];
    }
    
    return result;
}

+(NSArray *) getYoutubePlaylistByPlaylistId:(NSString *)playlistId
{
    NSString *url = [NSString stringWithFormat:@"http://gdata.youtube.com/feeds/api/playlists/%@?v=2", playlistId];
    NSString *response = [Http posturl:url body:nil encoding:NSUTF8StringEncoding headers:nil];
    
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithXMLString:response options:0 error:nil];
    GDataXMLElement *root = doc.rootElement;
    
    NSMutableArray *result = [NSMutableArray new];
    for (GDataXMLElement *element in [root elementsForName:@"entry"]) {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        GDataXMLElement *e;
        GDataXMLNode *node;
        
        [dict addEntriesFromDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:
                                        [element getValueByXPath:@"ns:title" namespace:@"http://www.w3.org/2005/Atom"], @"title",
                                        [element getValueByXPath:@"ns:author/ns:name" namespace:@"http://www.w3.org/2005/Atom"], @"author",
                                        [element getValueByXPath:@"ns:updated" namespace:@"http://www.w3.org/2005/Atom"], @"updated",
                                        [element getValueByXPath:@"ns:group/ns:description" namespace:@"http://search.yahoo.com/mrss/"], @"description",
                                        nil]];
        
        e = [[element getElementsByXPath:@"ns:statistics" namespace:@"http://gdata.youtube.com/schemas/2007"] objectAtIndex:0];
        node = [e attributeForName:@"viewCount"];
        
        [dict addEntriesFromDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:
                                        [node stringValue] , @"viewCount",
                                        nil]];
        
        e = [[element getElementsByXPath:@"ns:group/ns:thumbnail" namespace:@"http://search.yahoo.com/mrss/"] objectAtIndex:0];
        node = [e attributeForName:@"url"];
        
        [dict addEntriesFromDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:
                                        [node stringValue] , @"thumbnail",
                                        nil]];
        
        e = [[element getElementsByXPath:@"ns:group/ns:content" namespace:@"http://search.yahoo.com/mrss/"] objectAtIndex:0];
        node = [e attributeForName:@"url"];
        
        [dict addEntriesFromDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:
                                        [node stringValue] , @"content",
                                        nil]];
        
        [result addObject:dict];
    }
    
    return result;
}

@end
