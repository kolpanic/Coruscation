#import <CoreData/CoreData.h>

@interface SparkleBundle :  NSManagedObject {
@private
	NSBundle *_bundle;
	NSImage *_icon;
}

@property (retain, readonly) NSBundle *bundle;
@property (retain, readonly) NSImage *icon;
@property (nonatomic, retain) NSString *bundlePath;
@property (nonatomic, retain) NSString * availableUpdateVersion;

@end