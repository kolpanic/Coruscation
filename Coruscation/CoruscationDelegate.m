//
//  CoruscationDelegate.m
//  Coruscation
//
//  Created by Karl Moskowski on 12/1/2013.
//  Copyright (c) 2013 Karl Moskowski. All rights reserved.
//

#import "CoruscationDelegate.h"
#import "SparkleBundle.h"
#import "FindSparkleBundlesOperation.h"
#import "CheckAppUpdateOperation.h"
#import "UpdateCountTransformer.h"
#import <Sparkle/SUUpdater.h>

@interface CoruscationDelegate ()

@property (nonatomic, weak) IBOutlet NSCollectionView *collectionView;
@property (nonatomic, weak) IBOutlet NSArrayController *updateItems;

@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSArray *sorter;
@property (nonatomic, assign) NSUInteger count;

@end

@implementation CoruscationDelegate

#pragma mark -
#pragma mark Setup

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {
	self.sorter = @[[[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES]];
	[self refresh:nil];
}

- (BOOL) applicationOpenUntitledFile:(NSApplication *)theApplication {
	[self showWindow:nil];
	return YES;
}

- (void) awakeFromNib {
	self.collectionView.maxNumberOfColumns = 1;
	self.collectionView.minItemSize = NSMakeSize(0.0, 68.0);
	self.collectionView.maxItemSize = NSMakeSize(10000.0, 68.0);
}

+ (void) initialize {
	if (self == [CoruscationDelegate class]) {
		NSDictionary *defaults = @{@"UpdateCheckTimeOutInterval": @10.0};
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
		[NSValueTransformer setValueTransformer:[UpdateCountTransformer new] forName:@"UpdateCountTransformer"];
	}
	[super initialize];
}

#pragma mark -
#pragma mark Core Data

- (NSManagedObjectModel *) managedObjectModel {
	if (!_managedObjectModel) {
		NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Coruscation" withExtension:@"momd"];
		_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	}
	return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
	if (!_persistentStoreCoordinator) {
		NSManagedObjectModel *mom = self.managedObjectModel;
		if (!mom) {
			NSAssert(NO, @"Managed object model is nil");
			NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
			return nil;
		}
		NSError *error;
		_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
		if (![_persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error]) {
			[[NSApplication sharedApplication] presentError:error];
			_persistentStoreCoordinator = nil;
		}
	}
	return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *) managedObjectContext {
	if (!_managedObjectContext) {
		NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
		if (!coordinator) {
			NSMutableDictionary *dict = [NSMutableDictionary dictionary];
			[dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
			[dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
			NSError *error = [NSError errorWithDomain:@"com.voodooergonomics.Coruscation.ErrorDomain" code:9999 userInfo:dict];
			[[NSApplication sharedApplication] presentError:error];
			return nil;
		}
		_managedObjectContext = [[NSManagedObjectContext alloc] init];
		[_managedObjectContext setPersistentStoreCoordinator:coordinator];
	}
	return _managedObjectContext;
}

- (NSUndoManager *) windowWillReturnUndoManager:(NSWindow *)window {
	return [self.managedObjectContext undoManager];
}

#pragma mark -
#pragma mark Convenience

- (void) checkAppUpdateForBundleURL:(NSURL *)url {
	[self.operationQueue addOperation:[[CheckAppUpdateOperation alloc] initWithBundleURL:url]];
}

- (void) addSparkleBundleWithUserInfo:(NSDictionary *)userInfo {
	NSURL *url = userInfo[@"url"];
	SparkleBundle *sparkleBundle = [SparkleBundle insertInManagedObjectContext:[self managedObjectContext]];
	sparkleBundle.bundlePath = [url path];
	sparkleBundle.availableUpdateVersion = userInfo[@"availableUpdateVersion"];
	sparkleBundle.releaseNotesURL = [userInfo[@"releaseNotesURL"] absoluteString];
	sparkleBundle.fileURL = [userInfo[@"fileURL"] absoluteString];
	sparkleBundle.itemDescription = userInfo[@"itemDescription"];
	if ([[self managedObjectContext] save:nil]) {
		[[NSApplication sharedApplication] dockTile].badgeLabel = [NSString stringWithFormat:@"%ld", ++self.count];
	}
}

#pragma mark -
#pragma mark IB Actions

- (IBAction) rebuildLSDB:(id)sender {
	static NSString* const key = @"SuppressRebuildAlert";
	if (![[NSUserDefaults standardUserDefaults] boolForKey:key]) {
		NSAlert *alert = [NSAlert new]; {
			alert.messageText = NSLocalizedString(@"Rebuild Launch Services Database", @"message text");
			alert.informativeText = NSLocalizedString(@"If you've installed and removed many applications recently, Coruscation may show applications repeatedly. Rebuilding your Launch Services database should remedy this. Do you wish to do so?", @"message text");
			[[alert addButtonWithTitle:NSLocalizedString(@"Yes", @"button text")] setKeyEquivalent:@"\r"];
			[[alert addButtonWithTitle:NSLocalizedString(@"No", @"button text")] setKeyEquivalent:@"\E"];
			[alert setShowsSuppressionButton:YES];
		}
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            [[NSUserDefaults standardUserDefaults] setBool:(NSOnState == [[alert suppressionButton] state]) forKey:key];
            if (NSOKButton == returnCode) {
                [self doRebuildLSDB];
            }
        }];
	} else {
        [self doRebuildLSDB];
    }
}
- (void) doRebuildLSDB {
    [NSTask launchedTaskWithLaunchPath:@"/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister" arguments:@[@"-kill", @"-seed", @"-r"]];
}

- (IBAction) refresh:(id)sender {
	if ([self.operationQueue operationCount] > 0) {
		return;
	}
	[self.managedObjectContext reset];
	self.count = 0;
	[[NSApplication sharedApplication] dockTile].badgeLabel = nil;
    
	FindSparkleBundlesOperation *op = [FindSparkleBundlesOperation new];
	[self.operationQueue addOperation:op];
}

- (IBAction) openSelected:(id)sender {
	NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
	for (SparkleBundle *sparkleBundle in [self.updateItems selectedObjects]) {
		NSURL *updateURL = [sparkleBundle.bundle bundleURL];
		if ([updateURL isEqual:bundleURL]) {
			[[SUUpdater sharedUpdater] checkForUpdates:nil];
		} else {
			[[NSWorkspace sharedWorkspace] launchApplicationAtURL:updateURL options:NSWorkspaceLaunchWithoutActivation configuration:nil error:nil];
		}
	}
}

- (IBAction) revealSelected:(id)sender {
	for (SparkleBundle *sparkleBundle in [self.updateItems selectedObjects]) {
		[self reveal:sparkleBundle];
	}
}

- (IBAction) releaseNotesForSelected:(id)sender {
	for (SparkleBundle *sparkleBundle in [self.updateItems selectedObjects]) {
		[self releaseNotes:sparkleBundle];
	}
}

- (IBAction) downloadUpdateForSelected:(id)sender {
	for (SparkleBundle *sparkleBundle in [self.updateItems selectedObjects]) {
		[self downloadUpdate:sparkleBundle];
	}
}

- (void) reveal:(id)item {
	if ([item isKindOfClass:[SparkleBundle class]]) {
		SparkleBundle *sparkleBundle = (SparkleBundle *)item;
		NSString *path = [[sparkleBundle.bundle bundleURL] path];
		[[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:@""];
	}
}

- (void) releaseNotes:(id)item {
	if ([item isKindOfClass:[SparkleBundle class]]) {
		SparkleBundle *sparkleBundle = (SparkleBundle *)item;
		if (sparkleBundle.releaseNotesURL) {
			NSURL *url = [NSURL URLWithString:sparkleBundle.releaseNotesURL];
			[[NSWorkspace sharedWorkspace] openURL:url];
		} else {
			NSString *relnotesPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[sparkleBundle.bundle bundleIdentifier] stringByAppendingPathExtension:@"html"]];
			[sparkleBundle.itemDescription writeToFile:relnotesPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
			[[NSWorkspace sharedWorkspace] openFile:relnotesPath];
		}
	}
}

- (void) downloadUpdate:(id)item {
	if ([item isKindOfClass:[SparkleBundle class]]) {
		SparkleBundle *sparkleBundle = (SparkleBundle *)item;
		if (sparkleBundle.fileURL) {
			NSURL *url = [NSURL URLWithString:sparkleBundle.fileURL];
			[[NSWorkspace sharedWorkspace] openURL:url];
		}
	}
}

- (NSOperationQueue *) operationQueue {
	return _operationQueue ? : (_operationQueue = [NSOperationQueue new]);
}

@end
