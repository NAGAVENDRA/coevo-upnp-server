//
//  MusicTrack.m
//  UPnP
//
//  Created by Patrick Denney on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MusicTrack.h"

@implementation MusicTrack

@synthesize artist = _artist;
@synthesize album = _album;
@synthesize playlist = _playlist;
@synthesize contributor = _contributor;
@synthesize date = _date;
@synthesize storageMedium = _storageMedium;
@synthesize originalTrackNumber = _originalTrackNumber;

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
//    &lt;upnp:class&gt;object.item.audioItem.musicTrack&lt;/upnp:class&gt;
//    &lt;dc:date&gt;2011-01-01&lt;/dc:date&gt;&lt;upnp:album&gt;那些年，我們一起追的女孩電影原聲帶&lt;/upnp:album&gt;&lt;upnp:artist&gt;合輯&lt;/upnp:artist&gt;&lt;dc:creator&gt;合輯&lt;/dc:creator&gt;&lt;upnp:genre&gt;Soundtrack&lt;/upnp:genre&gt;&lt;upnp:originalTrackNumber&gt;6&lt;/upnp:originalTrackNumber&gt;&lt;upnp:albumArtURI dlna:profileID=&quot;JPEG_TN&quot;&gt;http://200.200.200.50:50002/transcoder/jpegtnscaler.cgi/ebdart/17.jpg&lt;/upnp:albumArtURI&gt;&lt;res  protocolInfo=&quot;http-get:*:audio/mpeg:*&quot; size=&quot;2940928&quot; bitrate=&quot;28875&quot; duration=&quot;0:01:39.000&quot; nrAudioChannels=&quot;2&quot; sampleFrequency=&quot;44100&quot;&gt;http://200.200.200.50:50002/m/NDLNA/17.mp3&lt;/res&gt;&lt;/item&gt;
//    &lt;item id=&quot;22$@25&quot; parentID=&quot;22$108&quot; restricted=&quot;1&quot;&gt;
//    &lt;dc:title&gt;各自的翅膀&lt;/dc:title&gt;
    
    return [NSString stringWithFormat:@"<item id=\"%@\" parentID=\"%@\" restricted=\"1\"><dc:title>%@</dc:title><upnp:class>object.item.audioItem.musicTrack</upnp:class><upnp:album>%@</upnp:album><dc:date>2011-09-08T20:25:29</dc:date><upnp:genre>Soundtrack</upnp:genre><res protocolInfo=\"http-get:*:audio/mpeg:*\" resolution=\"640x478\">%@%@</res></item>", self.id, self.parentId, self.title, self.album, [[FileServer sharedInstance] fileServerAddress], [self getFullPath]];
}

- (void)dealloc
{
    self.artist = nil;
    self.album = nil;
    self.playlist = nil;
    self.contributor = nil;
    self.date = nil;
    self.storageMedium = nil;
    
    [super dealloc];
}

@end
