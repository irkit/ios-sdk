// thanks to https://github.com/ishkawa/ISHTTPOperation

#import "XCTestCase+Async.h"
#import <objc/runtime.h>

static char XCTestCaseWaitingKey;

@implementation XCTestCase (Async)

- (BOOL)isWaiting {
    return [objc_getAssociatedObject(self, &XCTestCaseWaitingKey) boolValue];
}

- (void)setWaiting:(BOOL)waiting {
    objc_setAssociatedObject(self, &XCTestCaseWaitingKey, @(waiting), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)startWaiting {
    self.waiting = YES;

    do {
        [[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.1]];
    } while (self.isWaiting);
}

- (void)startWaitingForInterval:(NSTimeInterval)interval {
    self.waiting = YES;
    NSDate *startedDate = [NSDate date];

    do {
        [[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.1]];
    } while (self.isWaiting && ([[NSDate date] timeIntervalSinceDate: startedDate] < interval));

    if (self.isWaiting) {
        XCTFail(@"timed out");
    }
}

- (void)stopWaiting {
    self.waiting = NO;
}

@end
