//
//  IRSearcher.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/11/22.
//
//

#import "Log.h"
#import "IRSearcher.h"

@interface IRSearcher ()

@property (nonatomic) NSNetServiceBrowser *browser;
@property (nonatomic) NSMutableSet *services;
@property (nonatomic) NSTimer *timeoutTimer;
@property (nonatomic) NSTimer *waitTimer;
@property (nonatomic) NSTimeInterval searchInterval;

@end

@implementation IRSearcher

+ (instancetype)sharedInstance {
    static IRSearcher *queue = nil;
    static dispatch_once_t once;

    dispatch_once(&once, ^{
        queue = [[IRSearcher alloc] init];
    });
    return queue;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    _browser          = [[NSNetServiceBrowser alloc] init];
    _browser.delegate = self;

    _services = [[NSMutableSet alloc] init];

    return self;
}

- (void)startSearching {
    LOG_CURRENT_METHOD;

    [self stop];
    _searching = YES;

    if ([_delegate respondsToSelector: @selector(searcherWillStartSearching:)]) {
        [_delegate searcherWillStartSearching: self];
    }
    [_browser searchForServicesOfType: @"_irkit._tcp" inDomain: @""];
}

- (void)startSearchingForTimeInterval:(NSTimeInterval)interval {
    LOG(@"interval: %.1f", interval);

    _searching = YES;

    if ([_delegate respondsToSelector: @selector(searcherWillStartSearching:)]) {
        [_delegate searcherWillStartSearching: self];
    }
    [_browser searchForServicesOfType: @"_irkit._tcp" inDomain: @""];
    [_timeoutTimer invalidate];
    _timeoutTimer = [NSTimer timerWithTimeInterval: interval
                                            target: self
                                          selector: @selector(timeout:)
                                          userInfo: nil
                                           repeats: NO];
    [[NSRunLoop currentRunLoop] addTimer: _timeoutTimer forMode: NSRunLoopCommonModes];
}

- (void)startSearchingAfterTimeInterval:(NSTimeInterval)waitInterval forTimeInterval:(NSTimeInterval)interval {
    LOG(@"waitInterval: %1.f interval: %.1f", waitInterval, interval);

    [_waitTimer invalidate];
    _waitTimer = [NSTimer timerWithTimeInterval: waitInterval
                                         target: self
                                       selector: @selector(waitTimeout:)
                                       userInfo: nil
                                        repeats: NO];
    _searchInterval = interval;
    [[NSRunLoop currentRunLoop] addTimer: _waitTimer forMode: NSRunLoopCommonModes];
}

- (void)stop {
    _searching = NO;
    [_browser stop];
    [_timeoutTimer invalidate];
    _timeoutTimer = nil;
    [_waitTimer invalidate];
    _waitTimer = nil;
}

#pragma mark - Private

- (void)resolveServices {
    LOG_CURRENT_METHOD;

    [[_services allObjects] enumerateObjectsUsingBlock:^(NSNetService *service, NSUInteger idx, BOOL *stop) {
        service.delegate = self;
        [service resolveWithTimeout: 0];
    }];
}

- (void)timeout:(NSTimer*)timer {
    LOG_CURRENT_METHOD;

    [self stop];
    if ([_delegate respondsToSelector: @selector(searcherDidTimeout:)]) {
        [_delegate searcherDidTimeout: self];
    }
}

- (void)waitTimeout:(NSTimer*)timer {
    LOG_CURRENT_METHOD;

    [_waitTimer invalidate];
    _waitTimer = nil;
    [self startSearchingForTimeInterval: _searchInterval];
}

- (NSString *)copyStringFromTXTDict:(NSDictionary *)dict which:(NSString *)which {
    // Helper for getting information from the TXT data
    NSData *data           = [dict objectForKey: which];
    NSString *resultString = nil;

    if (data) {
        resultString = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    }
    return resultString;
}

#pragma mark - NSNetServiceDelegate

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    LOG_CURRENT_METHOD;
    [_services removeObject: sender];

    LOG(@"hostName: %@", sender.hostName);

    if (_delegate) {
        [_delegate searcher: self didResolveService: sender];
    }
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    LOG(@"errorDict:%@", errorDict);
    [_services removeObject: sender];
}

#pragma mark - NSNetServiceBrowserDelegate

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindDomain:(NSString *)domainName moreComing:(BOOL)moreDomainsComing {
    LOG_CURRENT_METHOD;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing {
    LOG_CURRENT_METHOD;

    [_services addObject: netService];

    if (!moreServicesComing) {
        [self resolveServices];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didNotSearch:(NSDictionary *)errorInfo {
    LOG_CURRENT_METHOD;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didRemoveDomain:(NSString *)domainName moreComing:(BOOL)moreDomainsComing {
    LOG_CURRENT_METHOD;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didRemoveService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing {
    LOG_CURRENT_METHOD;
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)netServiceBrowser {
    LOG_CURRENT_METHOD;
}

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)netServiceBrowser {
    LOG_CURRENT_METHOD;
}

@end
