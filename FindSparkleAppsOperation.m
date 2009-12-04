#import "FindSparkleAppsOperation.h"

// this is a private LaunchServices function
extern void _LSCopyAllApplicationURLs(NSArray**);

@implementation FindSparkleAppsOperation

- (void) main {
	NSArray *bundleURLs;
	_LSCopyAllApplicationURLs(&bundleURLs);
	if ([bundleURLs count] > 0) {
		for (NSURL *bundleURL in bundleURLs) {
			NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
			NSString *suFeedURL = [[bundle infoDictionary] objectForKey:@"SUFeedURL"];
			if (suFeedURL && [[NSApp delegate] respondsToSelector:@selector(checkAppUpdateForBundleURL:)]) {
				[[NSApp delegate] performSelectorOnMainThread:@selector(checkAppUpdateForBundleURL:)
												   withObject:bundleURL
												waitUntilDone:NO];
			}
		}
	}
}

@end