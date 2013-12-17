//
//  SparkleBundle.m
//  Coruscation
//
//  Created by Karl Moskowski on 12/1/2013.
//  Copyright (c) 2013 Karl Moskowski. All rights reserved.
//

#import "SparkleBundle.h"

@implementation SparkleBundle

- (NSString *) displayName {
	return [NSString stringWithFormat:@"%@ %@",
			[[NSFileManager defaultManager] displayNameAtPath:self.bundlePath],
			[self displayVersion]];
}

- (NSString *) displayVersion {
	NSString *displayVersion;
	NSString *shortVersionString = [self.bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	NSString *bundleVersion = [self.bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
	if (shortVersionString && ![shortVersionString isEqualToString:bundleVersion]) {
		displayVersion = [NSString stringWithFormat:@"%@ (%@)", shortVersionString, bundleVersion];
	} else {
		displayVersion = [NSString stringWithFormat:@"%@", bundleVersion];
	}
	return displayVersion;
}

- (NSImage *) icon {
	return [[NSWorkspace sharedWorkspace] iconForFile:self.bundlePath];
}

- (NSBundle *) bundle {
	return [NSBundle bundleWithPath:self.bundlePath];
}

@end
