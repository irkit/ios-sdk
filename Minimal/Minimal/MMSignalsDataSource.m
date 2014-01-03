//
//  MMSignalsDataSource.m
//  Minimal
//
//  Created by Masakazu Ohtsuka on 2014/01/03.
//  Copyright (c) 2014年 KAYAC Inc. All rights reserved.
//

#import "MMSignalsDataSource.h"

@interface MMSignalsDataSource ()

@property (nonatomic) IRSignals *signals;

@end

@implementation MMSignalsDataSource

- (instancetype) init {
    self = [super init];
    if (! self) { return nil; }

    _signals = [[IRSignals alloc] init];

    return self;
}

#pragma mark - IRSignals delegate

- (void)addSignalsObject: (IRSignal*) signal {
    [_signals addSignalsObject:signal];
}

- (IRSignal*)objectAtIndex: (NSUInteger) index {
    return [_signals objectAtIndex:index];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_signals countOfSignals];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MMSignalCell"];
    IRSignal *signal = [_signals objectAtIndex:indexPath.row];
    cell.textLabel.text = signal.name;
    return cell;
}

@end
