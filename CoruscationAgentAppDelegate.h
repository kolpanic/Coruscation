#import <Cocoa/Cocoa.h>

@interface CoruscationAgentAppDelegate : NSObject <NSApplicationDelegate> {
@private
	NSOperationQueue *i_operationQueue;
}

@property (retain) NSOperationQueue *operationQueue;

@end
