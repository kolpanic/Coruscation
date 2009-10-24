#import <Cocoa/Cocoa.h>

@interface FindSparkleAppsOperation : NSOperation {
@private
	NSOperationQueue *_operationQueue;
}

@property (retain) NSOperationQueue *operationQueue;

@end