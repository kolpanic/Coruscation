//
//  CoruscationCollectionView.m
//  Coruscation
//
//  Created by Karl Moskowski on 12/1/2013.
//  Copyright (c) 2013 Karl Moskowski. All rights reserved.
//

#import "CoruscationCollectionView.h"
#import "SparkleBundle.h"

@interface CoruscationCollectionView ()

@property (nonatomic, weak) IBOutlet id delegate;

@end

@implementation CoruscationCollectionView

- (id) copyWithZone:(NSZone *)zone {
	CoruscationCollectionView *copy = [[CoruscationCollectionView allocWithZone:zone] initWithFrame:[self frame]];
	copy.delegate = self.delegate;
	return copy;
}

- (void) mouseDown:(NSEvent *)event {
	[super mouseDown:event];
	if ([event clickCount] > 1) {
		if ([self.delegate respondsToSelector:@selector(openSelected:)]) {
			[self.delegate performSelector:@selector(openSelected:) withObject:self];
		}
	}
}

@end

@interface CoruscationCollectionViewItem ()

- (IBAction) reveal:(id)sender;
- (IBAction) releaseNotes:(id)sender;
- (IBAction) downloadUpdate:(id)sender;

@end

@implementation CoruscationCollectionViewItem

- (IBAction) reveal:(id)sender {
	[[(CoruscationCollectionView *)self.view delegate] reveal:[self representedObject]];
}

- (IBAction) releaseNotes:(id)sender {
	[[(CoruscationCollectionView *)self.view delegate] releaseNotes:[self representedObject]];
}

- (IBAction) downloadUpdate:(id)sender {
	[[(CoruscationCollectionView *)self.view delegate] downloadUpdate:[self representedObject]];
}

@end
