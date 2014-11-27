#import <Foundation/Foundation.h>
#import "IRSignal.h"

/// Collection of id<IRSendable>
/// IRSignals can contain IRSignal or IRSignalSequence
@interface IRSignals : NSObject

- (NSData *)data;
- (void)loadFromData:(NSData *)data;

- (void)loadFromStandardUserDefaultsKey:(NSString *)key;
- (void)saveToStandardUserDefaultsWithKey:(NSString *)key;
- (void)saveToUserDefaults:(NSUserDefaults*) defaults withKey:(NSString *)key;

- (id)objectAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfSignal:(id<IRSendable>)signal;

#pragma mark - Key Value Coding - Mutable Ordered To-Many Accessors

// Getter Indexed Accessors
- (NSArray *)signals;
- (NSUInteger)countOfSignals;
- (id<IRSendable>)objectInSignalsAtIndex:(NSUInteger)index;

// Mutable Indexed Accessors
- (void)insertObject:(id<IRSendable>)object inSignalsAtIndex:(NSUInteger)index;
- (void)removeObjectFromSignalsAtIndex:(NSUInteger)index;

- (void)addSignalsObject:(id<IRSendable>)object;

@end
