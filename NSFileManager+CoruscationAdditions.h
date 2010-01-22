#import <Cocoa/Cocoa.h>

@interface NSFileManager (CoruscationAdditions)

- (BOOL) isFilePackageAtPath:(NSString *) path;

@end
