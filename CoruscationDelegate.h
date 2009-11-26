#import <Cocoa/Cocoa.h>

@interface CoruscationDelegate : NSWindowController {
@private
	NSCollectionView *_collectionView;
	NSPersistentStoreCoordinator *_persistentStoreCoordinator;
	NSManagedObjectModel *_managedObjectModel;
	NSManagedObjectContext *_managedObjectContext;
	NSArrayController *_updateItems;
	NSOperationQueue *_operationQueue;
	NSArray *_sorter;
}

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

@end
