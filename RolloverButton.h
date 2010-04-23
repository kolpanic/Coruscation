#import <Cocoa/Cocoa.h>

@interface RolloverButton : NSButton {
@private
	NSTrackingArea *i_trackingArea;
	NSString *i_originalImageName;
}

@property (retain, nonatomic) NSTrackingArea *trackingArea;
@property (copy, nonatomic) NSString *originalImageName;

@end
