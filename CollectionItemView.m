#import "CollectionItemView.h"

@implementation CollectionItemView

- (id) copyWithZone:(NSZone *) zone {
	CollectionItemView *copy = [[CollectionItemView allocWithZone:zone] initWithFrame:[self frame]];
	copy.delegate = self.delegate;
	return copy;
}

- (NSView *) hitTest:(NSPoint) point {
	return NSPointInRect(point, [self convertRect:[self bounds] toView:[self superview]]) ? self : nil;
}

- (void) mouseDown:(NSEvent *) event {
	[super mouseDown:event];
	if ([event clickCount] > 1)
		if ([self.delegate respondsToSelector:@selector(openSelected:)])
			[self.delegate performSelector:@selector(openSelected:)withObject:self];
}

@synthesize delegate = i_delegate;

@end
