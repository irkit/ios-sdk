//
//  SRURLQueryTests.m
//  SimpleRemote
//
//  Created by Masakazu Ohtsuka on 2013/07/26.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "SRURLQueryTests.h"
#import "SRURLHandler.h"
#import <IRKit/IRKit.h>

@implementation SRURLQueryTests

- (void)setUp
{
    [super setUp];

    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.

    [super tearDown];
}

- (void)testExample
{
    NSString *name = @"エアコンオン";
    NSUInteger frequency = 38;
    NSArray *data = @[ @100, @100, @100, @100 ];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:1374803718];
    NSString *uuidString = @"ED572663-3FAA-4258-8126-5ADD908048CE";

    IRSignal *signal = [[IRSignal alloc] init];
    signal.name = name;
    signal.frequency = frequency;
    signal.data = data;
    signal.receivedDate = date;
    IRPeripheral *peripheral = [[IRPeripheral alloc] init];
    CFUUIDRef uuid = CFUUIDCreateFromString(nil, (CFStringRef)uuidString);
    peripheral.UUID = uuid;
    signal.peripheral = peripheral;
    IRSignals *signals = [[IRSignals alloc] init];
    [signals addSignalsObject:signal];

    NSString *json = [signals jsonRepresentation];
    NSLog(@"json string: %@", json);

    NSString *escapedString = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 kCFAllocatorDefault,
                                                                                 (CFStringRef)json,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8));
    NSString *urlString = [NSString stringWithFormat:@"irkit-one://send?irsignals=%@",escapedString];
    NSURL *url = [NSURL URLWithString:urlString];
    LOG( @"url: %@", url );

    BOOL can = [SRURLHandler canHandleOpenURL:url];
    STAssertTrue(can, @"canHandleOpenURL");

    NSArray *parsedSignals = [SRURLHandler signalsDictionariesFromURL:url];
    LOG( @"parsedSignals: %@", parsedSignals );
    NSDictionary *expected = @{
                             @"name":name,
                             @"frequency":[NSNumber numberWithUnsignedInteger:38],
                             @"data":data,
                             @"receivedDate":[NSNumber numberWithDouble:[date timeIntervalSince1970]],
                             @"uuid":uuidString };
    for (NSString *key in expected.allKeys) {
        STAssertEqualObjects(parsedSignals[0][key], expected[key],
                             [NSString stringWithFormat:@"%@ is equal",key]);
    }
}

@end
