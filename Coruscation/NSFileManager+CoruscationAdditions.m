//
//  NSFileManager+CoruscationAdditions.m
//  Coruscation
//
//  Created by Karl Moskowski on 12/1/2013.
//  Copyright (c) 2013 Karl Moskowski. All rights reserved.
//

#import "NSFileManager+CoruscationAdditions.h"

@implementation NSFileManager (CoruscationAdditions)

// because NSWorkspace isn't documented as being thread-safe, have to do this

- (BOOL) isFilePackageAtPath:(NSString *)path {
	NSURL *url = [NSURL fileURLWithPath:path];
	LSItemInfoRecord info;
	LSCopyItemInfoForURL((__bridge CFURLRef)url, kLSRequestAllFlags, &info);
	return 0 != (info.flags & kLSItemInfoIsPackage);
}

@end
