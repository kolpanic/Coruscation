#import "_SparkleBundle.h"

@interface SparkleBundle : _SparkleBundle {
@private
	NSBundle *i_bundle;
	NSImage *i_icon;
}

@property (retain, readonly) NSBundle *bundle;
@property (retain, readonly) NSImage *icon;

@end
