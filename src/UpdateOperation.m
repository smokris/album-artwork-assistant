//
//  UpdateOperation.m
//  Album Artwork Assistant
//
//  Created by Marc Liyanage on 14.07.08.
//  Copyright 2008-2009 Marc Liyanage <http://www.entropy.ch>. All rights reserved.
//

#import "UpdateOperation.h"
#import "GTMNSAppleScript+Handler.h"
#import "NSObject+DDExtensions.h"
#import <Carbon/Carbon.h>



@interface NSDictionary (UserDefinedRecord)



// AppleEvent record descriptor (typeAERecord) with arbitrary keys



+(NSDictionary*)scriptingUserDefinedRecordWithDescriptor:(NSAppleEventDescriptor*)desc;

-(NSAppleEventDescriptor*)scriptingUserDefinedRecordDescriptor;



@end



@interface NSArray (UserList)



// AppleEvent list descriptor (typeAEList)



+(NSArray*)scriptingUserListWithDescriptor:(NSAppleEventDescriptor*)desc;

-(NSAppleEventDescriptor*)scriptingUserListDescriptor;



@end



@interface NSAppleEventDescriptor (GenericObject)



// AppleEvent descriptor that may be a record, a list, or other object

// This is necessary to handle a list or a record contained in another list or record



+(NSAppleEventDescriptor*)descriptorWithObject:(id)object;

-(id)objectValue;



@end



@interface NSAppleEventDescriptor (URLValue)



// AppleEvenf file URL (typeFileURL) descriptor



+(NSAppleEventDescriptor*)descriptorWithURL:(NSURL*)url;

-(NSURL*)urlValue;



@end



@implementation NSDictionary (UserDefinedRecord)



+(NSDictionary*)scriptingUserDefinedRecordWithDescriptor:(NSAppleEventDescriptor*)desc

{

	NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:0];

	NSAppleEventDescriptor* userFieldItems = [desc descriptorForKeyword:keyASUserRecordFields];

	NSInteger numItems = [userFieldItems numberOfItems];



	for ( NSInteger itemIndex = 1; itemIndex <= numItems - 1; itemIndex += 2 ) {

		NSAppleEventDescriptor* keyDesc = [userFieldItems descriptorAtIndex:itemIndex];

		NSAppleEventDescriptor* valueDesc = [userFieldItems descriptorAtIndex:itemIndex + 1];

		NSString* keyString = [keyDesc stringValue];

		id value = [valueDesc objectValue];



		if ( keyString != nil && value != nil )

			[dict setObject:value forKey:keyString];

	}



	return [NSDictionary dictionaryWithDictionary:dict];

}



-(NSAppleEventDescriptor*)scriptingUserDefinedRecordDescriptor

{

	NSAppleEventDescriptor* recordDesc = [NSAppleEventDescriptor recordDescriptor];

	NSAppleEventDescriptor* userFieldDesc = [NSAppleEventDescriptor listDescriptor];

	NSInteger userFieldIndex = 1;



	for ( id key in self ) {

		if ( [key isKindOfClass:[NSString class]] ) {

			NSString* valueString = nil;

			id value = [self objectForKey:key];



			if ( ! [value isKindOfClass:[NSString class]] )

				valueString = [NSString stringWithFormat:@"%@", value];

			else

				valueString = value;



			NSAppleEventDescriptor* valueDesc = [NSAppleEventDescriptor descriptorWithString:valueString];

			NSAppleEventDescriptor* keyDesc = [NSAppleEventDescriptor descriptorWithString:key];



			if ( valueDesc != nil && keyDesc != nil ) {

				[userFieldDesc insertDescriptor:keyDesc atIndex:userFieldIndex++];

				[userFieldDesc insertDescriptor:valueDesc atIndex:userFieldIndex++];

			}

		}

	}



	[recordDesc setDescriptor:userFieldDesc forKeyword:keyASUserRecordFields];



	return recordDesc;

}





@end



@implementation NSArray (UserList)



+(NSArray*)scriptingUserListWithDescriptor:(NSAppleEventDescriptor*)desc

{

	NSMutableArray* array = [NSMutableArray arrayWithCapacity:0];

	NSInteger numItems = [desc numberOfItems];



	for ( NSInteger itemIndex = 1; itemIndex <= numItems; itemIndex++ ) {

		NSAppleEventDescriptor* itemDesc = [desc descriptorAtIndex:itemIndex];



		[array addObject:[itemDesc objectValue]];

	}



	return [NSArray arrayWithArray:array];

}



-(NSAppleEventDescriptor*)scriptingUserListDescriptor

{

	NSAppleEventDescriptor* listDesc = [NSAppleEventDescriptor listDescriptor];

	NSInteger itemIndex = 1;



	for ( id item in self ) {

		NSAppleEventDescriptor* itemDesc = [NSAppleEventDescriptor descriptorWithObject:item];



		[listDesc insertDescriptor:itemDesc atIndex:itemIndex++];

	}



	return listDesc;

}



@end





@implementation NSAppleEventDescriptor (GenericObject)



+(NSAppleEventDescriptor*)descriptorWithObject:(id)object

{

	NSAppleEventDescriptor* desc = nil;



	if ( [object isKindOfClass:[NSArray class]] ) {

		NSArray*    array = (NSArray*)object;



		desc = [array scriptingUserListDescriptor];

	}

	else if ( [object isKindOfClass:[NSDictionary class]] ) {

		NSDictionary*   dict = (NSDictionary*)object;



		desc = [dict scriptingUserDefinedRecordDescriptor];

	}

	else if ( [object isKindOfClass:[NSString class]] ) {

		desc = [NSAppleEventDescriptor descriptorWithString:(NSString*)object];

	}

	else if ( [object isKindOfClass:[NSURL class]] ) {

		desc = [NSAppleEventDescriptor descriptorWithURL:(NSURL*)object];

	}

	else {

		NSString* valueString = [NSString stringWithFormat:@"%@", object];



		desc = [NSAppleEventDescriptor descriptorWithString:valueString];

	}



	return desc;

}



-(id)objectValue

{

	DescType    descType = [self descriptorType];

	DescType    bigEndianDescType = 0;

	id          object = nil;





	switch ( descType ) {

		case typeUnicodeText:

		case typeUTF8Text:

			object = [self stringValue];

			break;

		case typeFileURL:

			object = [self fileURLValue];

			break;

		case typeAEList:

			object = [NSArray scriptingUserListWithDescriptor:self];

			break;

		case typeAERecord:

			object = [NSDictionary scriptingUserDefinedRecordWithDescriptor:self];

			break;

		case typeSInt16:

		case typeUInt16:

		case typeSInt32:

		case typeUInt32:

		case typeSInt64:

		case typeUInt64:

			object = [NSNumber numberWithInteger:(NSInteger)[self int32Value]];

			break;

		default:

			bigEndianDescType = EndianU32_NtoB(descType);

			NSLog(@"Creating NSData for AE desc type %.4s.", (char*)&bigEndianDescType);

			object = [self data];

			break;

	}



	return object;

}



@end












@implementation UpdateOperation

//@synthesize fileUrl;

- (id)initWithTracks:(NSArray *)t imageData:(NSData *)iData statusDelegate:(id <StatusDelegateProtocol>)sd {
	self = [super init];
	if (!self) return self;
	tracks = t;
	imageData = iData;
	statusDelegate = sd;
	didComplete = NO;
	return self;
}


- (void)main {

	@try {

		if (!self.fileUrl) {
			@throw [NSException exceptionWithName:@"TempFileWrite" reason:NSLocalizedString(@"cant_write_tempfile", @"") userInfo:nil];
		}
		
		NSString *tempFilePath = [self.fileUrl path];

		[statusDelegate startBusy:[NSString stringWithFormat:NSLocalizedString(@"adding_image_to_%@", @""), [self albumTitle]]];

		NSString *scptPath = [[NSBundle mainBundle] pathForResource:@"embed-artwork" ofType:@"scpt" inDirectory:@"Scripts"];
		NSURL *scptUrl = [NSURL fileURLWithPath:scptPath];
		NSDictionary *errorDict = nil;
		NSAppleScript *script = [[NSAppleScript alloc] initWithContentsOfURL:scptUrl error:&errorDict];
		if (errorDict) {
			@throw [NSException exceptionWithName:@"AppleScriptLoad" reason:[errorDict valueForKey:NSAppleScriptErrorBriefMessage] userInfo:nil];
		}



//		NSArray *params = [NSArray arrayWithObjects:tracks, tempFilePath, nil];
//		[[script dd_invokeOnMainThreadAndWaitUntilDone:YES] gtm_executePositionalHandler:@"embedArtwork" parameters:params error:&errorDict];
//		if (errorDict) {
//			@throw [NSException exceptionWithName:@"AppleScriptExecute" reason:[errorDict valueForKey:NSAppleScriptErrorBriefMessage] userInfo:nil];
//		}


		// create the first parameter
//		NSAppleEventDescriptor* firstParameter = [NSAppleEventDescriptor descriptorWithString:@"Message from my app."];

		// create and populate the list of parameters (in our case just one)
		NSAppleEventDescriptor* parameters = [NSAppleEventDescriptor listDescriptor];
		[parameters insertDescriptor:[tracks scriptingUserListDescriptor] atIndex:1];
		[parameters insertDescriptor:[NSAppleEventDescriptor descriptorWithString:tempFilePath] atIndex:2];

		// create the AppleEvent target
		ProcessSerialNumber psn = {0, kCurrentProcess};
		NSAppleEventDescriptor* target =
		[NSAppleEventDescriptor
		 descriptorWithDescriptorType:typeProcessSerialNumber
		 bytes:&psn
		 length:sizeof(ProcessSerialNumber)];

		// create an NSAppleEventDescriptor with the script's method name to call,
		// this is used for the script statement: "on show_message(user_message)"
		// Note that the routine name must be in lower case.
		NSAppleEventDescriptor* handler =
		[NSAppleEventDescriptor descriptorWithString:
		 [@"embedArtwork" lowercaseString]];

		// create the event for an AppleScript subroutine,
		// set the method name and the list of parameters
		NSAppleEventDescriptor* event =
		[NSAppleEventDescriptor appleEventWithEventClass:kASAppleScriptSuite
												 eventID:kASSubroutineEvent
										targetDescriptor:target
												returnID:kAutoGenerateReturnID
										   transactionID:kAnyTransactionID];
		[event setParamDescriptor:handler forKeyword:keyASSubroutineName];
		[event setParamDescriptor:parameters forKeyword:keyDirectObject];

		// call the event in AppleScript
		NSDictionary *errors=nil;
		if (![script executeAppleEvent:event error:&errors])
		{
			// report any errors from 'errors'
			NSLog(@"errors=%@",errors);
		}








		didComplete = YES;

	}

	@catch (NSException *e) {
		[statusDelegate displayErrorWithTitle:NSLocalizedString(@"cant_set_artwork", @"") message:[e reason]];
	}

	@finally {
		[statusDelegate clearBusy];
	}

}



- (BOOL)didComplete {
	return didComplete;
}



- (NSString *)albumTitle {
	return [[tracks objectAtIndex:0] valueForKey:@"track_album"];
}


- (NSURL *)fileUrl {
	if (_fileUrl) return _fileUrl;

	NSString *tempFilePath = [NSString stringWithFormat:@"%@/%@", NSTemporaryDirectory(), @"album-artwork-assistant.tmp"];

	if (![imageData writeToFile:tempFilePath atomically:YES]) {
		NSLog(@"Unable to store image data to temp file '%@'", tempFilePath);
		return nil;
	}
	_fileUrl = [NSURL fileURLWithPath:tempFilePath];
	return _fileUrl;
}








@end
