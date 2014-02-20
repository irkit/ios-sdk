#import "Log.h"
#import "IRSignals.h"
#import "IRPersistentStore.h"
#import "IRConst.h"
#import "IRHelper.h"
#import "IRSignalSendOperationQueue.h"
#import "IRSignalSendOperation.h"

@interface IRSignals ()

@property (nonatomic) NSMutableArray *signals;

@end

@implementation IRSignals

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    _signals = [NSMutableArray arrayWithCapacity: 0];

    return self;
}

- (NSData *)data {
    return [NSKeyedArchiver archivedDataWithRootObject: _signals];
}

- (void)loadFromData:(NSData *)data {
    NSMutableArray *array = data ? ((NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData: data]).mutableCopy
                            : nil;

    if (array) {
        _signals = array;
    }
    else {
        _signals = [[NSMutableArray alloc] init];
    }
    LOG(@"loaded signals: %@", _signals);
}

- (void)loadFromStandardUserDefaultsKey:(NSString *)key {
    LOG(@"key: %@", key);
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSData *data = [d objectForKey: key];
    [self loadFromData: data];
}

- (void)saveToStandardUserDefaultsWithKey:(NSString *)key {
    LOG(@"key: %@", key);
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d setObject: self.data
          forKey: key];
    [d synchronize];
}

- (NSString *)JSONRepresentation {
    LOG_CURRENT_METHOD;

    NSArray *signals = [IRHelper mapObjects: self.signals
                                 usingBlock: (id) ^ (id obj, NSUInteger idx) {
                            return ((IRSignal *)obj).asDictionary;
                        }];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: signals
                                                       options: 0
                                                         error: &error];
    NSString *json = [[NSString alloc] initWithData: jsonData
                                           encoding: NSUTF8StringEncoding];
    return json;
}

- (void)sendSequentiallyWithCompletion:(void (^)(NSError *))completion {
    LOG_CURRENT_METHOD;

    IRSignalSendOperationQueue *q = [[IRSignalSendOperationQueue alloc] init];
    q.completion = completion;

    for (IRSignal *signal in self.signals) {
        __weak IRSignalSendOperationQueue *_q = q;
        IRSignalSendOperation *op = [[IRSignalSendOperation alloc] initWithSignal: signal
                                                                       completion:^(NSError *error) {
            LOG(@"error: %@", error);
            if (error) {
                _q.error = error;
            }
        }];
        [q addOperation: op];
    }
}

- (id)objectAtIndex:(NSUInteger)index {
    LOG(@"index: %d", index);
    return _signals[ index ];
}

- (NSUInteger)indexOfSignal:(IRSignal *)signal {
    LOG_CURRENT_METHOD;

    return [_signals indexOfObject: signal];
}

#pragma mark - Key Value Coding - Mutable Indexed Accessors

- (NSArray *)signals {
    return _signals;
}

- (NSUInteger)countOfSignals {
    return [_signals count];
}

- (IRSignal *)objectInSignalsAtIndex:(NSUInteger)index {
    return _signals[ index ];
}

- (void)addSignalsObject:(IRSignal *)object {
    [_signals addObject: object];
}

- (void)insertObject:(IRSignal *)object inSignalsAtIndex:(NSUInteger)index {
    [_signals insertObject: object atIndex: index];
}

- (void)removeObjectFromSignalsAtIndex:(NSUInteger)index {
    [_signals removeObjectAtIndex: index];
}

@end
