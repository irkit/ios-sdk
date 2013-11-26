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

@end

@implementation IRSearcher

- (instancetype) init {
    self = [super init];
    if (! self) { return nil; }

    _browser = [[NSNetServiceBrowser alloc] init];
    _browser.delegate = self;

    _services = [[NSMutableSet alloc] init];

    return self;
}

- (void) start {
    [_browser searchForServicesOfType:@"_irkit._tcp" inDomain:@""];
}

- (void) stop {
    [_browser stop];
}

#pragma mark - Private

- (void) resolveServices {
    LOG_CURRENT_METHOD;

    [[_services allObjects] enumerateObjectsUsingBlock:^(NSNetService *service, NSUInteger idx, BOOL *stop) {
        service.delegate = self;
        [service resolveWithTimeout:0];
    }];
}

- (NSString *)copyStringFromTXTDict:(NSDictionary *)dict which:(NSString*)which {
	// Helper for getting information from the TXT data
	NSData* data = [dict objectForKey:which];
	NSString *resultString = nil;
	if (data) {
		resultString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	}
	return resultString;
}

#pragma mark - NSNetServiceDelegate

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    LOG_CURRENT_METHOD;
    [_services removeObject:sender];

    LOG( @"hostName: %@", sender.hostName);

    if (_delegate) {
        [_delegate searcher:self didResolveService:sender];
    }
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    LOG(@"errorDict:%@", errorDict);
    [_services removeObject:sender];
}

#pragma mark - NSNetServiceBrowserDelegate

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindDomain:(NSString *)domainName moreComing:(BOOL)moreDomainsComing {
    LOG_CURRENT_METHOD;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing {
    LOG_CURRENT_METHOD;

    [_services addObject: netService];

    if (! moreServicesComing) {
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
