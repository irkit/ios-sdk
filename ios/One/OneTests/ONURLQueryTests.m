#import "ONURLQueryTests.h"
#import "ONURLHandler.h"
#import <IRKit/IRKit.h>

@implementation ONURLQueryTests

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
    NSNumber *frequency = @38;
    NSArray *data = @[ @100, @100, @100, @100 ];
    NSNumber *date = @1374803718;
    NSString *uuidString = @"ED572663-3FAA-4258-8126-5ADD908048CE";

    NSDictionary *signalDictionary = @{
                                       @"name":name,
                                       @"frequency":frequency,
                                       @"data":data,
                                       @"receivedDate":date,
                                       @"uuid":uuidString,
                                       };
    IRSignal *signal = [[IRSignal alloc] initWithDictionary:signalDictionary];
    IRSignals *signals = [[IRSignals alloc] init];
    [signals addSignalsObject:signal];

    NSString *json = [signals JSONRepresentation];
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

    BOOL can = [ONURLHandler canHandleOpenURL:url];
    STAssertTrue(can, @"canHandleOpenURL");

    NSArray *parsedSignals = [ONURLHandler signalsDictionariesFromURL:url];
    LOG( @"parsedSignals: %@", parsedSignals );
    NSDictionary *expected = @{
                             @"name":name,
                             @"frequency":[NSNumber numberWithUnsignedInteger:38],
                             @"data":data,
                             @"receivedDate":date,
                             @"uuid":uuidString };
    for (NSString *key in expected.allKeys) {
        STAssertEqualObjects(parsedSignals[0][key], expected[key],
                             [NSString stringWithFormat:@"%@ is equal",key]);
    }
}

@end
