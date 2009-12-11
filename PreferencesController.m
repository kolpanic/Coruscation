#import "PreferencesController.h"

// TODO: use the agent...
// - add prefs UI to control scheduled update checks - never, weekly or monthly
// - (un)install & (un)load plist in ~/Library/LaunchAgents/ based on user prefs

@implementation PreferencesController

- (IBAction) installAgent:(id)sender {
	NSString *agentApp = [[NSBundle mainBundle] pathForAuxiliaryExecutable:@"CoruscationAgent.app"];
	NSString *identifier = [[NSBundle bundleWithPath:agentApp] bundleIdentifier];
	NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *libraryFolder = [searchPaths objectAtIndex:0];
	NSString *plistPath = [[[libraryFolder stringByAppendingPathComponent:@"LaunchAgents"] stringByAppendingPathComponent:identifier] stringByAppendingPathExtension:@"plist"];
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:identifier forKey:@"Label"];
	[dict setObject:[NSNumber numberWithUnsignedInteger:60] forKey:@"StartInterval"];
	[dict setObject:[NSNumber numberWithBool:NO] forKey:@"RunAtLoad"];
	[dict setObject:[NSArray arrayWithObjects:@"/usr/bin/open", agentApp, nil] forKey:@"ProgramArguments"];
	[dict writeToFile:plistPath atomically:YES];
	
	[NSTask launchedTaskWithLaunchPath:@"/bin/launchctl" arguments:[NSArray arrayWithObjects:@"load", @"-w", plistPath,  nil]];
}

- (id) init {
	self = [super initWithWindowNibName:@"Preferences"];
	return self;
}

- (void) awakeFromNib {
	[self showPrefsPaneForItem:nil];
	self.window.toolbar.selectedItemIdentifier = [[self.window.toolbar.items objectAtIndex:0] itemIdentifier];
}

- (IBAction) showPrefsPaneForItem:(id)sender {
	NSView *prefsView = nil;
	switch ([sender tag]) {
//		case 99 :
//			prefsView = self.advancedView;
//			break;
		default:
			prefsView = self.generalView;
			break;
	}
	if (prefsView) {
		if (self.window.contentView == prefsView)
			return;
		
		if (sender)
			self.window.title = [sender label];
		
		NSView *temp = [[NSView alloc] initWithFrame:[self.window.contentView frame]];
		self.window.contentView = temp;
		
		NSRect newFrame = self.window.frame;
		NSView *contentView = self.window.contentView;
		float dY = (prefsView.frame.size.height - contentView.frame.size.height) * self.window.userSpaceScaleFactor;
		newFrame.origin.y -= dY;
		newFrame.size.height += dY;
		float dX = (prefsView.frame.size.width - contentView.frame.size.width) * self.window.userSpaceScaleFactor;
		newFrame.size.width += dX;
		
		[prefsView setHidden:YES];
		[self.window setFrame:newFrame display:YES animate:YES];
		self.window.contentView = prefsView;
		[prefsView setHidden:NO];
	}
}

@synthesize generalView = _generalView;

@end
