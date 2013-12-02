//
//  CheckAppUpdateOperation.m
//  Coruscation
//
//  Created by Karl Moskowski on 12/1/2013.
//  Copyright (c) 2013 Karl Moskowski. All rights reserved.
//

#import "CheckAppUpdateOperation.h"
#import "SparkleBundle.h"

@interface CheckAppUpdateOperation ()

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) SUUpdater *updater;
@property (nonatomic, strong) NSTimer *timeOutTimer;
@property (assign) BOOL isExecuting;
@property (assign) BOOL isFinished;

@end

@implementation CheckAppUpdateOperation

#pragma mark -
#pragma mark Setup

- (id) initWithBundleURL:(NSURL *)url {
	if ([super init]) {
		self.url = [url copy];
		self.isExecuting = NO;
		self.isFinished = NO;
	}
	return self;
}

- (BOOL) isConcurrent {
	return YES;
}

- (void) start {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
		return;
	}
	if ([[ NSFileManager defaultManager] fileExistsAtPath:[self.url path]]) {
		NSBundle *bundle = [NSBundle bundleWithURL:self.url];
		self.updater = [SUUpdater updaterForBundle:bundle];
		if (self.updater) {
			[self willChangeValueForKey:@"isExecuting"];
			[self willChangeValueForKey:@"isFinished"];
			self.isExecuting = YES;
			self.isFinished = NO;
			[self didChangeValueForKey:@"isExecuting"];
			[self didChangeValueForKey:@"isFinished"];
            
			[self.updater setDelegate:self];
			[self.updater setAutomaticallyChecksForUpdates:NO];
			[self.updater setAutomaticallyDownloadsUpdates:NO];
            
			// some appcasts (e.g. Coda) require this to return data, but I know of no better way to enable it
			NSString *ext = [[self.updater feedURL] pathExtension];
			if ([ext isEqualToString:@"php"]) {
				[self.updater setSendsSystemProfile:YES];
			}
            
			[self.updater checkForUpdateInformation];
            
			self.timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:[[NSUserDefaults standardUserDefaults] doubleForKey:@"UpdateCheckTimeOutInterval"]
																 target:self selector:@selector(timedOut:)
															   userInfo:nil
																repeats:NO];
		}
	}
	if (!self.isExecuting) {
		[self finish];
	}
    
}

- (void) finish {
	[self.timeOutTimer invalidate];
    
	[self willChangeValueForKey:@"isExecuting"];
	[self willChangeValueForKey:@"isFinished"];
	self.isExecuting = NO;
	self.isFinished = YES;
	[self didChangeValueForKey:@"isExecuting"];
	[self didChangeValueForKey:@"isFinished"];
}

- (void) timedOut:(NSTimer *)t {
	NSLog(@"%@ - timed out", self);
	[self finish];
}

- (NSString *) description {
	return [NSString stringWithFormat:@"%@ for %@ SUFeedURL: %@", [self className], [self.url path], [self.updater feedURL]];
}

#pragma mark -
#pragma mark Sparkle Delegate

- (void) updater:(SUUpdater *)updater didFindValidUpdate:(SUAppcastItem *)updateItem {
	if ([[NSApp delegate] respondsToSelector:@selector(addSparkleBundleWithUserInfo:) ]) {
		NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:4];
		userInfo[@"url"] = self.url;
		NSString *displayVersionString = [updateItem displayVersionString];
		if (displayVersionString) {
			userInfo[@"availableUpdateVersion"] = displayVersionString;
		}
		NSURL *releaseNotesURL = [updateItem releaseNotesURL];
		if (releaseNotesURL) {
			userInfo[@"releaseNotesURL"] = releaseNotesURL;
		}
		NSURL *fileURL = [updateItem fileURL];
		if (fileURL) {
			userInfo[@"fileURL"] = fileURL;
		}
		NSString *itemDescription = [updateItem itemDescription];
		if (itemDescription) {
			userInfo[@"itemDescription"] = itemDescription;
		}
		[[NSApp delegate] performSelectorOnMainThread:@selector(addSparkleBundleWithUserInfo:) withObject:userInfo waitUntilDone:NO];
		[self finish];
	}
}

- (void) updaterDidNotFindUpdate:(SUUpdater *)update {
	[self finish];
}

- (BOOL) updaterShouldPromptForPermissionToCheckForUpdates:(SUUpdater *)bundle {
	return NO;
}

@end
