//
//  IRSignals.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRSignal.h"

@interface IRSignals : NSObject

- (void) save;

#pragma mark -
#pragma mark Key Value Coding - Mutable Indexed Accessors

- (NSArray*) signals;
- (NSUInteger) countOfSignals;
- (id) objectInSignalsAtIndex:(NSUInteger)index;
- (void) insertObject:(IRSignal *)object inSignalsAtIndex:(NSUInteger)index;
- (void) removeObjectFromSignalsAtIndex:(NSUInteger)index;
- (void) replaceObjectInSignalsAtIndex:(NSUInteger)index;

@end
