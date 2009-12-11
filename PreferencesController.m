#import "PreferencesController.h"

@implementation PreferencesController

- (IBAction) configureAutomaticUpdates:(id)sender {
	NSString *intervalKey = nil;
	NSInteger tag = [sender tag];
	switch (tag) {
		case 1:
			// weekly (every Monday)
			intervalKey = @"Weekday";
			break;
		case 2:
			// monthly (first of every month)
			intervalKey = @"Day";
			break;
		default:
			// never
			intervalKey = nil;
			break;
	}
	if ([self.fileManager fileExistsAtPath:self.plistPath]) {
		[[NSTask launchedTaskWithLaunchPath:@"/bin/launchctl" arguments:[NSArray arrayWithObjects:@"unload", @"-w", self.plistPath,  nil]] waitUntilExit];
		[self.fileManager removeItemAtPath:self.plistPath error:nil];
	}		
	if (intervalKey != nil) {
		NSMutableDictionary *plist = [NSMutableDictionary dictionary];
		[plist setObject:self.identifier forKey:@"Label"];
		[plist setObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInteger:1] forKey:intervalKey]
				  forKey:@"StartCalendarInterval"];
		[plist setObject:[NSNumber numberWithBool:NO] forKey:@"RunAtLoad"];
		[plist setObject:[NSArray arrayWithObjects:@"/usr/bin/open", self.agentApp, nil] forKey:@"ProgramArguments"];
		[plist writeToFile:self.plistPath atomically:YES];
		
		[NSTask launchedTaskWithLaunchPath:@"/bin/launchctl" arguments:[NSArray arrayWithObjects:@"load", @"-w", self.plistPath,  nil]];
	}
}

- (id) init {
	if (self = [super initWithWindowNibName:@"Preferences"]) {
		_fileManager = [NSFileManager defaultManager];
		_agentApp = [[NSBundle mainBundle] pathForAuxiliaryExecutable:@"CoruscationAgent.app"];
		_identifier = [[NSBundle bundleWithPath:_agentApp] bundleIdentifier];
		NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
		NSString *libraryFolder = [searchPaths objectAtIndex:0];
		_plistPath = [[[libraryFolder stringByAppendingPathComponent:@"LaunchAgents"] stringByAppendingPathComponent:_identifier] stringByAppendingPathExtension:@"plist"];
		
		if ([_fileManager fileExistsAtPath:_plistPath]) {
			NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:_plistPath];
			NSString *intervalKey = [[[plist objectForKey:@"StartCalendarInterval"] allKeys] objectAtIndex:0];
			if ([intervalKey isEqualToString:@"Weekday"])
				_selectedAutomaticUpdatesTag = 1;
			else if ([intervalKey isEqualToString:@"Day"])
				_selectedAutomaticUpdatesTag = 2;
			else
				_selectedAutomaticUpdatesTag = 0;
		} else
			_selectedAutomaticUpdatesTag = 0;
	}
	return self;
}

- (void) awakeFromNib {	
	[self showPrefsPaneForItem:nil];
	self.window.toolbar.selectedItemIdentifier = [[self.window.toolbar.items objectAtIndex:0] itemIdentifier];
}

- (IBAction) showPrefsPaneForItem:(id)sender {
	NSView *prefsView = nil;
	switch ([sender tag]) {
		default:
			prefsView = self.generalView;
			break;
	}
	if (prefsView) {
		if (self.window.contentView == prefsView)
			return;
		
		if (sender)
			self.window.title = [sender label];
		
		NSView *blankVew = [[NSView alloc] initWithFrame:[self.window.contentView frame]];
		self.window.contentView = blankVew;
		
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
@synthesize fileManager = _fileManager;
@synthesize agentApp = _agentApp;
@synthesize identifier = _identifier;
@synthesize plistPath = _plistPath;
@synthesize selectedAutomaticUpdatesTag = _selectedAutomaticUpdatesTag;

@end
