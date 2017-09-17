#import <Cocoa/Cocoa.h>
#import "UpdateOperation.h"
#import "StatusDelegateProtocol.h"
#import "QuickLookImageBrowserView.h"
#import "IKImageBrowserFileUrlDataSource.h"
#import "DataStore.h"
#import "ImageSearchItem.h"
#import "TrackGroup.h"
#import <WebKit/WebKit.h>

enum {
	DOUBLECLICK_ACTION_SET_IMMEDIATELY = 0,
	DOUBLECLICK_ACTION_QUEUE           = 1
};

//#define DOUBLECLICK_ACTION_SET_IMMEDIATELY 0
//#define DOUBLECLICK_ACTION_QUEUE 1

#define GOOGLE_IMAGE_RESULT_PAGE_COUNT 2
#define GOOGLE_IMAGE_RESULTS_PER_PAGE 8
#define ERRORDOMAIN @"ch.entropy.album-artwork-assistant"
#define IMAGE_BROWSER_MAX_ITEMS 100

@interface AppDelegate : NSObject <StatusDelegateProtocol, IKImageBrowserFileUrlDataSource> {
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSWindow *window;
	IBOutlet NSDrawer *queueDrawer;
	IBOutlet NSButton *processQueueButton;
    IBOutlet QuickLookImageBrowserView *imageBrowser;
    IBOutlet NSArrayController *queueController;
    IBOutlet NSArrayController *groupsController;
    IBOutlet NSArrayController *albumTracksController;
    IBOutlet NSTabView *tabView;
    IBOutlet WebView *webView;
    IBOutlet NSMenuItem *addImmediatelyMenuItem;
    IBOutlet NSMenuItem *addToQueueMenuItem;
	DOMHTMLElement *highlightedElement;
	NSString *highlightedElementOriginalStyle;
	NSMutableArray *tracks;
	NSString *albumTitle;
	NSMutableArray *images;
	BOOL isImageSelected;
	BOOL isQueueProcessing;
	BOOL isBusy;
	NSString *__unsafe_unretained statusMessage;
	NSMutableArray *__unsafe_unretained queue;
	
	DataStore *__unsafe_unretained dataStore;
}

@property BOOL isBusy;
@property BOOL isImageSelected;
@property BOOL isQueueProcessing;
@property(unsafe_unretained) NSString *statusMessage;
@property(unsafe_unretained) NSMutableArray *queue;
@property(unsafe_unretained) DataStore *dataStore;

- (IBAction)removeSelectedTrackGroups:(id)sender;
- (IBAction)installiTunesAppleScript:(id)sender;
- (BOOL)canInstalliTunesAppleScript;
- (BOOL)copyiTunesAppleScript:(NSError **)error;
- (BOOL)createiTunesShortcut;
- (BOOL)isImageSelectedAndImageBrowserTabActive;
- (IBAction)fetch:(id)sender;
- (IBAction)setAlbumArtwork:(id)sender;
- (IBAction)setAlbumTitle:(NSString *)albumTitle;
- (IBAction)addToQueue:(id)sender;

- (void)loadQueueItemImageData:(ImageSearchItem *)item;
- (void)queueItemImageDataLoaded:(NSData *)data;

- (void)loadImmediateItemImageData:(ImageSearchItem *)item;
- (void)immediateItemImageDataLoaded:(NSData *)data;

- (void)itemImageDataLoadFailed:(ImageSearchItem *)item;


- (BOOL)fetchITunesTrackList;
- (void)prepareAlbumTrackName;
- (void)clearImages;
- (IBAction)findImages:(id)sender;
- (void)doWebSearch:(id)sender;
- (void)doFindImages:(id)sender;
- (void)doFindImagesGoogle;
- (void)doFindImagesAmazon;
- (IBAction)processQueue:(id)sender;
- (void)imageBrowserSelectionDidChange:(IKImageBrowserView *)aBrowser;
- (UpdateOperation *)makeUpdateOperationForImageData:(NSData *)imageData;
- (void)processOneQueueEntry;
- (NSArray *)searchSuggestions;
- (void)cleanupString:(NSMutableString *)input;
- (void)setupDefaults;
- (void)setupNotifications;
- (id)makeTrackGroupWithImageData:(NSData *)imageData;
- (NSUInteger)queueLength;
- (BOOL)isQueueEmpty;
- (void)switchToMainTab;

- (void)removeItemAtIndex:(NSInteger)index;
- (ImageSearchItem *)selectedImage;
- (NSUInteger)selectedImageIndex;
- (void)removeCurrentItemAndWarn;

- (IBAction)debug:(id)sender;
- (void)logProcessSize;

@end
