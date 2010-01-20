#import "PreferencesController.h"
#import <ServiceManagement/ServiceManagement.h>

@implementation PreferencesController

- (IBAction) configureAutomaticUpdates:(id)sender {
	NSDictionary *intervalDict = nil;
	NSInteger tag = [sender tag];
	if (tag == 1 || tag == 2) {
		NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit
																	   fromDate:[NSDate date]];
		if (tag == 1) {
			intervalDict = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSNumber numberWithInt:([components weekday] - 1)], @"Weekday",
							[NSNumber numberWithInt:[components hour]], @"Hour",
							[NSNumber numberWithInt:[components minute]], @"Minute",
							nil];
		} else if (tag == 2) {
			intervalDict = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSNumber numberWithInt:MIN(28, [components day])], @"Day",
							[NSNumber numberWithInt:[components hour]], @"Hour",
							[NSNumber numberWithInt:[components minute]], @"Minute",
							nil];
		}
	}
	CFDictionaryRef launchInfo = SMJobCopyDictionary(kSMDomainUserLaunchd, (CFStringRef)self.agentIdentifier);
	if (launchInfo != NULL) {
		CFRelease(launchInfo);
		CFErrorRef *outError = NULL;
		if (!SMJobRemove(kSMDomainUserLaunchd, (CFStringRef)self.agentIdentifier, NULL, YES, outError))
			NSLog(@"Error in SMJobRemove: %@", (NSError *)outError);
		if (outError != NULL)
			CFRelease(outError);
		[self.fileManager removeItemAtPath:self.plistPath error:nil];
	}
	NSString *errorMessage = nil;
	if (intervalDict != nil) {
		NSMutableDictionary *plist = [NSMutableDictionary dictionary];
		[plist setObject:self.agentIdentifier forKey:@"Label"];
		[plist setObject:intervalDict forKey:@"StartCalendarInterval"];
		[plist setObject:[NSNumber numberWithBool:NO] forKey:@"RunAtLoad"];
		[plist setObject:self.agentExecutable forKey:@"Program"];

		CFErrorRef *outError = NULL;
		if (SMJobSubmit(kSMDomainUserLaunchd, (CFDictionaryRef)plist, NULL, outError))
			[plist writeToFile:self.plistPath atomically:YES];
		else {
			NSError *nserr = (NSError *)outError;
			NSLog(@"Error in SMJobSubmit: %@", nserr);
			self.selectedAutomaticUpdatesTag = 0;
			[self.intervalPopUpButton selectItemWithTag:0];
			intervalDict = nil;
			if (nserr == nil)
				errorMessage = @"no more info";
			else
				errorMessage = [nserr localizedDescription];
		}
		if (outError != NULL)
			CFRelease(outError);
	}
	[self updateScheduleDescriptionForIntervalDict:intervalDict];

	if (errorMessage) {
		NSString *informativeText = [NSString stringWithFormat:NSLocalizedString(@"An error occurred when attempting to configure scheduled update checks (%@).", @"message informative text"), errorMessage];
		NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Scheduling Error", @"message text")
										 defaultButton:nil
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:informativeText];
		[alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
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
				NSDictionary *intervalDict = [plist objectForKey:@"StartCalendarInterval"];
				NSNumber *weekday = [intervalDict objectForKey:@"Weekday"];
				NSNumber *day = [intervalDict objectForKey:@"Day"];
				if (weekday != nil)
					_selectedAutomaticUpdatesTag = 1;
				else if (day != nil)
					_selectedAutomaticUpdatesTag = 2;
				else
					_selectedAutomaticUpdatesTag = 0;
				[self updateScheduleDescriptionForIntervalDict:intervalDict];
			} else {
				_selectedAutomaticUpdatesTag = 0;
				[self updateScheduleDescriptionForIntervalDict:nil];
			}
		} else {
			_selectedAutomaticUpdatesTag = 0;
			if (plistExists)
				[_fileManager removeItemAtPath:_plistPath error:nil];
			[self updateScheduleDescriptionForIntervalDict:nil];
		}
	}
	return self;
}

- (void) updateScheduleDescriptionForIntervalDict:(NSDictionary *)dict {
	self.scheduleDescription = NSLocalizedString(@"Manually", @"schedule description");
	if (dict) {
		NSNumber *weekday = [dict objectForKey:@"Weekday"];
		NSNumber *day = [dict objectForKey:@"Day"];
		if (day != nil) {
			NSUInteger remainder = [day unsignedIntegerValue] % 10;
			NSString *suffix = nil;
			switch (remainder) {
				case 1:
					suffix = NSLocalizedString(@"st", @"ordinal suffix");
					break;
				case 2:
					suffix = NSLocalizedString(@"nd", @"ordinal suffix");
					break;
				case 3:
					suffix = NSLocalizedString(@"rd", @"ordinal suffix");
					break;
				default:
					suffix = NSLocalizedString(@"th", @"ordinal suffix");
					break;
			}
			self.scheduleDescription = [NSString stringWithFormat:NSLocalizedString(@"Every month on the %@%@", @"schedule description"), day, suffix];
		} else if (weekday != nil) {
			NSString *dayString = nil;
			switch ([weekday unsignedIntegerValue] + 1) {
				case 1:
					dayString = NSLocalizedString(@"Sunday", @"day of week");
					break;
				case 2:
					dayString = NSLocalizedString(@"Monday", @"day of week");
					break;
				case 3:
					dayString = NSLocalizedString(@"Tuesday", @"day of week");
					break;
				case 4:
					dayString = NSLocalizedString(@"Wednesday", @"day of week");
					break;
				case 5:
					dayString = NSLocalizedString(@"Thursday", @"day of week");
					break;
				case 6:
					dayString = NSLocalizedString(@"Friday", @"day of week");
					break;
				case 7:
					dayString = NSLocalizedString(@"Saturday", @"day of week");
					break;
				default:
					dayString = nil;
					break;
			}
			if (dayString != nil)
				self.scheduleDescription = [NSString stringWithFormat:NSLocalizedString(@"Every week on %@", @"schedule description"), dayString];
		}
	}
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
@synthesize intervalPopUpButton = _intervalPopUpButton;

@end
