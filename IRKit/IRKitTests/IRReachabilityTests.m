//
//  IRReachabilityTests.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2014/03/17.
//
//

#import <XCTest/XCTest.h>
#import "IRPeripherals.h"
#import "IRPeripheral.h"
#import "Log.h"
#import "IRReachability.h"
#import "XCTestCase+Async.h"

@interface IRReachabilityTests : XCTestCase

@end

@implementation IRReachabilityTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testReachable {
    NSDate *before = [NSDate date];

    IRReachability *r = [IRReachability reachabilityWithHostname: @"google.com"];
    // IRReachability *r = [IRReachability reachabilityWithHostname: @"irkitd2b4.local"];
    BOOL wifi   = [r isReachableViaWiFi];
    BOOL direct = [r isReachableViaWiFiAndDirect];

    NSDate *after           = [NSDate date];
    NSTimeInterval interval = [after timeIntervalSinceDate: before];
    LOG( @"reachability took %.1f seconds", interval );

    XCTAssertEqual(wifi, 0, @"is initially not reachable (wifi)");
    XCTAssertEqual(direct, 0, @"is initially not reachable (direct)");
    XCTAssertEqual(interval < 0.1, true );

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BOOL wifi = [r isReachableViaWiFi];
        BOOL direct = [r isReachableViaWiFiAndDirect];
        XCTAssertEqual(wifi, 1, @"is reachable via wifi after a while");
        XCTAssertEqual(direct, 0, @"google is not reachable directly");
        [self stopWaiting];
    });
    [self startWaiting];
}

@end
