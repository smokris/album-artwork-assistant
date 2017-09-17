//
//  TrackGroup.h
//  Album Artwork Assistant
//
//  Created by Marc Liyanage on 18.08.08.
//  Copyright 2008-2009 Marc Liyanage <http://www.entropy.ch>. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface TrackGroup : NSManagedObject  
{
	NSImage *tinyAlbumImage;
}

@property (strong) NSData *imageData;
@property (strong) NSString *title;
@property (strong) NSSet *tracks;

@end

@interface TrackGroup (CoreDataGeneratedAccessors)
- (void)addTracksObject:(NSManagedObject *)value;
- (void)removeTracksObject:(NSManagedObject *)value;
- (void)addTracks:(NSSet *)value;
- (void)removeTracks:(NSSet *)value;
- (NSImage *)tinyAlbumImage;
- (NSArray *)tracksData;
@end

