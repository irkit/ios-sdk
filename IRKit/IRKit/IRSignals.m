#import "Log.h"
#import "IRSignals.h"

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
    NSData *data      = [d objectForKey: key];
    [self loadFromData: data];
}

- (void)saveToStandardUserDefaultsWithKey:(NSString *)key {
    [self saveToUserDefaults: [NSUserDefaults standardUserDefaults]
                     withKey: key];
}

- (void)saveToUserDefaults:(NSUserDefaults*) defaults withKey:(NSString *)key {
    LOG(@"key: %@", key);
    [defaults setObject: self.data
                 forKey: key];
    [defaults synchronize];
}

- (id)objectAtIndex:(NSUInteger)index {
    LOG(@"index: %lu", (unsigned long)index);
    return _signals[ index ];
}

- (NSUInteger)indexOfSignal:(id<IRSendable>)signal {
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

- (id<IRSendable>)objectInSignalsAtIndex:(NSUInteger)index {
    return _signals[ index ];
}

- (void)addSignalsObject:(id<IRSendable>)object {
    [_signals addObject: object];
}

- (void)insertObject:(id<IRSendable>)object inSignalsAtIndex:(NSUInteger)index {
    [_signals insertObject: object atIndex: index];
}

- (void)removeObjectFromSignalsAtIndex:(NSUInteger)index {
    [_signals removeObjectAtIndex: index];
}

@end
