//
//  Photo.m
//  UPnP
//
//  Created by Patrick Denney on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Photo.h"

@implementation Photo

@synthesize album = _album;

- (id)initObjectFromDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) 
    {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    
    return self;
}

- (NSString *)xmlRepresentation:(NSString *)childElement
{
//    &lt;upnp:class&gt;object.item.imageItem.photo&lt;/upnp:class&gt;
//    &lt;upnp:album&gt;2011 乾杯&lt;/upnp:album&gt;&lt;dc:date&gt;2011-09-08T20:24:51&lt;/dc:date&gt;&lt;res  protocolInfo=&quot;http-get:*:image/jpeg:*&quot; resolution=&quot;640x478&quot;&gt;http://200.200.200.50:50002/bp/NDLNA/3028.jpg&lt;/res&gt;&lt;/item&gt;&lt;item id=&quot;32$@3025&quot; parentID=&quot;32$150&quot; restricted=&quot;1&quot;&gt;
//    &lt;dc:title&gt;IMG_1127&lt;/dc:title&gt;
    
    return [NSString stringWithFormat:@"<item id=\"%@\" parentID=\"%@\" restricted=\"1\"><dc:title>%@</dc:title><upnp:class>object.item.imageItem.photo</upnp:class><upnp:album>%@</upnp:album><dc:date>2011-09-08T20:25:29</dc:date><res protocolInfo=\"http-get:*:image/jpeg:*\" resolution=\"640x478\">%@%@</res></item>", self.id, self.parentId, self.title, self.album, [[FileServer sharedInstance] fileServerAddress], [self getFullPath]];
}

- (void)dealloc
{
    self.album = nil;
    
    [super dealloc];
}

@end
