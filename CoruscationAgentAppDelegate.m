#import "CoruscationAgentAppDelegate.h"
#import "Sparkle/SUUpdater.h"
#import "FindSparkleBundlesOperation.h"
#import "CheckAppUpdateOperation.h"

@implementation CoruscationAgentAppDelegate

+ (void) initialize {
	if (self == [CoruscationAgentAppDelegate class]) {
		NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
		                          [NSNumber numberWithDouble:10.0], @"UpdateCheckTimeOutInterval",
		                          nil];
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
	}
	[super initialize];
}

- (id) init {
	if (self = [super init]) {
		i_operationQueue = [NSOperationQueue new];
		[i_operationQueue addObserver:self forKeyPath:@"operations" options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"operations"])
		if ([self.operationQueue operationCount] < 1) {
			NSLog(@"No updates found, terminating.");
			[NSApp terminate:nil];
		}
}

- (void) finalize {
	[i_operationQueue removeObserver:self forKeyPath:@"operations"];
	[super finalize];
}
- (BOOL) coruscationAlreadyRunning {
	BOOL coruscationAlreadyRunning = NO;
	for (NSRunningApplication *app in [[NSWorkspace sharedWorkspace] runningApplications]) {
		if ([[[[[app bundleURL] path] lastPathComponent] stringByDeletingPathExtension] isEqualToString:@"Coruscation"]) {
			coruscationAlreadyRunning = YES;
			break;
		}
	}
	return coruscationAlreadyRunning;
}

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {
	if ([self coruscationAlreadyRunning])
		[NSApp terminate:nil];

	NSDate *lastRunDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastRunDate"];
	NSDate *lastScheduledRunDate = nil;
	NSDate *now = [NSDate date];

	NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
	NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *agentsFolder = [[searchPaths objectAtIndex:0] stringByAppendingPathComponent:@"LaunchAgents"];
	NSString *plistPath = [[agentsFolder stringByAppendingPathComponent:bundleIdentifier] stringByAppendingPathExtension:@"plist"];
	if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
		NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:plistPath];
		NSDictionary *intervalDict = [plist objectForKey:@"StartCalendarInterval"];
		NSUInteger weekday = [[intervalDict objectForKey:@"Weekday"] unsignedIntegerValue];
		NSUInteger day = [[intervalDict objectForKey:@"Day"] unsignedIntegerValue];

		NSDateComponents *nowComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit | NSDayCalendarUnit fromDate:now];
		[nowComponents setHour:[[intervalDict objectForKey:@"Hour"] unsignedIntegerValue]];
		[nowComponents setMinute:[[intervalDict objectForKey:@"Minute"] unsignedIntegerValue]];

		if (weekday > 0)
			lastScheduledRunDate = [[[NSCalendar currentCalendar] dateFromComponents:nowComponents] dateByAddingTimeInterval:(8 - [nowComponents weekday]) * -86400.0];
		else if (day > 0) {
			[nowComponents setDay:day];
			if (day < [nowComponents day]) {
				NSUInteger month = [nowComponents month] - 1;
				if (month < 1) {
					month = 12;
					[nowComponents setYear:[nowComponents year] - 1];
				}
				[nowComponents setMonth:month];
			}
			lastScheduledRunDate = [[NSCalendar currentCalendar] dateFromComponents:nowComponents];
		}
	}

	if ([lastRunDate compare:lastScheduledRunDate] == NSOrderedDescending) {
		NSLog(@"Terminating before checking for updates");
		[NSApp terminate:nil];
	}

	[[NSUserDefaults standardUserDefaults] setObject:now forKey:@"LastRunDate"];
	NSLog(@"Checking for updates...");
	FindSparkleBundlesOperation *op = [FindSparkleBundlesOperation new];
	[self.operationQueue addOperation:op];
}

- (void) checkAppUpdateForBundleURL:(NSURL *)url {
	[self.operationQueue addOperation:[[CheckAppUpdateOperation alloc] initWithBundleURL:url]];
}

- (void) addSparkleBundleWithUserInfo:(NSDictionary *)userInfo {
	[self.operationQueue cancelAllOperations];
	if (![self coruscationAlreadyRunning]) {
		NSLog(@"Launching Coruscation...");
		[[NSWorkspace sharedWorkspace] launchApplication:@"Coruscation"];
	}
	[NSApp terminate:nil];
}

@synthesize operationQueue = i_operationQueue;

@end
