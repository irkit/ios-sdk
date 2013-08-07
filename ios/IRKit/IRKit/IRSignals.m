#import "IRSignals.h"
#import "IRPersistentStore.h"
#import "IRConst.h"
#import "IRSignalCell.h"
#import "IRHelper.h"
#import "IRSignalSendOperationQueue.h"
#import "IRSignalSendOperation.h"

@interface IRSignals ()

// IRSignal.uniqueID => IRSignal
@property (nonatomic, strong) NSMutableDictionary* signals;

@end

@implementation IRSignals

- (id)init {
    self = [super init];
    if (! self) { return nil; }
    _signals = [NSMutableDictionary dictionaryWithCapacity:0];
    
    return self;
}

- (id)objectAtIndex:(NSUInteger)index {
    LOG( @"index: %d", index);
    
    NSArray* keys = [_signals keysSortedByValueUsingSelector:@selector(compareByReceivedDate:)];
    NSString* key = [keys objectAtIndex: index];
    return _signals[key];
}

- (NSData*)data {
    return [NSKeyedArchiver archivedDataWithRootObject:_signals];
}

- (void)loadFromData: (NSData*)data {
    NSMutableSet *set = data ? (NSMutableSet*)[NSKeyedUnarchiver unarchiveObjectWithData:data]
                             : nil;
    if ( set ) {
        _signals = set;
    }
    else {
        _signals = [[NSMutableDictionary alloc] init];
    }
    LOG( @"loaded signals: %@", _signals );
}

- (void)loadFromStandardUserDefaultsKey:(NSString*)key {
    LOG( @"key: %@", key );
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSData *data = [d objectForKey: key];
    [self loadFromData:data];
}

- (void)saveToStandardUserDefaultsWithKey:(NSString*)key {
    LOG( @"key: %@", key );
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d setObject:self.data
          forKey:key];
    [d synchronize];
}

- (NSString*)JSONRepresentation {
    LOG_CURRENT_METHOD;

    NSArray *signals = [IRHelper mapObjects:self.signals
                                 usingBlock:(id)^(id obj, NSUInteger idx) {
                                     return ((IRSignal*)obj).asDictionary;
                                 }];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:signals
                                                       options:0
                                                         error:&error];
    NSString *json = [[NSString alloc] initWithData:jsonData
                                           encoding:NSUTF8StringEncoding];
    return json;
}

- (void)sendSequentiallyWithCompletion:(void (^)(NSError *))completion {
    LOG_CURRENT_METHOD;

    IRSignalSendOperationQueue *q = [[IRSignalSendOperationQueue alloc] init];
    q.completion = completion;

    for (IRSignal *signal in self.signals) {
        IRSignalSendOperation *op = [[IRSignalSendOperation alloc] initWithSignal:signal
                                                                       completion:^(NSError *error) {
                                                                           LOG(@"error: %@", error);
                                                                       }];
        [q addOperation:op];
    }
}

#pragma mark - Private methods

- (NSInteger) indexOfSignal: (IRSignal*) signal {
    LOG_CURRENT_METHOD;

    return [[_signals keysSortedByValueUsingSelector:@selector(compareByReceivedDate:)] indexOfObject:signal.uniqueID];
}

#pragma mark - Key Value Coding - Mutable Indexed Accessors

- (NSArray*) signals {
    return [_signals.allValues sortedArrayUsingSelector:@selector(compareByReceivedDate:)];
}

- (NSUInteger) countOfSignals {
    return _signals.count;
}

- (NSEnumerator*)enumeratorOfSignals {
    return self.signals.objectEnumerator;
}

- (IRSignal*)memberOfSignals:(IRSignal *)object {
    LOG_CURRENT_METHOD;
    
    return _signals[object.uniqueID];
}

- (void)addSignalsObject:(IRSignal *)object {

    if ( [self memberOfSignals:object] ) {
        return;
    }
    
    _signals[object.uniqueID] = object;
    
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate controller:self
                      didChangeObject:object
                          atIndexPath:nil
                        forChangeType:IRAnimatingTypeInsert
                         newIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            });
        }
        if ([_delegate respondsToSelector:@selector(controllerDidChangeContent:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate controllerDidChangeContent:self];
            });
        }
    }
}

- (void)removeSignalsObject:(IRSignal *)object {
    NSInteger row;
    if (_delegate) {
        row = [self indexOfSignal: object];
        if (row == NSNotFound) {
            LOG( @"something weird happened" );
        }
    }
    [_signals removeObjectForKey:object.uniqueID];
    
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate controller:self
                      didChangeObject:object
                          atIndexPath:[NSIndexPath indexPathForRow:row
                                                         inSection:0]
                        forChangeType:IRAnimatingTypeDelete
                         newIndexPath:nil];
            });
        }
        if ([_delegate respondsToSelector:@selector(controllerDidChangeContent:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate controllerDidChangeContent:self];
            });
        }
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG( @"indexPath.row: %d", indexPath.row);

    IRSignalCell *cell = (IRSignalCell*)[tableView dequeueReusableCellWithIdentifier:IRKitCellIdentifierSignal];
    if (cell == nil) {
        NSBundle *main = [NSBundle mainBundle];
        NSBundle *resources = [NSBundle bundleWithPath:[main pathForResource:@"IRKitResources"
                                                                      ofType:@"bundle"]];
        [tableView registerNib:[UINib nibWithNibName:@"IRSignalCell" bundle:resources]
        forCellReuseIdentifier:IRKitCellIdentifierSignal];

        cell = [tableView dequeueReusableCellWithIdentifier:IRKitCellIdentifierSignal];
    }
    [cell inflateFromSignal:[self objectAtIndex:indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    LOG_CURRENT_METHOD;
    return self.countOfSignals;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;
    return [IRSignalCell height];
}

@end
