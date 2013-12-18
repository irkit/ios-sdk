#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IRSignal.h"

@interface IRSignals : NSObject

- (id)objectAtIndex:(NSUInteger)index;
- (NSData*)data;
- (void)loadFromData: (NSData*)data;
- (void)loadFromStandardUserDefaultsKey:(NSString*)key;
- (void)saveToStandardUserDefaultsWithKey:(NSString*)key;
- (NSString*)JSONRepresentation;
- (void)sendSequentiallyWithCompletion:(void (^)(NSError *error))completion;
- (NSUInteger) indexOfSignal: (IRSignal*) signal;

#pragma mark - Key Value Coding - Mutable Unordered Accessors

- (NSArray*) signals;
- (NSUInteger) countOfSignals;
- (IRSignal*)objectInSignalsAtIndex:(NSUInteger)index;
- (IRSignal*)memberOfSignals:(IRSignal *)object;
- (void)addSignalsObject:(IRSignal *)object;
- (void)insertObject:(IRSignal *)object inSignalsAtIndex:(NSUInteger)index;
- (void)removeObjectFromSignalsAtIndex:(NSUInteger)index;

@end
