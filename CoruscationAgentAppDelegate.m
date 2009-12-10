#import "CoruscationAgentAppDelegate.h"
#import "Sparkle/SUUpdater.h"
#import "FindSparkleAppsOperation.h"
#import "CheckAppUpdateOperation.h"

// TODO: use this agent...
// - add prefs UI in the main app to control scheduled update checks - never, weekly or monthly
// - install & load plist in ~/Library/LaunchAgents/ based on user prefs

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
	if ([keyPath isEqualToString:@"operations"]) {
		if ([self.operationQueue operationCount] < 1) {
			[NSApp terminate:nil];
			NSLog(@"Terminating - all operations finished with no updates found");
		}
	}
}

- (void) finalize {
	[_operationQueue removeObserver:self forKeyPath:@"operations"];
	[super finalize];
}

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {
	FindSparkleAppsOperation *op = [FindSparkleAppsOperation new];
	[self.operationQueue setMaxConcurrentOperationCount:1];
	[self.operationQueue addOperation:op];
}

- (void) checkAppUpdateForBundleURL:(NSURL *)url {
	[self.operationQueue addOperation:[[CheckAppUpdateOperation alloc] initWithBundleURL:url]];
}

- (void) addSparkleBundleWithUserInfo:(NSDictionary *)userInfo {
	[[NSWorkspace sharedWorkspace] launchApplication:@"Coruscation"];
	[NSApp terminate:nil];
}

@synthesize operationQueue = _operationQueue;

@end
