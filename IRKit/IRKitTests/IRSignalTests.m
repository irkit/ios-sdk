//
//  IRSignalTests.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2014/02/17.
//
//

#import <XCTest/XCTest.h>
#import "IRSignal.h"

@interface IRSignalTests : XCTestCase

@end

@implementation IRSignalTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testRound
{
    NSDictionary *signalInfo = @{
        @"data": @[ @100,@100,@100,@100,@100,@100,@100,@100,@100,@100 ],
        @"format": @"raw",
        @"freq": @38,
    };
    IRSignal *signal = [[IRSignal alloc] initWithDictionary: signalInfo];
    XCTAssertNotNil(signal);

    NSDictionary *signalInfo2 = signal.asPublicDictionary;
    XCTAssertEqualObjects(signalInfo, signalInfo2);
}

@end
