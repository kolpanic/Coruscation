// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SparkleBundle.h instead.

#import <CoreData/CoreData.h>



@interface SparkleBundleID : NSManagedObjectID {}
@end

@interface _SparkleBundle : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SparkleBundleID*)objectID;



@property (nonatomic, retain) NSString *fileURL;

//- (BOOL)validateFileURL:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *availableUpdateVersion;

//- (BOOL)validateAvailableUpdateVersion:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *itemDescription;

//- (BOOL)validateItemDescription:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *releaseNotesURL;

//- (BOOL)validateReleaseNotesURL:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *bundlePath;

//- (BOOL)validateBundlePath:(id*)value_ error:(NSError**)error_;




@end

@interface _SparkleBundle (CoreDataGeneratedAccessors)

@end
