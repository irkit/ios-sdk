//
//  IRPeripheral.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRPeripheral.h"
#import "IRKit.h"

@implementation IRPeripheral

- (id) init {
    LOG_CURRENT_METHOD;
    self = [super init];
    if ( ! self ) {
        return nil;
    }
    _authorized       = NO;
    _shouldReadIRData = NO;
    // on memory should be enough
    _receivedCount = 0;

    return self;
}

- (NSComparisonResult) compareByFirstFoundDate: (IRPeripheral*) otherPeripheral {
    return [self.foundDate compare: otherPeripheral.foundDate];
}

- (void) restartDisconnectTimer {
    LOG_CURRENT_METHOD;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    // disconnect after interval
    // regarding that we might want to continuously write to this peripheral
    [self performSelector:@selector(disconnect)
               withObject:nil
               afterDelay:1.];
}

- (void) disconnect {
    LOG_CURRENT_METHOD;
    [[IRKit sharedInstance] disconnectPeripheral: self];
}

#pragma mark -
#pragma NSKeyedArchiving

- (void)encodeWithCoder:(NSCoder*)coder {
    [coder encodeObject:_customizedName forKey:@"c"];
    [coder encodeObject:_isPaired       forKey:@"p"];
    [coder encodeObject:_foundDate      forKey:@"f"];
    [coder encodeObject:[NSNumber numberWithBool:_authorized] forKey:@"a"];
}

- (id)initWithCoder:(NSCoder*)coder {
    self = [super init];
    if (self) {
        _customizedName = [coder decodeObjectForKey:@"c"];
        _isPaired       = [coder decodeObjectForKey:@"p"];
        _foundDate      = [coder decodeObjectForKey:@"f"];
        _authorized     = [[coder decodeObjectForKey:@"a"] boolValue];
        _peripheral     = nil;
        
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
