//
//  FindSparkleBundlesOperation.m
//  Coruscation
//
//  Created by Karl Moskowski on 12/1/2013.
//  Copyright (c) 2013 Karl Moskowski. All rights reserved.
//

#import "FindSparkleBundlesOperation.h"
#import "NSFileManager+CoruscationAdditions.h"

// private LaunchServices function
extern void _LSCopyAllApplicationURLs(NSArray **);

@implementation FindSparkleBundlesOperation

- (void) main {
	NSFileManager *fm = [NSFileManager new];
    
	// assemble a list of typical bundle locations
	NSMutableArray *otherBundleDirs = [NSMutableArray array];
	NSString *dir = nil;
	NSArray *libraryDirs = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask | NSLocalDomainMask, YES);
	for (NSString *libraryDir in libraryDirs) {
		dir = [libraryDir stringByAppendingPathComponent:@"Internet Plug-Ins"];
		if ([fm fileExistsAtPath:dir]) {
			[otherBundleDirs addObject:dir];
		}
		dir = [libraryDir stringByAppendingPathComponent:@"PreferencePanes"];
		if ([fm fileExistsAtPath:dir]) {
			[otherBundleDirs addObject:dir];
		}
	}
    
	// find all the applications on the system
	NSMutableArray *bundleURLs;
	_LSCopyAllApplicationURLs(&bundleURLs);
    
	// find all bundles in the bundle locations
	for (dir in otherBundleDirs) {
		NSArray *dirContents = [fm contentsOfDirectoryAtPath:dir error:nil];
		for (NSString *subpath in dirContents) {
			NSString *path = [dir stringByAppendingPathComponent:subpath];
			if ([fm isFilePackageAtPath:path]) {
				[bundleURLs addObject:[NSURL fileURLWithPath:path]];
			}
		}
	}
    
	// check all the found bundles & apps to see if they're Sparkle-enabled, ignoring Mac App Store purchases (in case the developer didn't clean up Info.plist)
	if ([bundleURLs count] > 0) {
		for (NSURL *bundleURL in bundleURLs) {
			NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
			NSString *masReceiptPath = [[[bundleURL path] stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:@"_MASReceipt"];
			if (![fm fileExistsAtPath:masReceiptPath]) {
				NSString *suFeedURL = [bundle infoDictionary][@"SUFeedURL"];
				if (suFeedURL && [[NSApp delegate] respondsToSelector:@selector(checkAppUpdateForBundleURL:)]) {
					[[NSApp delegate] performSelectorOnMainThread:@selector(checkAppUpdateForBundleURL:)
													   withObject:bundleURL
													waitUntilDone:NO];
				}
			}
		}
	}
}

@end
