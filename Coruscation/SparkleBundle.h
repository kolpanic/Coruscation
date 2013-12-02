//
//  SparkleBundle.h
//  Coruscation
//
//  Created by Karl Moskowski on 12/1/2013.
//  Copyright (c) 2013 Karl Moskowski. All rights reserved.
//

#import "_SparkleBundle.h"

@interface SparkleBundle : _SparkleBundle

@property (nonatomic, copy, readonly) NSString *displayVersion;
@property (nonatomic, strong, readonly) NSBundle *bundle;
@property (nonatomic, strong, readonly) NSImage *icon;

@end
