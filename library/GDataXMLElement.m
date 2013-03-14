//
//  Xml.m
//  library
//
//  Created by Chi-Cheng Lin on 11/11/7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "GDataXMLElement.h"

@implementation GDataXMLElement (COEVO)

- (NSArray *) getElementsByXPath:(NSString *)xpath namespace:(NSString *)namespace
{
    id ns = nil;
    
    if (namespace != nil) {
        ns = [NSDictionary dictionaryWithObjectsAndKeys:namespace, @"ns", nil];
    }
    
    return [self nodesForXPath:xpath namespaces:ns error:nil];
}

- (NSArray *) getElementsByTagName:(NSString *)name namespace:(NSString *)namespace
{
    NSString *xpath;
    
    if (namespace != nil) {
        xpath = [NSString stringWithFormat:@"//ns:%@", name];
    } else {
        xpath = [NSString stringWithFormat:@"//%@", name];
    }
    
    return [self getElementsByXPath:xpath namespace:namespace];
}

- (NSString *) getValueByXPath:(NSString *)xpath namespace:(NSString *)namespace
{
    NSArray *elements = [self getElementsByXPath:xpath namespace:namespace];
    if ([elements count] > 1) {
        NSException *exception = [NSException exceptionWithName: @"XmlException" reason: @"This method can't use in more than one tag name" userInfo: nil];
        @throw exception;
    } else if ([elements count] == 0) {
        NSException *exception = [NSException exceptionWithName: @"XmlException" reason: @"have no this tag name" userInfo: nil];
        @throw exception;
    }
    
    GDataXMLElement *element = [elements objectAtIndex:0];
    return element.stringValue;
}

- (NSString *) getValueByTagName:(NSString *)name namespace:(NSString *)namespace
{
    NSArray *elements = [self getElementsByTagName:name namespace:namespace];
    if ([elements count] > 1) {
        NSException *exception = [NSException exceptionWithName: @"XmlException" reason: @"This method can't use in more than one tag name" userInfo: nil];
        @throw exception;
    } else if ([elements count] == 0) {
        NSException *exception = [NSException exceptionWithName: @"XmlException" reason: @"have no this tag name" userInfo: nil];
        @throw exception;
    }
    
    GDataXMLElement *element = [elements objectAtIndex:0];
    return element.stringValue;
}

- (NSArray *) getValuesByTagName:(NSString *)name namespace:(NSString *)namespace
{
    NSArray *elements = [self getElementsByTagName:name namespace:namespace];
    NSMutableArray *array = [NSMutableArray new];
    
    for (GDataXMLElement *element in elements) {
        [array addObject:element.stringValue];
    }
    
    return array;
}

- (NSArray *) getDictInArrayByTagName:(NSString *)name namespace:(NSString *)namespace
{
    NSArray *elements = [self getElementsByTagName:name namespace:namespace];
    NSMutableArray *array = [NSMutableArray new];
    
    for (GDataXMLElement *element in elements) {
        NSMutableDictionary *dicts = [NSMutableDictionary new];
        for (GDataXMLElement *child in [element children]) {
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[child stringValue], [child name], nil];
            [dicts addEntriesFromDictionary:dict];
        }
        [array addObject:dicts];
    }
    
    return array;
}

- (BOOL) isTextElement
{
    if ([self childCount] == 1 && [[[self childAtIndex:0] name] isEqualToString:@"text"]) {
        return YES;
    } else {
        return NO;
    }
}

- (NSDictionary *) toDict
{
    if ([self isTextElement]) {
        NSDictionary *result = [[NSDictionary alloc] initWithObjectsAndKeys:[[self childAtIndex:0] stringValue], [self name], nil];
        return result;
    }
    
    NSMutableDictionary *result = [NSMutableDictionary new];
    for (GDataXMLElement *child in [self children]) {
        if ([result objectForKey:[child name]] == nil) {
            NSMutableArray *element = [NSMutableArray new];
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:element, [child name], nil];
            [result addEntriesFromDictionary:dict];
        }
        
        if ([child isTextElement]) {
            [[result objectForKey:[child name]] addObject:[[child childAtIndex:0] stringValue]];
        } else {
            [[result objectForKey:[child name]] addObject:[child toDict]];
        }
    }
    
    return result;
}


@end
