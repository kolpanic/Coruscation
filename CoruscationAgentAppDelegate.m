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
	NSDate *lastRunDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastRunDate"];
	NSTimeInterval intervalSinceLastRun = [[NSDate date] timeIntervalSinceDate:lastRunDate];
	NSTimeInterval minInterval = 604800;
	NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
	NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *agentsFolder = [[searchPaths objectAtIndex:0] stringByAppendingPathComponent:@"LaunchAgents"];
	NSString *plistPath = [[agentsFolder stringByAppendingPathComponent:bundleIdentifier] stringByAppendingPathExtension:@"plist"];
	if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
		NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:plistPath];
		minInterval = [[plist objectForKey:@"StartInterval"] integerValue];
	}
	if (intervalSinceLastRun < minInterval) {
		NSLog(@"Terminating before checking for updates - run before scheduled (e.g. at login)");
		[NSApp terminate:nil];
	}

	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LastRunDate"];
	if ([self coruscationAlreadyRunning])
		[NSApp terminate:nil];
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
