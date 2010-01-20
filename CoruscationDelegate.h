#import <Cocoa/Cocoa.h>

@interface CoruscationDelegate : NSWindowController {
@private
	NSCollectionView *i_collectionView;
	NSPersistentStoreCoordinator *i_persistentStoreCoordinator;
	NSManagedObjectModel *i_managedObjectModel;
	NSManagedObjectContext *i_managedObjectContext;
	NSArrayController *i_updateItems;
	NSOperationQueue *i_operationQueue;
	NSArray *i_sorter;
	NSUInteger i_count;
}

- (IBAction) go:(id)sender;
- (IBAction) refresh:(id)sender;
- (IBAction) openSelected:(id)sender;
- (IBAction) revealSelected:(id)sender;

@property (retain) IBOutlet NSCollectionView *collectionView;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (retain) IBOutlet NSArrayController *updateItems;
@property (retain) NSOperationQueue *operationQueue;
@property (retain) NSArray *sorter;
@property (assign) NSUInteger count;

@end
