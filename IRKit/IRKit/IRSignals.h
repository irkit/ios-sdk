#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IRSignal.h"

@interface IRSignals : NSObject

- (id)objectAtIndex:(NSUInteger)index;
- (NSData *)data;
- (void)loadFromData:(NSData *)data;
- (void)loadFromStandardUserDefaultsKey:(NSString *)key;
- (void)saveToStandardUserDefaultsWithKey:(NSString *)key;
- (NSString *)JSONRepresentation;
- (void)sendSequentiallyWithCompletion:(void (^) (NSError * error))completion;
- (void)sendSequentiallyWithIntervals:(NSArray*)intervals completion:(void (^)(NSError *))completion;
- (NSUInteger)indexOfSignal:(IRSignal *)signal;

#pragma mark - Key Value Coding - Mutable Ordered To-Many Accessors

// Getter Indexed Accessors
- (NSArray *)signals;
- (NSUInteger)countOfSignals;
- (IRSignal *)objectInSignalsAtIndex:(NSUInteger)index;

// Mutable Indexed Accessors
- (void)insertObject:(IRSignal *)object inSignalsAtIndex:(NSUInteger)index;
- (void)removeObjectFromSignalsAtIndex:(NSUInteger)index;

- (void)addSignalsObject:(IRSignal *)object;

@end
