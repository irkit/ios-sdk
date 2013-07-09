//
//  IRSignals.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IRSignal.h"

typedef NS_ENUM(NSUInteger, IRAnimatingType) {
    IRAnimatingTypeInsert = 1,
    IRAnimatingTypeDelete = 2
};

@protocol IRAnimatingControllerDelegate <NSObject>

@optional
- (void)controller:(id)controller
   didChangeObject:(id)object
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(IRAnimatingType)type
      newIndexPath:(NSIndexPath *)newIndexPath;
- (void)controllerDidChangeContent:(id)controller;

@end

@interface IRSignals : NSObject<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, assign) id<IRAnimatingControllerDelegate> delegate;
- (id)objectAtIndex:(NSUInteger)index;
- (NSData*)data;
- (void)loadFromData: (NSData*)data;

#pragma mark - Key Value Coding - Mutable Unordered Accessors

- (NSArray*) signals;
- (NSUInteger) countOfSignals;
- (NSEnumerator*)enumeratorOfSignals;
- (IRSignal*)memberOfSignals:(IRSignal *)object;
- (void)addSignalsObject:(IRSignal *)object;
- (void)removeSignalsObject:(IRSignal *)object;

@end
