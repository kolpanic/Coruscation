#import "PreferencesController.h"
#import <ServiceManagement/ServiceManagement.h>

@implementation PreferencesController

- (IBAction) configureAutomaticUpdates:(id)sender {
	NSDictionary *intervalDict = nil;
	NSInteger tag = [sender tag];
	if (tag == 1 || tag == 2) {
		NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
		if (tag == 1)
			intervalDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:([components weekday] - 1)]
													   forKey:@"Weekday"];                                                                    // weekly, on the same day as today
		else if (tag == 2)
			intervalDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:MIN(28, [components day])]
													   forKey:@"Day"];                                                                    // monthly, on the same date as today
	}
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
	if (intervalDict != nil) {
		NSMutableDictionary *plist = [NSMutableDictionary dictionary];
		[plist setObject:self.agentIdentifier forKey:@"Label"];
		[plist setObject:intervalDict forKey:@"StartCalendarInterval"];
		[plist setObject:[NSNumber numberWithBool:NO] forKey:@"RunAtLoad"];
		[plist setObject:[NSArray arrayWithObjects:@"/usr/bin/open", self.agentApp, nil] forKey:@"ProgramArguments"];
		[plist writeToFile:self.plistPath atomically:YES];
		
		CFErrorRef *error = NULL;
		if (!SMJobSubmit(kSMDomainUserLaunchd, (CFDictionaryRef)plist, NULL, error))
			NSLog(@"Error in SMJobSubmit: %@", (NSError *)error);
		if (error != NULL)
			CFRelease(error);
	}
	[self updateScheduleDescriptionForIntervalDict:intervalDict];
}

- (id) init {
	if (self = [super initWithWindowNibName:@"Preferences"]) {
		_fileManager = [NSFileManager defaultManager];
		_agentApp = [[NSBundle mainBundle] pathForAuxiliaryExecutable:@"CoruscationAgent.app"];
		_agentIdentifier = [[NSBundle bundleWithPath:_agentApp] bundleIdentifier];
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
				NSString *intervalKey = [[intervalDict allKeys] objectAtIndex:0];
				if ([intervalKey isEqualToString:@"Weekday"])
					_selectedAutomaticUpdatesTag = 1;
				else if ([intervalKey isEqualToString:@"Day"])
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
		NSString *intervalKey = [[dict allKeys] objectAtIndex:0];
		NSNumber *intervalValue = [dict objectForKey:intervalKey];
		if ([intervalKey isEqualToString:@"Day"]) {
			NSUInteger remainder = [intervalValue unsignedIntegerValue] % 10;
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
			self.scheduleDescription = [NSString stringWithFormat:NSLocalizedString(@"Every month on the %@%@", @"schedule description"), intervalValue, suffix];
		} else if ([intervalKey isEqualToString:@"Weekday"]) {
			NSString *day = nil;
			switch ([intervalValue unsignedIntegerValue] + 1) {
				case 1:
					day = NSLocalizedString(@"Sunday", @"day of week");
					break;
				case 2:
					day = NSLocalizedString(@"Monday", @"day of week");
					break;
				case 3:
					day = NSLocalizedString(@"Tuesday", @"day of week");
					break;
				case 4:
					day = NSLocalizedString(@"Wednesday", @"day of week");
					break;
				case 5:
					day = NSLocalizedString(@"Thursday", @"day of week");
					break;
				case 6:
					day = NSLocalizedString(@"Friday", @"day of week");
					break;
				case 7:
					day = NSLocalizedString(@"Saturday", @"day of week");
					break;
				default:
					day = nil;
					break;
			}
			self.scheduleDescription = [NSString stringWithFormat:NSLocalizedString(@"Every week on %@", @"schedule description"), day];
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
@synthesize agentApp = _agentApp;
@synthesize agentIdentifier = _agentIdentifier;
@synthesize plistPath = _plistPath;
@synthesize selectedAutomaticUpdatesTag = _selectedAutomaticUpdatesTag;
@synthesize scheduleDescription = _scheduleDescription;

@end
