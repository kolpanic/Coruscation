#import "PreferencesController.h"
#import <ServiceManagement/ServiceManagement.h>
#import "asl.h"

const NSInteger weeklyStartInterval = 604800;
const NSInteger monthlyStartInterval = 2592000;

@implementation PreferencesController

- (IBAction) configureAutomaticUpdates:(id)sender {
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

	BOOL errorOccurred = NO;
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
		[plist setObject:[NSNumber numberWithBool:YES] forKey:@"RunAtLoad"];
		[plist setObject:self.agentExecutable forKey:@"Program"];
		[plist writeToFile:self.plistPath atomically:YES];

		CFErrorRef *smError = NULL;
		if (!SMJobSubmit(kSMDomainUserLaunchd, (CFDictionaryRef)plist, NULL, smError)) {
			errorOccurred = YES;
			if (smError != NULL)
				NSLog(@"Error in SMJobSubmit: %@", (NSError *)smError);
			else
				NSLog(@"Error in SMJobSubmit without details. Check /var/db/launchd.db/com.apple.launchd.peruser.NNN/overrides.plist for %@ set to disabled.", self.agentIdentifier);
			self.selectedAutomaticUpdatesTag = 0;
			[self.intervalPopUpButton selectItemWithTag:0];
		}

		if (smError != NULL)
			CFRelease(smError);
	}
	if (errorOccurred) {
		NSString *informativeText = NSLocalizedString(@"An error occurred when attempting to configure scheduled update checks.", @"message informative text");
		NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Scheduling Error", @"message text")
										 defaultButton:nil
									   alternateButton:NSLocalizedString(@"View Console…", @"button title")
										   otherButton:nil
							 informativeTextWithFormat:informativeText];
		[alert beginSheetModalForWindow:self.window
						  modalDelegate:self
						 didEndSelector:@selector(errorAlertDidEnd:returnCode:contextInfo:)
							contextInfo:nil];
	}
}

- (void) errorAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	if (returnCode == NSAlertAlternateReturn) {
		NSArray *appSupport = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
		NSString *queryPath = [[[[[appSupport objectAtIndex:0] stringByAppendingPathComponent:@"Console"] stringByAppendingPathComponent:@"ASLQueries"] stringByAppendingPathComponent:@"Coruscation"] stringByAppendingPathExtension:@"aslquery"];
		NSArray *aslQuery = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:
		                                              [NSString stringWithUTF8String:ASL_KEY_MSG], @"key",
		                                              [NSNumber numberWithInt:ASL_QUERY_OP_EQUAL | ASL_QUERY_OP_PREFIX | ASL_QUERY_OP_SUFFIX], @"op",
		                                              @"Coruscation", @"value",
		                                              nil]];
		[aslQuery writeToFile:queryPath atomically:YES];
		[[NSWorkspace sharedWorkspace] openFile:queryPath withApplication:@"Console"];
	}
}

- (id) init {
	if (self = [super initWithWindowNibName:@"Preferences"]) {
		i_fileManager = [NSFileManager defaultManager];
		NSString *agentAppBundle = [[NSBundle mainBundle] pathForAuxiliaryExecutable:@"CoruscationAgent.app"];
		i_agentExecutable = [[[agentAppBundle stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:@"MacOS"] stringByAppendingPathComponent:@"CoruscationAgent"];
		i_agentIdentifier = [[NSBundle bundleWithPath:agentAppBundle] bundleIdentifier];
		[[NSUserDefaults standardUserDefaults] addSuiteNamed:i_agentIdentifier];
		NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
		NSString *agentsFolder = [[searchPaths objectAtIndex:0] stringByAppendingPathComponent:@"LaunchAgents"];
		[i_fileManager createDirectoryAtPath:agentsFolder withIntermediateDirectories:YES attributes:nil error:nil];
		i_plistPath = [[agentsFolder stringByAppendingPathComponent:i_agentIdentifier] stringByAppendingPathExtension:@"plist"];

		BOOL plistExists = [i_fileManager fileExistsAtPath:i_plistPath];
		CFDictionaryRef launchInfo = SMJobCopyDictionary(kSMDomainUserLaunchd, (CFStringRef)i_agentIdentifier);
		if (launchInfo != NULL) {
			CFRelease(launchInfo);
			if (plistExists) {
				NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:i_plistPath];
				NSInteger startInterval = [[plist objectForKey:@"StartInterval"] integerValue];
				if (startInterval == weeklyStartInterval)
					i_selectedAutomaticUpdatesTag = 1;
				else if (startInterval == monthlyStartInterval)
					i_selectedAutomaticUpdatesTag = 2;
				else
					i_selectedAutomaticUpdatesTag = 0;

			} else
				i_selectedAutomaticUpdatesTag = 0;
		} else {
			i_selectedAutomaticUpdatesTag = 0;
			if (plistExists)
				[i_fileManager removeItemAtPath:i_plistPath error:nil];
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

@synthesize generalView = i_generalView;
@synthesize fileManager = i_fileManager;
@synthesize agentExecutable = i_agentExecutable;
@synthesize agentIdentifier = i_agentIdentifier;
@synthesize plistPath = i_plistPath;
@synthesize selectedAutomaticUpdatesTag = i_selectedAutomaticUpdatesTag;
@synthesize intervalPopUpButton = i_intervalPopUpButton;

@end
