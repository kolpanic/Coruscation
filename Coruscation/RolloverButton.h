//
//  RolloverButton.h
//  Coruscation
//
//  Created by Karl Moskowski on 12/1/2013.
//  Copyright (c) 2013 Karl Moskowski. All rights reserved.
//

@import Cocoa;

@interface RolloverButton : NSButton 

@property (strong, nonatomic) NSTrackingArea *trackingArea;
@property (copy, nonatomic) NSString *originalImageName;

@end
