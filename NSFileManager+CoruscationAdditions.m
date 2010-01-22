#import "NSFileManager+CoruscationAdditions.h"

@implementation NSFileManager (CoruscationAdditions)

// because NSWorkspace isn't documented as being thread-safe, have to do this

- (BOOL) isFilePackageAtPath:(NSString *) path {
	NSURL *url = [NSURL fileURLWithPath:path];
	LSItemInfoRecord info;
	LSCopyItemInfoForURL((CFURLRef)url, kLSRequestAllFlags, &info);
	return (0 != (info.flags & kLSItemInfoIsPackage));
}

@end
