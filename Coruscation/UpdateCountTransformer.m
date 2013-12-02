//
//  UpdateCountTransformer.m
//  Coruscation
//
//  Created by Karl Moskowski on 12/1/2013.
//  Copyright (c) 2013 Karl Moskowski. All rights reserved.
//

#import "UpdateCountTransformer.h"

@implementation UpdateCountTransformer

+ (Class) transformedValueClass {
	return [NSString class];
}

+ (BOOL) allowsReverseTransformation {
	return NO;
}

- (id) transformedValue:(id)value {
	NSUInteger v = [value unsignedIntegerValue];
	NSString *transformedValue = nil;
	switch (v) {
		case 0:
			transformedValue = NSLocalizedString(@"No available updates", @"status message");
			break;
		case 1:
			transformedValue = NSLocalizedString(@"1 available update", @"status message");
			break;
		default:
			transformedValue = [NSString stringWithFormat:NSLocalizedString(@"%u available updates", @"status message"), v];
			break;
	}
	return transformedValue;
}

@end
