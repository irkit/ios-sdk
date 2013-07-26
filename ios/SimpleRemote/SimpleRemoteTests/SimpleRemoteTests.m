//
//  SimpleRemoteTests.m
//  SimpleRemoteTests
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//
//  Unit-Test Result Macro Reference
//  see http://developer.apple.com/library/ios/#documentation/DeveloperTools/Conceptual/UnitTesting/AB-Unit-Test_Result_Macro_Reference/result_macro_reference.html#//apple_ref/doc/uid/TP40002143-CH9-SW1

#import "SimpleRemoteTests.h"
#import "SRHelper.h"

@implementation SimpleRemoteTests {
BOOL _isFinished; // test finished
}

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    // Tear-down code here.
    do {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    } while (!_isFinished);

    [super tearDown];
}

- (void)testUploadIcon
{
    UIImage *image = [UIImage imageNamed:@"icon.png"];
    NSArray *irdata = @[ @100, @100, @100 ];

    [SRHelper uploadIcon:image
              withIRData:irdata
              withIRFreq:38
       completionHandler:^(NSHTTPURLResponse *response, NSDictionary *json, NSError *error) {
           LOG(@"response: %@, image: %@, error: %@", response, json, error);
           STAssertTrue(response.statusCode == 200, @"status code valid");
           STAssertTrue(json[@"Icon"] != nil, @"Icon key");
           STAssertTrue(json[@"Icon"][@"Id"] != nil, @"Icon.Id key");
           STAssertTrue(json[@"Icon"][@"Url"] != nil, @"Icon.Url key");
           STAssertTrue(error == nil, @"no error");
           _isFinished = YES;
       }];
}

@end
