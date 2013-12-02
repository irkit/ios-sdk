//
//  IRHTTPJSONOperation.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/12/02.
//
//

#import "IRHTTPJSONOperation.h"
#import "Log.h"

@implementation IRHTTPJSONOperation

- (id)processData:(NSData *)data {
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data
                                                options:NSJSONReadingAllowFragments
                                                  error:&error];
    if (error) {
        LOG(@"JSON error: %@", error);
    }
    return object;
}

@end
