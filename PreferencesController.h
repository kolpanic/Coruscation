#import <Cocoa/Cocoa.h>

@interface PreferencesController : NSWindowController {
@private
	NSView *i_generalView;
	NSFileManager *i_fileManager;
	NSString *i_agentExecutable;
	NSString *i_agentIdentifier;
	NSString *i_plistPath;
	NSUInteger i_selectedAutomaticUpdatesTag;
	NSString *i_scheduleDescription;
	NSPopUpButton *i_intervalPopUpButton;
}

- (IBAction) configureAutomaticUpdates:(id)sender;
- (void) updateScheduleDescriptionForIntervalDict:(NSDictionary *)dict;
- (IBAction) showPrefsPaneForItem:(id)sender;

@property (retain) IBOutlet NSView *generalView;
@property (retain) NSFileManager *fileManager;
@property (copy) NSString *agentExecutable;
@property (copy) NSString *agentIdentifier;
@property (copy) NSString *plistPath;
@property (assign) NSUInteger selectedAutomaticUpdatesTag;
@property (copy) NSString *scheduleDescription;
@property (retain) IBOutlet NSPopUpButton *intervalPopUpButton;

@end
