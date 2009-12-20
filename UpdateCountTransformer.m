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
