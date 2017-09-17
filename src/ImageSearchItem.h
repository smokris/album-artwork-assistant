//
//  GoogleImageItem.h
//  Album Artwork Assistant
//
//  Created by Marc Liyanage on 14.07.08.
//  Copyright 2008-2009 Marc Liyanage <http://www.entropy.ch>. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ImageSearchItem.h"
#import <Quartz/Quartz.h>

#define HTTP_SUCCESS 200

@interface ImageSearchItem : NSObject <QLPreviewItem> {
	NSDictionary *searchResult;
	NSData *__unsafe_unretained imageData;
	NSData * imageData2;
	NSURL * _fileUrl;
	NSString *__unsafe_unretained source;
}

@property(unsafe_unretained) NSData *imageData;
//@property(unsafe_unretained) NSURL *fileUrl;
@property(unsafe_unretained) NSString *source;

- (id)initWithSearchResult:(NSDictionary *)searchResult;
- (NSComparisonResult)areaCompare:(ImageSearchItem *)anItem;
- (NSString *)url;
- (NSImage *)tinyImage;

- (NSString *)imageUID;
- (NSString *)imageRepresentationType;
- (id)imageRepresentation;
- (NSString *)imageSubtitle;
- (NSData *)dataError:(NSError **)error;
- (NSURL *)fileUrl;

@end
