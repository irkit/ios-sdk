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
#import "IRHelper.h"

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

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    LOG_CURRENT_METHOD;
    self = [self init];
    if (!self) {
        return nil;
    }
    NSAssert( [dictionary[@"type"] isEqualToString: @"sequence"], @"dictionary.type must be \"sequence \"" );

    NSArray* signals   = dictionary[ @"signals" ];
    NSArray* intervals = dictionary[ @"intervals" ];
    self = [self initWithSignals: signals andIntervals: intervals];

    if (dictionary[@"name"]) {
        _name = dictionary[@"name"];
    }
    else {
        _name = @"unknown";
    }

    if (dictionary[@"custom"]) {
        _custom = dictionary[@"custom"];
    }

    return self;
}

#pragma mark - IRSendable protocol

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

- (NSDictionary*)asDictionary {
    LOG_CURRENT_METHOD;

    NSArray *signals = [IRHelper mapObjects: _signals usingBlock:^id (id obj, NSUInteger idx) {
        return [obj asDictionary];
    }];
    return @{
               @"type":      @"sequence",
               @"name":      _name   ? _name   : [NSNull null],
               @"custom":    _custom ? _custom : [NSNull null],
               @"signals":   signals,
               @"intervals": _intervals,
    };
}

- (NSDictionary *)asSendableDictionary {
    LOG_CURRENT_METHOD;

    NSArray *signals = [IRHelper mapObjects: _signals usingBlock:^id (id obj, NSUInteger idx) {
        return [obj asSendableDictionary];
    }];
    return @{
               @"type":      @"sequence",
               @"name":      _name   ? _name   : [NSNull null],
               @"signals":   signals,
               @"intervals": _intervals,
    };
}

- (NSDictionary *)asPublicDictionary {
    LOG_CURRENT_METHOD;

    NSArray *signals = [IRHelper mapObjects: _signals usingBlock:^id (id obj, NSUInteger idx) {
        return [obj asPublicDictionary];
    }];
    return @{
               @"type":      @"sequence",
               @"signals":   signals,
               @"intervals": _intervals,
    };
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject: _name forKey: @"n"];
    [coder encodeObject: _custom forKey: @"c"];
    [coder encodeObject: _signals forKey: @"s"];
    [coder encodeObject: _intervals forKey: @"i"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _name      = [coder decodeObjectForKey: @"n"];
        _custom    = [coder decodeObjectForKey: @"c"];
        _signals   = [coder decodeObjectForKey: @"s"];
        _intervals = [coder decodeObjectForKey: @"i"];
    }
    return self;
}

@end
