#import "CoruscationDelegate.h"
#import "SparkleBundle.h"
#import "Sparkle/SUUpdater.h"
#import "FindSparkleBundlesOperation.h"
#import "CheckAppUpdateOperation.h"
#import "UpdateCountTransformer.h"

@implementation CoruscationDelegate

#pragma mark -
#pragma mark Setup

- (id) init {
	if (self = [super init])
		i_operationQueue = [NSOperationQueue new];
	return self;
}

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {
	self.sorter = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES]];
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
		NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
		                          [NSNumber numberWithDouble:10.0], @"UpdateCheckTimeOutInterval",
		                          nil];
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
		[NSValueTransformer setValueTransformer:[UpdateCountTransformer new] forName:@"UpdateCountTransformer"];
	}
	[super initialize];
}
#pragma mark -
#pragma mark Core Data

- (NSManagedObjectModel *) managedObjectModel {
	if (!i_managedObjectModel)
		i_managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
	return i_managedObjectModel;
}

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
	if (!i_persistentStoreCoordinator) {
		NSManagedObjectModel *mom = self.managedObjectModel;
		if (!mom) {
			NSAssert(NO, @"Managed object model is nil");
			NSLog(@"%@:%s No model to generate a store from", [self class], _cmd);
			return nil;
		}
		NSError *error;
		i_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
		if (![i_persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
														configuration:nil
																  URL:nil
															  options:nil
																error:&error]) {
			[[NSApplication sharedApplication] presentError:error];
			i_persistentStoreCoordinator = nil;
		}
	}
	return i_persistentStoreCoordinator;
}

- (NSManagedObjectContext *) managedObjectContext {
	if (!i_managedObjectContext) {
		NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
		if (!coordinator) {
			NSMutableDictionary *dict = [NSMutableDictionary dictionary];
			[dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
			[dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
			NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
			[[NSApplication sharedApplication] presentError:error];
			return nil;
		}
		i_managedObjectContext = [[NSManagedObjectContext alloc] init];
		[i_managedObjectContext setPersistentStoreCoordinator:coordinator];
	}
	return i_managedObjectContext;
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
	NSURL *url = [userInfo objectForKey:@"url"];
	NSManagedObjectContext *moc = [self managedObjectContext];
	SparkleBundle *sparkleBundle = [SparkleBundle insertInManagedObjectContext:moc];
	sparkleBundle.bundlePath = [url path];
	sparkleBundle.availableUpdateVersion = [userInfo objectForKey:@"availableUpdateVersion"];
	sparkleBundle.releaseNotesURL = [[userInfo objectForKey:@"releaseNotesURL"] absoluteString];
	sparkleBundle.itemDescription = [userInfo objectForKey:@"itemDescription"];
	if ([moc save:nil])
		[[NSApplication sharedApplication] dockTile].badgeLabel = [NSString stringWithFormat:@"%u", ++self.count];
}

#pragma mark -
#pragma mark IB Actions

- (IBAction) go:(id)sender {
	if ([[sender className] isEqualToString:@"NSSegmentedControl"]) {
		NSSegmentedControl *control = sender;
		switch ([control selectedSegment]) {
			case 0:
				[self openSelected:sender];
				break;
			case 1:
				[self revealSelected:sender];
				break;
			case 2:
				[self releaseNotesForSelected:sender];
				break;
			default:
				break;
		}
	}
}

- (IBAction) refresh:(id)sender {
	if ([self.operationQueue operationCount] > 0)
		return;
	[self.managedObjectContext reset];
	FindSparkleBundlesOperation *op = [FindSparkleBundlesOperation new];
	[self.operationQueue addOperation:op];
}

- (IBAction) openSelected:(id)sender {
	NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
	for (SparkleBundle *sparkleBundle in [self.updateItems selectedObjects]) {
		NSURL *updateURL = [sparkleBundle.bundle bundleURL];
		if ([updateURL isEqual:bundleURL])
			[[SUUpdater sharedUpdater] checkForUpdates:nil];
		else
			[[NSWorkspace sharedWorkspace] launchApplicationAtURL:updateURL
														  options:NSWorkspaceLaunchWithoutActivation
													configuration:nil
															error:nil];
	}
}

- (IBAction) revealSelected:(id)sender {
	for (SparkleBundle *sparkleBundle in [self.updateItems selectedObjects]) {
		NSString *path = [[sparkleBundle.bundle bundleURL] path];
		[[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:@""];
	}
}

- (IBAction) releaseNotesForSelected:(id)sender {
	for (SparkleBundle *sparkleBundle in [self.updateItems selectedObjects]) {
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

@dynamic persistentStoreCoordinator, managedObjectModel, managedObjectContext;
@synthesize collectionView = i_collectionView, updateItems = i_updateItems, operationQueue = i_operationQueue, sorter = i_sorter, count = i_count;

@end
