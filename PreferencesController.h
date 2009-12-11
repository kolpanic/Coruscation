#import <Cocoa/Cocoa.h>

@interface PreferencesController : NSWindowController {
@private
	NSView *_generalView;
	NSFileManager *_fileManager;
	NSString *_agentApp;
	NSString *_identifier;
	NSString *_plistPath;
	NSUInteger _selectedAutomaticUpdatesTag;
}

- (IBAction) configureAutomaticUpdates:(id)sender;
- (IBAction) showPrefsPaneForItem:(id) sender;
- (NSDictionary *) launchInfo;

@property (retain) IBOutlet NSView *generalView;
@property (retain) NSFileManager *fileManager;
@property (copy) NSString *agentApp;
@property (copy) NSString *identifier;
@property (copy) NSString *plistPath;
@property (assign) NSUInteger selectedAutomaticUpdatesTag;

@end
