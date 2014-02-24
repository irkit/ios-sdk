//
//  IRSignalSequenceTests.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2014/02/20.
//
//

#import <XCTest/XCTest.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "IRSignals.h"
#import "IRSignal.h"
#import "IRSignalSequence.h"
#import "XCTestCase+Async.h"
#import "IRKitTests.h"

@interface IRSignalSequenceTests : XCTestCase

@end

@implementation IRSignalSequenceTests

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


- (void)testRound {
    NSDictionary *signalInfo = @{
        @"data": @[ @100,@100,@100,@100,@100,@100,@100,@100,@100,@100 ],
        @"format": @"raw",
        @"freq": @38,
        @"type": @"single",
    };
    IRSignal *signal           = [[IRSignal alloc] initWithDictionary: signalInfo];
    IRSignalSequence *sequence = [[IRSignalSequence alloc] initWithSignals: @[ signal ] andIntervals: @[]];
    XCTAssertNotNil(sequence);

    NSDictionary *signalInfo2 = sequence.asPublicDictionary;
    NSDictionary *expected    = @{
        @"type": @"sequence",
        @"signals": @[ signalInfo ],
        @"intervals": @[],
    };
    XCTAssertEqualObjects(signalInfo2, expected);
}

- (void)testInitThrows {
    IRSignal *signal = [IRKitTests makeTestSignal];
    signal.peripheral = [IRKitTests makeTestPeripheral];
    IRSignal *signal2 = [IRKitTests makeTestSignal];
    signal2.peripheral = [IRKitTests makeTestPeripheral];
    NSArray *signals = @[ signal, signal2 ];

    XCTAssertThrows( [[IRSignalSequence alloc] initWithSignals: signals andIntervals: @[] ] );
}

- (void)testInitAndSend1 {
    IRSignal *signal = [IRKitTests makeTestSignal];
    signal.peripheral = [IRKitTests makeTestPeripheral];
    IRSignalSequence *sequence = [[IRSignalSequence alloc] initWithSignals: @[ signal ] andIntervals: @[]];
    XCTAssert(sequence);

    [sequence sendWithCompletion:^(NSError *error) {
        XCTAssertNil(error);
        [self stopWaiting];
    }];
    [self startWaiting];
}

- (void)testInitAndSend2 {
    IRSignal *signal = [IRKitTests makeTestSignal];
    signal.peripheral = [IRKitTests makeTestPeripheral];
    IRSignalSequence *sequence = [[IRSignalSequence alloc] initWithSignals: @[ signal, signal ] andIntervals: @[ @0 ]];
    XCTAssert(sequence);

    [sequence sendWithCompletion:^(NSError *error) {
        XCTAssertNil(error);
        [self stopWaiting];
    }];
    [self startWaiting];
}

@end
