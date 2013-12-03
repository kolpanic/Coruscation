// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SparkleBundle.h instead.

@import CoreData;


@interface SparkleBundleID : NSManagedObjectID {}
@end

@interface _SparkleBundle : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SparkleBundleID*)objectID;



@property (nonatomic, strong) NSString *fileURL;

//- (BOOL)validateFileURL:(id*)value_ error:(NSError**)error_;



@property (nonatomic, strong) NSString *availableUpdateVersion;

//- (BOOL)validateAvailableUpdateVersion:(id*)value_ error:(NSError**)error_;



@property (nonatomic, strong) NSString *itemDescription;

//- (BOOL)validateItemDescription:(id*)value_ error:(NSError**)error_;



@property (nonatomic, strong) NSString *releaseNotesURL;

//- (BOOL)validateReleaseNotesURL:(id*)value_ error:(NSError**)error_;



@property (nonatomic, strong) NSString *bundlePath;

//- (BOOL)validateBundlePath:(id*)value_ error:(NSError**)error_;


@property (nonatomic, strong) NSNumber *isUpdateAvailable;

//- (BOOL)validateIsUpdateAvailable:(id*)value_ error:(NSError**)error_;



@end

@interface _SparkleBundle (CoreDataGeneratedAccessors)

@end
