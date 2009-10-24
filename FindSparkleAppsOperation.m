#import "FindSparkleAppsOperation.h"
#import "CheckAppUpdateOperation.h"

extern void _LSCopyAllApplicationURLs(NSArray**); // private API

@implementation FindSparkleAppsOperation

- (void) main {
	NSArray *bundleURLs;
	_LSCopyAllApplicationURLs(&bundleURLs);
	if ([bundleURLs count] > 0) {
		for (NSURL *bundleURL in bundleURLs) {
			NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
			NSString *suFeedURL = [[bundle infoDictionary] objectForKey:@"SUFeedURL"];
			if (suFeedURL) {
				[self.operationQueue performSelectorOnMainThread:@selector(addOperation:)
													  withObject:[[CheckAppUpdateOperation alloc] initWithBundleURL:bundleURL]
												   waitUntilDone:NO];
			}
		}
	}
}

@synthesize operationQueue = _operationQueue;

@end