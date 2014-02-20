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
#import "XCTestCase+Async.h"
#import "IRKitTests.h"

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

- (void)testSendSequentiallyWithCompletion {
    IRSignals *signals = [[IRSignals alloc] init];
    IRSignal *signal   = [IRKitTests makeTestSignal];
    signal.peripheral = [IRKitTests makeTestPeripheral];
    [signals addSignalsObject: signal];

    [signals sendSequentiallyWithCompletion:^(NSError *error) {
        LOG(@"error: %@", error);
        XCTAssertNil(error);
        [self stopWaiting];
    }];

    [self startWaiting];
}

- (void)testSendSequentiallyWithIntervalsCompletionThrows {
    IRSignals *signals = [[IRSignals alloc] init];
    IRSignal *signal   = [IRKitTests makeTestSignal];
    signal.peripheral = [IRKitTests makeTestPeripheral];
    [signals addSignalsObject: signal];

    XCTAssertThrows( [signals sendSequentiallyWithIntervals: @[ @0 ] completion:^(NSError *error) {}] );
}

- (void)testSendSequentiallyWithIntervalsCompletion {
    IRSignals *signals = [[IRSignals alloc] init];
    IRSignal *signal   = [IRKitTests makeTestSignal];
    signal.peripheral = [IRKitTests makeTestPeripheral];
    [signals addSignalsObject: signal];
    [signals addSignalsObject: signal];
    [signals addSignalsObject: signal];

    [signals sendSequentiallyWithIntervals: @[ @0, @0 ] completion:^(NSError *error) {
        LOG(@"error: %@", error);
        XCTAssertNil(error);
        [self stopWaiting];
    }];

    [self startWaiting];
}

- (void)testSaveAndRestore {
    IRSignals *signals = [[IRSignals alloc] init];
    IRSignal *signal   = [IRKitTests makeTestSignal];
    signal.peripheral = [IRKitTests makeTestPeripheral];
    [signals addSignalsObject: signal];

    NSData *data = signals.data;
    XCTAssertNotNil(data);

    IRSignals *signals2 = [[IRSignals alloc] init];
    [signals2 loadFromData: data];
    XCTAssertEqual(signals2.countOfSignals, (NSUInteger)1);
}

@end
