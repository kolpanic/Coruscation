#import "PreferencesController.h"
#import <ServiceManagement/ServiceManagement.h>

const NSInteger weeklyStartInterval = 604800;
const NSInteger monthlyStartInterval = 2592000;

@implementation PreferencesController

- (IBAction) configureAutomaticUpdates:(id)sender {
	CFDictionaryRef launchInfo = SMJobCopyDictionary(kSMDomainUserLaunchd, (CFStringRef)self.agentIdentifier);
	if (launchInfo != NULL) {
		CFRelease(launchInfo);
		CFErrorRef *error = NULL;
		if (!SMJobRemove(kSMDomainUserLaunchd, (CFStringRef)self.agentIdentifier, NULL, YES, error))
			NSLog(@"Error in SMJobRemove: %@", (NSError *)error);
		if (error != NULL)
			CFRelease(error);
		[self.fileManager removeItemAtPath:self.plistPath error:nil];
	}
	
	NSInteger startInterval = 0;
	NSInteger tag = [sender tag];
	if (tag == 1)
		startInterval = weeklyStartInterval;
	else if (tag == 2)
		startInterval = monthlyStartInterval;
	if (startInterval > 0) {
		NSMutableDictionary *plist = [NSMutableDictionary dictionary];
		[plist setObject:self.agentIdentifier forKey:@"Label"];
		[plist setObject:[NSNumber numberWithInteger:startInterval] forKey:@"StartInterval"];
		[plist setObject:[NSNumber numberWithBool:NO] forKey:@"RunAtLoad"];
		[plist setObject:self.agentExecutable forKey:@"Program"];
		[plist writeToFile:self.plistPath atomically:YES];
		
		CFErrorRef *error = NULL;
		if (!SMJobSubmit(kSMDomainUserLaunchd, (CFDictionaryRef)plist, NULL, error))
			NSLog(@"Error in SMJobSubmit: %@", (NSError *)error);
		if (error != NULL)
			CFRelease(error);
	}
}

- (id) init {
	if (self = [super initWithWindowNibName:@"Preferences"]) {
		_fileManager = [NSFileManager defaultManager];
		NSString *agentAppBundle = [[NSBundle mainBundle] pathForAuxiliaryExecutable:@"CoruscationAgent.app"];
		_agentExecutable = [[[agentAppBundle stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:@"MacOS"] stringByAppendingPathComponent:@"CoruscationAgent"];
		_agentIdentifier = [[NSBundle bundleWithPath:agentAppBundle] bundleIdentifier];
		NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
		NSString *libraryFolder = [searchPaths objectAtIndex:0];
		_plistPath = [[[libraryFolder stringByAppendingPathComponent:@"LaunchAgents"] stringByAppendingPathComponent:_agentIdentifier] stringByAppendingPathExtension:@"plist"];
		
		BOOL plistExists = [_fileManager fileExistsAtPath:_plistPath];
		CFDictionaryRef launchInfo = SMJobCopyDictionary(kSMDomainUserLaunchd, (CFStringRef)_agentIdentifier);
		if (launchInfo != NULL) {
			CFRelease(launchInfo);
			if (plistExists) {
				NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:_plistPath];
				NSInteger startInterval = [[plist objectForKey:@"StartInterval"] integerValue];
				if (startInterval == weeklyStartInterval)
					_selectedAutomaticUpdatesTag = 1;
				else if (startInterval == monthlyStartInterval)
					_selectedAutomaticUpdatesTag = 2;
				else
					_selectedAutomaticUpdatesTag = 0;
			} else
				_selectedAutomaticUpdatesTag = 0;
		} else {
			_selectedAutomaticUpdatesTag = 0;
			if (plistExists)
				[_fileManager removeItemAtPath:_plistPath error:nil];
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
@synthesize agentExecutable = _agentExecutable;
@synthesize agentIdentifier = _agentIdentifier;
@synthesize plistPath = _plistPath;
@synthesize selectedAutomaticUpdatesTag = _selectedAutomaticUpdatesTag;
@synthesize scheduleDescription = _scheduleDescription;

@end
