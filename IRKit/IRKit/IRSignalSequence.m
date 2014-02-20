//
//  IRSignalSequence.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2014/02/20.
//
//

#import "IRSignalSequence.h"
#import "Log.h"
#import "IRSignalSendOperationQueue.h"
#import "IRSignalSendOperation.h"

@interface IRSignalSequence ()

@property (nonatomic) NSArray* signals;
@property (nonatomic) NSArray* intervals;

@end

@implementation IRSignalSequence

- (instancetype)initWithSignals:(NSArray*)signals andIntervals:(NSArray*)intervals {
    LOG_CURRENT_METHOD;
    NSAssert( signals.count == (intervals.count + 1), @"number of intervals should be `countofSignals - 1`" );
    NSAssert( signals && intervals, @"neither signals nor intervals can be null" );

    self = [self init];
    if (!self) {
        return nil;
    }

    _signals   = signals;
    _intervals = intervals;

    return self;
}

#pragma mark - IRSendalbe protocol

- (void)sendWithCompletion:(void (^)(NSError *))completion {
    LOG_CURRENT_METHOD;

    IRSignalSendOperationQueue *q = [[IRSignalSendOperationQueue alloc] init];
    q.completion = completion;

    for (int i=0; i<_signals.count; i++) {
        IRSignal *signal                      = _signals[ i ];
        __weak IRSignalSendOperationQueue *_q = q;
        IRSignalSendOperation *op             = [[IRSignalSendOperation alloc] initWithSignal: signal
                                                                                   completion:^(NSError *error) {
            LOG(@"error: %@", error);
            if (error) {
                _q.error = error;
            }
        }];
        [q addOperation: op];

        if (i != _signals.count - 1) {
            NSTimeInterval interval = ((NSNumber*)_intervals[ i ]).doubleValue;
            NSBlockOperation *b     = [NSBlockOperation blockOperationWithBlock:^{
                LOG( @"will sleep for: %.1f sec", interval );
                [NSThread sleepForTimeInterval: interval];
                LOG( @"slept for: %.1f sec", interval );
            }];
            [q addOperation: b];
        }
    }

}

@end
