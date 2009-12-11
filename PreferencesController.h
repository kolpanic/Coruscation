#import <Cocoa/Cocoa.h>

@interface PreferencesController : NSWindowController {
@private
	NSView *_generalView;
}

- (IBAction) showPrefsPaneForItem:(id) sender;
- (IBAction) installAgent:(id)sender;

@property (retain) IBOutlet NSView *generalView;

@end
