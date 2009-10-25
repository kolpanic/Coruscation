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
	if ([[ NSFileManager defaultManager] fileExistsAtPath:[self.url path]]) {
		NSBundle *bundle = [NSBundle bundleWithURL:self.url];
		self.updater = [SUUpdater updaterForBundle:bundle];
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
		}
	} 
	if (!_isExecuting){
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
	NSLog(@"%@ - timed out", self);
	[self finish];
}

- (NSString *) description {
	return [NSString stringWithFormat:@"%@ for %@ SUFeedURL: %@", [self className], [self.url path], [self.updater feedURL]];
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