//
//  MMSignalsDataSource.h
//  Minimal
//
//  Created by Masakazu Ohtsuka on 2014/01/03.
//  Copyright (c) 2014年 KAYAC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IRKit/IRKit.h>

@interface MMSignalsDataSource : NSObject<UITableViewDataSource>

- (void)addSignalsObject: (IRSignal*) signal;
- (IRSignal*)objectAtIndex: (NSUInteger) index;

@end
