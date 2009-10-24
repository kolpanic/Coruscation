#import <Foundation/Foundation.h>

@interface CollectionItemView : NSView {
@private
	id _delegate;
}

@property (retain) IBOutlet id delegate;

@end