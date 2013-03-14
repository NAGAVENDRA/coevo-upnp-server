//
//  Xml.h
//  library
//
//  Created by Chi-Cheng Lin on 11/11/7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "GDataXMLNode.h"

@interface GDataXMLElement (COEVO)

/**
 * @brief Get elements by xpath.
 * @param name Tag name.
 * @param namespace XML namespace.
 * @retval NSArray The XML elements (GDataXMLElement, GDataXMLElement, ..).
 */

- (NSArray *) getElementsByXPath:(NSString *)xpath namespace:(NSString *)namespace;

/**
 * @brief Get XML elements by xpath.
 * @param name Tag name.
 * @param namespace XML namespace.
 * @retval NSArray The XML elements (GDataXMLElement, GDataXMLElement, ..).
 */

- (NSString *) getValueByXPath:(NSString *)xpath namespace:(NSString *)namespace;

/**
 * @brief Get text by tag name.
 * @param name Tag name.
 * @param namespace XML namespace.
 * @retval NSArray The XML elements (GDataXMLElement, GDataXMLElement, ..).
 */

- (NSString *) getValueByTagName:(NSString *)name namespace:(NSString *)namespace;

/**
 * @brief Get text by tag name.
 * @param name Tag name.
 * @param namespace XML namespace.
 * @retval NSString The text value that you target.
 */

- (NSArray *) getValuesByTagName:(NSString *)name namespace:(NSString *)namespace;

/**
 * @brief Get elements by tag name.
 * @param name Tag name.
 * @param namespace XML namespace.
 * @retval NSArray The elements.
 */

- (NSArray *) getElementsByTagName:(NSString *)name namespace:(NSString *)namespace;

/**
 * @brief Get dictionaries in array by tag name.
 * @param name Tag name.
 * @param namespace XML namespace.
 * @retval NSArray The dictionaries in array that you target.
 */

- (NSArray *) getDictInArrayByTagName:(NSString *)name namespace:(NSString *)namespace;

/**
 * @brief XML to NSDictionary.
 * @retval NSDictionary The NSDictionary.
 */

- (NSDictionary *) toDict;

@end
