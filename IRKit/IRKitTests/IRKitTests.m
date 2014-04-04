//
//  IRKitTests.m
//  IRKitTests
//
//  Created by Masakazu Ohtsuka on 2014/02/17.
//
//

#import "IRSignal.h"
#import "IRPeripherals.h"
#import "IRUserDefaultsStore.h"

@interface IRKitTests : NSObject

@end

@implementation IRKitTests

+ (IRSignal*)makeTestSignal {
    NSDictionary *signalInfo = @{
        @"data": @[ @100,@100,@100,@100,@100,@100,@100,@100,@100,@100 ],
        @"format": @"raw",
        @"freq": @38,
        @"type": @"single",
    };
    return [[IRSignal alloc] initWithDictionary: signalInfo];
}

+ (IRPeripheral*)makeTestPeripheral {
    IRUserDefaultsStore *store = [[IRUserDefaultsStore alloc] init];
    IRPeripherals *peripherals = [[IRPeripherals alloc] initWithPersistentStore: store];
    return [peripherals savePeripheralWithName: @"IRKitTEST" deviceid: @"xxx"];
}

@end
