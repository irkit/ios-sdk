//
//  IRPeripheral.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRPeripheral.h"

@implementation IRPeripheral

- (NSComparisonResult) compareByFirstFoundDate: (IRPeripheral*) otherPeripheral {
    return [self.foundDate compare: otherPeripheral.foundDate];
}

#pragma mark -
#pragma NSKeyedArchiving

- (void)encodeWithCoder:(NSCoder*)coder {
    [coder encodeObject:_customizedName forKey:@"c"];
    [coder encodeObject:_isPaired       forKey:@"p"];
    [coder encodeObject:_foundDate      forKey:@"f"];
}

- (id)initWithCoder:(NSCoder*)coder {
    self = [super init];
    if (self) {
        _customizedName = [coder decodeObjectForKey:@"c"];
        _isPaired       = [coder decodeObjectForKey:@"p"];
        _foundDate      = [coder decodeObjectForKey:@"f"];
        
        if ( ! _customizedName ) {
            _customizedName = @"unknown";
        }
        if ( ! _isPaired ) {
            _isPaired = @NO;
        }
        if ( ! _foundDate ) {
            _foundDate = [NSDate date];
        }
    }
    return self;
}

@end
