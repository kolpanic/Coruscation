#import <Cocoa/Cocoa.h>

@interface CoruscationAgentAppDelegate : NSObject <NSApplicationDelegate> {
@private
	NSOperationQueue *_operationQueue;
}

@property (retain) NSOperationQueue *operationQueue;

@end
