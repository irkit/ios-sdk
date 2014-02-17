//
//  IRHTTPOperationQueue.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/12/18.
//
//

#import "IRHTTPOperationQueue.h"

@implementation IRHTTPOperationQueue

+ (instancetype)localQueue {
    static IRHTTPOperationQueue *queue = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        queue = [[IRHTTPOperationQueue alloc] init];
    });
    // no multiple concurrent requests agains device
    queue.maxConcurrentOperationCount = 1;

    return queue;
}

@end
