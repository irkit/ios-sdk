//
//  IRSignals.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IRSignals : NSObject

- (BOOL)containsObject:(id)object;
- (void)addObject:(id)object;
- (id)objectAtIndex:(NSUInteger)index;

@property (nonatomic, getter = count) NSUInteger count;

@end
