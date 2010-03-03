#import "CheckAppUpdateOperation.h"
#import "SparkleBundle.h"

@implementation CheckAppUpdateOperation

#pragma mark -
#pragma mark Setup

- (id) initWithBundleURL:(NSURL *)url {
	if ([super init]) {
		i_url = [url copy];
		i_isExecuting = NO;
		i_isFinished = NO;
	}
	return self;
}

- (BOOL) isConcurrent {
	return YES;
}

- (void) start {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(start)withObject:nil waitUntilDone:NO];
		return;
	}
	if ([[ NSFileManager defaultManager] fileExistsAtPath:[self.url path]]) {
		NSBundle *bundle = [NSBundle bundleWithURL:self.url];
		self.updater = [SUUpdater updaterForBundle:bundle];
		if (self.updater) {
			[self willChangeValueForKey:@"isExecuting"];
			[self willChangeValueForKey:@"isFinished"];
			i_isExecuting = YES;
			i_isFinished = NO;
			[self didChangeValueForKey:@"isExecuting"];
			[self didChangeValueForKey:@"isFinished"];

			[self.updater setDelegate:self];
			[self.updater setAutomaticallyChecksForUpdates:NO];
			[self.updater setAutomaticallyDownloadsUpdates:NO];

			// some appcasts (e.g. Coda) require this to return data, but I know of no better way to enable it
			NSString *ext = [[self.updater feedURL] pathExtension];
			if ([ext isEqualToString:@"php"])
				[self.updater setSendsSystemProfile:YES];

			[self.updater checkForUpdateInformation];

			self.timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:[[NSUserDefaults standardUserDefaults] doubleForKey:@"UpdateCheckTimeOutInterval"]
																 target:self selector:@selector(timedOut:)
															   userInfo:nil
																repeats:NO];
		}
	}
	if (!i_isExecuting)
		[self finish];

}

- (void) finish {
	[self.timeOutTimer invalidate];

	[self willChangeValueForKey:@"isExecuting"];
	[self willChangeValueForKey:@"isFinished"];
	i_isExecuting = NO;
	i_isFinished = YES;
	[self didChangeValueForKey:@"isExecuting"];
	[self didChangeValueForKey:@"isFinished"];
}

- (void) timedOut:(NSTimer *)t {
	NSLog(@"%@ - timed out", self);
	[self finish];
}

- (NSString *) description {
	return [NSString stringWithFormat:@"%@ for %@ SUFeedURL: %@", [self className], [self.url path], [self.updater feedURL]];
}

#pragma mark -
#pragma mark Sparkle Delegate

- (void) updater:(SUUpdater *)updater didFindValidUpdate:(SUAppcastItem *)updateItem {
	if ([[NSApp delegate] respondsToSelector:@selector(addSparkleBundleWithUserInfo:)])
		[[NSApp delegate] performSelectorOnMainThread:@selector(addSparkleBundleWithUserInfo:)
										   withObject:[NSDictionary dictionaryWithObjectsAndKeys:self.url, @"url",
													   [updateItem displayVersionString], @"availableUpdateVersion",
													   [updateItem releaseNotesURL], @"releaseNotesURL",
													   nil]
										waitUntilDone:NO];
	[self finish];
}

- (void) updaterDidNotFindUpdate:(SUUpdater *)update {
	[self finish];
}

- (BOOL) updaterShouldPromptForPermissionToCheckForUpdates:(SUUpdater *)bundle {
	return NO;
}

@synthesize url = i_url, isExecuting = i_isExecuting, isFinished = i_isFinished, updater = i_updater, timeOutTimer = i_timeOut;

@end
