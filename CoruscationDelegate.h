#import <Cocoa/Cocoa.h>

@interface CoruscationDelegate : NSWindowController {
@private
	NSPersistentStoreCoordinator *_persistentStoreCoordinator;
	NSManagedObjectModel *_managedObjectModel;
	NSManagedObjectContext *_managedObjectContext;
	NSArrayController *_updateItems;
	NSOperationQueue *_operationQueue;
	NSArray *_sorter;
}

- (IBAction) log:(id) sender;
- (IBAction) reload:(id) sender;
- (IBAction) openSelected:(id) sender;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (retain) IBOutlet NSArrayController *updateItems;
@property (retain) NSOperationQueue *operationQueue;
@property (retain) NSArray *sorter;

@end