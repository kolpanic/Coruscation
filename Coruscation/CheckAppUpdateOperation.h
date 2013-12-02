//
//  CheckAppUpdateOperation.h
//  Coruscation
//
//  Created by Karl Moskowski on 12/1/2013.
//  Copyright (c) 2013 Karl Moskowski. All rights reserved.
//

@import Foundation;
#import <Sparkle/Sparkle.h>

@interface CheckAppUpdateOperation : NSOperation 

- (id) initWithBundleURL:(NSURL *)url;

@end
