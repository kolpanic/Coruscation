//
//  RolloverButton.m
//  Coruscation
//
//  Created by Karl Moskowski on 12/1/2013.
//  Copyright (c) 2013 Karl Moskowski. All rights reserved.
//

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
	if (self.originalImageName)
		[self setImage:[NSImage imageNamed:[self.originalImageName stringByAppendingString:@"Rollover"]]];
	[super mouseEntered:event];
}

- (void) mouseExited:(NSEvent *)event {
	if (self.originalImageName)
		[self setImage:[NSImage imageNamed:self.originalImageName]];
	[super mouseExited:event];
}

@end
