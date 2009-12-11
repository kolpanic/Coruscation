#import "PreferencesController.h"

NSString *const launchctl = @"/bin/launchctl";

@implementation PreferencesController

- (IBAction) configureAutomaticUpdates:(id)sender {
	NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
	NSString *intervalKey = nil;
	NSNumber *intervalValue = nil;
	switch ([sender tag]) {
		case 1:
			// weekly, on the same day as today
			intervalKey = @"Weekday";
			intervalValue = [NSNumber numberWithInt:([components weekday] - 1)];
			break;
		case 2:
			// monthly, on the same date as today
			intervalKey = @"Day";
			intervalValue = [NSNumber numberWithInt:MIN(28, [components day])];
			break;
		default:
			// never
			intervalKey = nil;
			intervalValue = nil;
			break;
	}
	if ([self launchInfo]) {
		[[NSTask launchedTaskWithLaunchPath:launchctl arguments:[NSArray arrayWithObjects:@"unload", @"-w", self.identifier,  nil]] waitUntilExit];
		[self.fileManager removeItemAtPath:self.plistPath error:nil];
	}
	if (intervalKey != nil && intervalValue != nil) {
		NSMutableDictionary *plist = [NSMutableDictionary dictionary];
		[plist setObject:self.identifier forKey:@"Label"];
		[plist setObject:[NSDictionary dictionaryWithObject:intervalValue forKey:intervalKey] forKey:@"StartCalendarInterval"];
		[plist setObject:[NSNumber numberWithBool:NO] forKey:@"RunAtLoad"];
		[plist setObject:[NSArray arrayWithObjects:@"/usr/bin/open", self.agentApp, nil] forKey:@"ProgramArguments"];
		[plist writeToFile:self.plistPath atomically:YES];
		
		[NSTask launchedTaskWithLaunchPath:launchctl arguments:[NSArray arrayWithObjects:@"load", @"-w", self.plistPath,  nil]];
	}
}

- (NSDictionary *) launchInfo {
	NSPipe *outPipe = [NSPipe new];
	NSTask *task = [NSTask new];
	task.launchPath = launchctl;
	task.arguments = [NSArray arrayWithObjects:@"list", @"-x", self.identifier,  nil];
	task.standardOutput = outPipe;
	task.standardError = outPipe;
	[task launch];
	NSDictionary *launchInfo = nil;
	NSData *data = [[outPipe fileHandleForReading] readDataToEndOfFile];
	if (data) {
		NSString *launchInfoPlist = [NSTemporaryDirectory() stringByAppendingPathComponent:@"launchInfo.plist"];
		[data writeToFile:launchInfoPlist atomically:YES];
		launchInfo = [NSDictionary dictionaryWithContentsOfFile:launchInfoPlist];
		[self.fileManager removeItemAtPath:launchInfoPlist error:nil];
	}
	return launchInfo;
}

- (id) init {
	if (self = [super initWithWindowNibName:@"Preferences"]) {
		_fileManager = [NSFileManager defaultManager];
		_agentApp = [[NSBundle mainBundle] pathForAuxiliaryExecutable:@"CoruscationAgent.app"];
		_identifier = [[NSBundle bundleWithPath:_agentApp] bundleIdentifier];
		NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
		NSString *libraryFolder = [searchPaths objectAtIndex:0];
		_plistPath = [[[libraryFolder stringByAppendingPathComponent:@"LaunchAgents"] stringByAppendingPathComponent:_identifier] stringByAppendingPathExtension:@"plist"];
		
		BOOL plistExists = [_fileManager fileExistsAtPath:_plistPath];
		NSDictionary *launchInfo = [self launchInfo];
		if (!launchInfo) {
			_selectedAutomaticUpdatesTag = 0;
			if (plistExists)
				[_fileManager removeItemAtPath:_plistPath error:nil];
		} else {
			if (plistExists) {
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
