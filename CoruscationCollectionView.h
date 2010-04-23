#import <Foundation/Foundation.h>

@interface CoruscationCollectionView : NSView {
@private
	id i_delegate;
}

@property (retain) IBOutlet id delegate;

@end

@interface CoruscationCollectionViewItem : NSCollectionViewItem

- (IBAction) reveal:(id)sender;
- (IBAction) releaseNotes:(id)sender;
- (IBAction) downloadUpdate:(id)sender;

@end
