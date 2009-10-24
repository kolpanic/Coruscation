#import "CheckAppUpdateOperation.h"
#import "SparkleBundle.h"

@implementation CheckAppUpdateOperation

#pragma mark -
#pragma mark Setup

- (id) initWithBundleURL:(NSURL *) url {
	if ([super init]) {
		_url = [url copy];
		_isExecuting = NO;
		_isFinished = NO;
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
	self.updater = [SUUpdater updaterForBundle:[NSBundle bundleWithURL:self.url]];
	if (self.updater) {
		[self willChangeValueForKey:@"isExecuting"];
		[self willChangeValueForKey:@"isFinished"];
		_isExecuting = YES;
		_isFinished = NO;
		[self didChangeValueForKey:@"isExecuting"];
		[self didChangeValueForKey:@"isFinished"];
		
		[self.updater setDelegate:self];
		[self.updater setAutomaticallyChecksForUpdates:NO];
		[self.updater setAutomaticallyDownloadsUpdates:NO];
		[self.updater checkForUpdateInformation];
		
		self.timeOut = [NSTimer scheduledTimerWithTimeInterval:[[NSUserDefaults standardUserDefaults] doubleForKey:@"UpdateCheckTimeOutInterval"]
														target:self selector:@selector(timeOut:) userInfo:nil repeats:NO];
	} else {
		[self finish];
	}
}

- (void) finish {
	[self.timeOut invalidate];
	[self willChangeValueForKey:@"isExecuting"];
	[self willChangeValueForKey:@"isFinished"];
	_isExecuting = NO;
	_isFinished = YES;
	[self didChangeValueForKey:@"isExecuting"];
	[self didChangeValueForKey:@"isFinished"];
}

- (void)timeOut:(NSTimer*)t {
	NSLog(@"Timed out: %@", self);
	[self finish];
}

- (NSString *) description {
	return [NSString stringWithFormat:@"CheckAppUpdateOperation for %@ - %@",
			[[NSFileManager defaultManager] displayNameAtPath:[self.url path]], [self.updater feedURL]];
}

#pragma mark -
#pragma mark Sparkle Delegate

- (void) updater:(SUUpdater *) updater didFindValidUpdate:(SUAppcastItem *) updateItem {
	[[NSApp delegate] performSelectorOnMainThread:@selector(addSparkleBundleWithUserInfo:)
									   withObject:[NSDictionary dictionaryWithObjectsAndKeys:self.url, @"url",
												   [updateItem displayVersionString], @"availableUpdateVersion",
												   nil]
									waitUntilDone:NO];
	[self finish];
}

- (void) updaterDidNotFindUpdate:(SUUpdater *) update {
	[self finish];
}

- (BOOL) updaterShouldPromptForPermissionToCheckForUpdates:(SUUpdater *) bundle {
	return NO;
}

@synthesize url = _url, isExecuting = _isExecuting, isFinished = _isFinished, updater = _updater, timeOut = _timeOut;

@end