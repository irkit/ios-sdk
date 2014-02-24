#import <XCTest/XCTest.h>

@interface XCTestCase (Async)

@property (nonatomic, getter = isWaiting) BOOL waiting;

- (void)startWaiting;
- (void)startWaitingForInterval:(NSTimeInterval)interval;
- (void)stopWaiting;

- (void)waitUntilSatisfyingCondition:(BOOL (^)(void))conditionBlock;

@end
