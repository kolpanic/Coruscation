#import "RolloverButton.h"

@implementation RolloverButton

- (void) updateTrackingAreas {
	[super updateTrackingAreas];
	if (self.trackingArea)
		[self removeTrackingArea:self.trackingArea];
	NSTrackingAreaOptions options = NSTrackingInVisibleRect | NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow;
	self.trackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect options:options owner:self userInfo:nil];
	[self addTrackingArea:self.trackingArea];
}

- (void) mouseEntered:(NSEvent *)event {
	self.originalImageName = [[self image] name];
	[self setImage:[NSImage imageNamed:[self.originalImageName stringByAppendingString:@"Rollover"]]];
	[super mouseEntered:event];
}

- (void) mouseExited:(NSEvent *)event {
	[self setImage:[NSImage imageNamed:self.originalImageName]];
	[super mouseExited:event];
}

@synthesize trackingArea = i_trackingArea, originalImageName = i_originalImageName;

@end
