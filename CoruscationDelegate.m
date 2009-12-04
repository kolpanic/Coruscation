#import "CoruscationDelegate.h"
#import "SparkleBundle.h"
#import "Sparkle/SUUpdater.h"
#import "FindSparkleAppsOperation.h"
#import "CheckAppUpdateOperation.h"
#import "UpdateCountTransformer.h"

@implementation CoruscationDelegate

#pragma mark -
#pragma mark Setup

- (id) init {
	if (self = [super init])
		_operationQueue = [NSOperationQueue new];
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
	if (!_managedObjectModel)
		_managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
	return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
	if (!_persistentStoreCoordinator) {
		NSManagedObjectModel *mom = self.managedObjectModel;
		if (!mom) {
			NSAssert(NO, @"Managed object model is nil");
			NSLog(@"%@:%s No model to generate a store from", [self class], _cmd);
			return nil;
		}
		NSError *error;
		_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
		if (![_persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
													   configuration:nil
																 URL:nil
															 options:nil
															   error:&error]) {
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
			NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
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
	NSURL *url = [userInfo objectForKey:@"url"];
	NSManagedObjectContext *moc = [self managedObjectContext];
	SparkleBundle *sparkleBundle = [NSEntityDescription insertNewObjectForEntityForName:@"SparkleBundle" inManagedObjectContext:moc];
	sparkleBundle.bundlePath = [url path];
	sparkleBundle.availableUpdateVersion = [userInfo objectForKey:@"availableUpdateVersion"];
	[moc save:nil];
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
				[self refresh:sender];
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
	FindSparkleAppsOperation *op = [FindSparkleAppsOperation new];
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

@dynamic persistentStoreCoordinator, managedObjectModel, managedObjectContext;
@synthesize collectionView = _collectionView, updateItems = _updateItems, operationQueue = _operationQueue, sorter = _sorter;

@end
