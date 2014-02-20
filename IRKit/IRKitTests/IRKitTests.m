//
//  IRKitTests.m
//  IRKitTests
//
//  Created by Masakazu Ohtsuka on 2014/02/17.
//
//

#import "IRSignal.h"
#import "IRPeripherals.h"

@interface IRKitTests : NSObject

@end

@implementation IRKitTests

+ (IRSignal*)makeTestSignal {
    NSDictionary *signalInfo = @{
        @"data": @[ @100,@100,@100,@100,@100,@100,@100,@100,@100,@100 ],
        @"format": @"raw",
        @"freq": @38,
    };
    return [[IRSignal alloc] initWithDictionary: signalInfo];
}

+ (IRPeripheral*)makeTestPeripheral {
    IRPeripherals *peripherals = [[IRPeripherals alloc] init];
    return [peripherals savePeripheralWithName: @"IRKitTEST" deviceid: @"xxx"];
}

@end
