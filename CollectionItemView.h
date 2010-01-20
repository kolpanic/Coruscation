#import <Foundation/Foundation.h>

@interface CollectionItemView : NSView {
@private
	id i_delegate;
}

@property (retain) IBOutlet id delegate;

@end
