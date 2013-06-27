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
- (id)objectAtIndex:(NSUInteger)index;

#pragma mark -
#pragma mark Key Value Coding - Mutable Unordered Accessors

- (NSArray*) signals;
- (NSUInteger) countOfSignals;
- (NSEnumerator*)enumeratorOfSignals;
- (IRSignal*)memberOfSignals:(IRSignal *)object;
- (void)addSignalsObject:(IRSignal *)object;
- (void)removeSignalsObject:(IRSignal *)object;

@end
