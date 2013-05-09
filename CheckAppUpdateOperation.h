#import <Foundation/Foundation.h>
#import "Sparkle/Sparkle.h"

@interface CheckAppUpdateOperation : NSOperation {
@private
	NSURL *i_url;
	BOOL i_isExecuting;
	BOOL i_isFinished;
	SUUpdater *i_updater;
	NSTimer *i_timeOut;
}

- (id) initWithBundleURL:(NSURL *) url;
- (void) finish;

@property (retain) NSURL *url;
@property (assign) BOOL isExecuting;
@property (assign) BOOL isFinished;
@property (retain) SUUpdater *updater;
@property (retain) NSTimer *timeOutTimer;

@end
