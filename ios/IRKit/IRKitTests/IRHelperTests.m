//
//  IRHelperTests.m
//  IRHelperTests
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRHelperTests.h"
#import "IRHelper.h"

@implementation IRHelperTests {
    BOOL _isFinished; // test finished
}

- (void)setUp
{
    [super setUp];

    _isFinished = NO;
}

- (void)tearDown
{
    do {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    } while (!_isFinished);
    
    [super tearDown];
}

- (void)testLoadImage
{
    [IRHelper loadImage:@"http://www.google.com/" completionHandler:^(NSHTTPURLResponse *response, UIImage *image, NSError *error) {
        STAssertTrue(response.statusCode >= 200, @"status code valid");
        _isFinished = YES;
    }];
}

@end
