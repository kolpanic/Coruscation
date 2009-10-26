#import <Foundation/Foundation.h>
#import <Sparkle/Sparkle.h>

@interface CheckAppUpdateOperation : NSOperation {
@private
	NSURL *_url;
	BOOL _isExecuting;
	BOOL _isFinished;
	SUUpdater *_updater;
	NSTimer *_timeOut;
}

- (id) initWithBundleURL:(NSURL *) url;
- (void) finish;

@property (retain) NSURL *url;
@property (assign) BOOL isExecuting;
@property (assign) BOOL isFinished;
@property (retain) SUUpdater *updater;
@property (retain) NSTimer *timeOutTimer;

@end