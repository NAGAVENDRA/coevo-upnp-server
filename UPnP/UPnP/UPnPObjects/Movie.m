//
//  Movie.m
//  UPnP
//
//  Created by Patrick Denney on 8/23/11.
//

#import "Movie.h"

@implementation Movie

@synthesize storageMedium = _storageMedium;
@synthesize channelName = _channelName;
@synthesize scheduledStartTime = _scheduledStartTime;
@synthesize scheduledEndTime = _scheduledEndTime;
@synthesize dvdRegionCode = _dvdRegionCode;

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
//    &lt;upnp:class&gt;object.item.videoItem&lt;/upnp:class&gt;
//    &lt;dc:date&gt;2012-05-22T16:57:10&lt;/dc:date&gt;&lt;res  protocolInfo=&quot;http-get:*:video/mp4:*&quot; resolution=&quot;400x222&quot; size=&quot;42623176&quot; bitrate=&quot;95145&quot; duration=&quot;0:07:27.000&quot; nrAudioChannels=&quot;2&quot; sampleFrequency=&quot;22050&quot;&gt;http://200.200.200.50:50002/v/NDLNA/385.mp4&lt;/res&gt;&lt;/item&gt;
//    &lt;item id=&quot;33$@386&quot; parentID=&quot;33$170&quot; restricted=&quot;1&quot;&gt;
//    &lt;dc:title&gt;麗車坊-求救篇CF.wmv&lt;/dc:title&gt;
    
    return [NSString stringWithFormat:@"<item id=\"%@\" parentID=\"%@\" restricted=\"1\"><dc:title>%@</dc:title><upnp:class>object.item.videoItem</upnp:class><dc:date>2011-09-08T20:25:29</dc:date><res protocolInfo=\"http-get:*:video/mp4:*\" resolution=\"640x478\">%@%@</res></item>", self.id, self.parentId, self.title, [[FileServer sharedInstance] fileServerAddress], [self getFullPath]];
}

- (void)dealloc
{
    self.storageMedium = nil;
    self.channelName = nil;
    self.scheduledStartTime = nil;
    self.scheduledEndTime = nil;
    
    [super dealloc];
}

@end
