#import <Foundation/Foundation.h>
#import "IRPeripheral.h"
#import "IRPersistentStore.h"

@interface IRPeripherals : NSObject

- (instancetype)initWithPersistentStore:(id<IRPersistentStore>)store;
- (id)objectAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfObject:(id)object;
- (IRPeripheral *)peripheralWithName:(NSString *)name;
- (void)save;
- (void)saveToStore:(id<IRPersistentStore>)store;
- (NSUInteger)countOfReadyPeripherals;
- (BOOL)isKnownName:(NSString *)hostname;
- (IRPeripheral *)registerPeripheralWithName:(NSString *)hostname;
- (IRPeripheral *)savePeripheralWithName:(NSString *)hostname deviceid:(NSString *)deviceid;
- (void)clearPeripherals;

#pragma mark - Key Value Coding - Mutable Unordered Accessors

- (NSArray *)peripherals;
- (NSUInteger)countOfPeripherals;
- (NSEnumerator *)enumeratorOfPeripherals;
- (void)addPeripheralsObject:(IRPeripheral *)peripheral;
- (void)removePeripheralsObject:(IRPeripheral *)peripheral;
- (IRPeripheral *)memberOfPeripherals:(IRPeripheral *)object;

@end
