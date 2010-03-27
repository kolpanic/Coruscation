// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SparkleBundle.m instead.

#import "_SparkleBundle.h"

@implementation SparkleBundleID
@end

@implementation _SparkleBundle

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SparkleBundle" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SparkleBundle";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SparkleBundle" inManagedObjectContext:moc_];
}

- (SparkleBundleID*)objectID {
	return (SparkleBundleID*)[super objectID];
}




@dynamic availableUpdateVersion;






@dynamic itemDescription;






@dynamic releaseNotesURL;






@dynamic bundlePath;








@end
