#import "SparkleBundle.h"
#import <Sparkle/Sparkle.h>

@implementation SparkleBundle

#pragma mark -
#pragma mark Convenience

- (NSString *) displayName {
	return [[NSFileManager defaultManager] displayNameAtPath:self.bundlePath];
}

- (NSString *) displayVersion {
	NSString *displayVersion;
	NSString *shortVersionString = [self.bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	NSString *bundleVersion = [self.bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
	if (shortVersionString && ![shortVersionString isEqualToString:bundleVersion])
		displayVersion = [NSString stringWithFormat:@"%@ (%@)", shortVersionString, bundleVersion];
	else
		displayVersion = [NSString stringWithFormat:@"%@", bundleVersion];
	return displayVersion;
}

- (NSImage *) icon {
	if (!_icon)
		_icon = [[NSWorkspace sharedWorkspace] iconForFile:self.bundlePath];
	return _icon;
}

- (NSBundle *) bundle {
	if (!_bundle)
		_bundle = [NSBundle bundleWithPath:self.bundlePath];
	return _bundle;
}

@dynamic bundle, icon, bundlePath, availableUpdateVersion;

@end