#import "SparkleBundle.h"

@implementation SparkleBundle

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
	if (!i_icon)
		i_icon = [[NSWorkspace sharedWorkspace] iconForFile:self.bundlePath];
	return i_icon;
}

- (NSBundle *) bundle {
	if (!i_bundle)
		i_bundle = [NSBundle bundleWithPath:self.bundlePath];
	return i_bundle;
}

@end
