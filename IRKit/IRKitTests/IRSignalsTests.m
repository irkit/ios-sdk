//
//  IRSignalsTests.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2014/02/18.
//
//

#import <XCTest/XCTest.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "IRSignals.h"
#import "IRPeripherals.h"
#import "Log.h"
#define ASYNC_TEST_INIT __block BOOL isFinished = NO
#define ASYNC_TEST_WAIT while (!isFinished) { \
        [[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.5]]; \
} \
    XCTAssertTrue(isFinished)
#define ASYNC_TEST_FINISHED isFinished = YES

@interface IRSignalsTests : XCTestCase

@end

@implementation IRSignalsTests

- (void)setUp {
    [super setUp];

    [OHHTTPStubs stubRequestsPassingTest:^BOOL (NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData: nil
                                          statusCode: 200
                                             headers: nil];
    }];
}

- (void)tearDown {
    [OHHTTPStubs removeAllStubs];
    [super tearDown];
}

- (IRSignal*)makeTestSignal {
    NSDictionary *signalInfo = @{
        @"data": @[ @100,@100,@100,@100,@100,@100,@100,@100,@100,@100 ],
        @"format": @"raw",
        @"freq": @38,
    };
    return [[IRSignal alloc] initWithDictionary: signalInfo];
}

- (IRPeripheral*)makeTestPeripheral {
    IRPeripherals *peripherals = [[IRPeripherals alloc] init];
    return [peripherals savePeripheralWithName: @"IRKitTEST" deviceid: @"xxx"];
}

- (void)testSendSequentiallyWithCompletion {
    ASYNC_TEST_INIT;

    IRSignals *signals = [[IRSignals alloc] init];
    IRSignal *signal   = [self makeTestSignal];
    signal.peripheral = [self makeTestPeripheral];
    [signals addSignalsObject: signal];

    [signals sendSequentiallyWithCompletion:^(NSError *error) {
        LOG(@"error: %@", error);
        XCTAssertNil(error);
        ASYNC_TEST_FINISHED;
    }];

    ASYNC_TEST_WAIT;
}

- (void)testSendSequentiallyWithIntervalsCompletionThrows {
    IRSignals *signals = [[IRSignals alloc] init];
    IRSignal *signal   = [self makeTestSignal];
    signal.peripheral = [self makeTestPeripheral];
    [signals addSignalsObject: signal];

    XCTAssertThrows( [signals sendSequentiallyWithIntervals: @[ @0 ] completion:^(NSError *error) {}] );
}

- (void)testSendSequentiallyWithIntervalsCompletion {
    ASYNC_TEST_INIT;

    IRSignals *signals = [[IRSignals alloc] init];
    IRSignal *signal   = [self makeTestSignal];
    signal.peripheral = [self makeTestPeripheral];
    [signals addSignalsObject: signal];
    [signals addSignalsObject: signal];
    [signals addSignalsObject: signal];

    [signals sendSequentiallyWithIntervals: @[ @0, @0 ] completion:^(NSError *error) {
        LOG(@"error: %@", error);
        XCTAssertNil(error);
        ASYNC_TEST_FINISHED;
    }];

    ASYNC_TEST_WAIT;
}

@end
