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
    IRPeripherals *peripherals = [[IRPeripherals alloc] init];
    IRPeripheral *peripheral   = [peripherals savePeripheralWithName: @"IRKitD2A8" deviceid: @"xxx"];

    NSDate *before = [NSDate date];

    BOOL is = [peripheral isReachableViaWifi];

    NSDate *after           = [NSDate date];
    NSTimeInterval interval = [after timeIntervalSinceDate: before];
    LOG( @"reachability took %.1f seconds", interval );
    XCTAssertEqual(interval < 0.1, true );
}

@end
