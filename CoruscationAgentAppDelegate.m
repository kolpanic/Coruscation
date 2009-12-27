#import "CoruscationAgentAppDelegate.h"
#import "Sparkle/SUUpdater.h"
#import "FindSparkleAppsOperation.h"
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
		_operationQueue = [NSOperationQueue new];
		[_operationQueue addObserver:self forKeyPath:@"operations" options:NSKeyValueObservingOptionNew context:nil];
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
	[_operationQueue removeObserver:self forKeyPath:@"operations"];
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
	NSLog(@"Checking for updates...");
	FindSparkleAppsOperation *op = [FindSparkleAppsOperation new];
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

@synthesize operationQueue = _operationQueue;

@end
