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
	if ([keyPath isEqualToString:@"operations"]) {
		if ([self.operationQueue operationCount] < 1) {
			[NSApp terminate:nil];
		}
	}
}

- (void) finalize {
	[_operationQueue removeObserver:self forKeyPath:@"operations"];
	[super finalize];
}

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {
	FindSparkleAppsOperation *op = [FindSparkleAppsOperation new];
	[self.operationQueue addOperation:op];
}

- (void) checkAppUpdateForBundleURL:(NSURL *)url {
	[self.operationQueue addOperation:[[CheckAppUpdateOperation alloc] initWithBundleURL:url]];
}

- (void) addSparkleBundleWithUserInfo:(NSDictionary *)userInfo {
	[self.operationQueue cancelAllOperations];
	[[NSWorkspace sharedWorkspace] launchApplication:@"Coruscation"];
	[NSApp terminate:nil];
}

@synthesize operationQueue = _operationQueue;

@end