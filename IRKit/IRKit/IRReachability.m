//
//  IRReachability.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2014/03/17.
//
//

#import "IRReachability.h"
#import "Log.h"
#import <SystemConfiguration/SystemConfiguration.h>

@interface IRReachability ()

@property (nonatomic) SCNetworkReachabilityRef reachability;
@property (nonatomic) dispatch_queue_t reachabilityQueue;
@property (nonatomic) SCNetworkReachabilityFlags flags;
@property (nonatomic, copy) NSString *hostname;

@end

@implementation IRReachability

static void NetworkReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info){
    IRReachability *_self = (__bridge IRReachability *)info;
    _self.flags = flags;

    LOG( @"reachability for host:%@ %@", _self.hostname, NSStringFromNetworkReachabilityFlags(flags) );
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"
static NSString *NSStringFromNetworkReachabilityFlags(SCNetworkReachabilityFlags flags) {
#pragma clang diagnostic pop
    return [NSString stringWithFormat: @"Reachability Flag Status: %c%c %c%c%c%c%c%c%c",
#if TARGET_OS_IPHONE
            (flags & kSCNetworkReachabilityFlagsIsWWAN)               ? 'W' : '-',
#else
            '-',
#endif
            (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
            (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
            (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
            (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
            (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-'
    ];
}

- (instancetype) initWithReachability: (SCNetworkReachabilityRef)reachability {
    self = [super init];
    if (!self) { return nil; }

    self.reachability = reachability;

    return self;
}

- (void)dealloc {
    LOG_CURRENT_METHOD;

    [self stopMonitoring];

    if (_reachability) {
        CFRelease(_reachability);
        _reachability = NULL;
    }
}

- (void) startMonitoring {
    SCNetworkReachabilityContext context = {
        0,
        (__bridge void *)(self),
        NULL,
        NULL,
        NULL
    };

    if (!SCNetworkReachabilitySetCallback(_reachability, NetworkReachabilityCallback, &context)) {
        LOG(@"SCNetworkReachabilitySetCallback() failed with error code: %s", SCErrorString(SCError()));
        return;
    }

    [self createReachabilityQueue];
}

- (void)createReachabilityQueue {
    _reachabilityQueue = dispatch_queue_create("com.getirkit.reachability.queue", DISPATCH_QUEUE_SERIAL);

    if (!SCNetworkReachabilitySetDispatchQueue(_reachability, _reachabilityQueue)) {
        LOG(@"SCNetworkReachabilitySetDispatchQueue() failed with error code: %s", SCErrorString(SCError()));
        [self releaseReachabilityQueue];
    }
}

- (void)releaseReachabilityQueue {
    if (_reachability) {
        SCNetworkReachabilitySetDispatchQueue(_reachability, NULL);
    }

    if (_reachabilityQueue) {
        _reachabilityQueue = NULL;
    }
}

- (void) stopMonitoring {
    if (_reachability) {
        SCNetworkReachabilitySetCallback(_reachability, NULL, NULL);
    }
    [self releaseReachabilityQueue];
}

+ (instancetype) reachabilityWithHostname: (NSString*)hostname {
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithName(NULL, [hostname UTF8String]);

    // implicitly monitor reachability, to respond with correct results synchronously
    IRReachability *instance = [[IRReachability alloc] initWithReachability: ref];
    instance.hostname = hostname;
    [instance startMonitoring];
    return instance;
}

-(BOOL)isReachableViaWiFi {
    // reachable and not on WWAN
    return (_flags & kSCNetworkReachabilityFlagsReachable) &&
#if TARGET_OS_IPHONE
           !(_flags & kSCNetworkReachabilityFlagsIsWWAN);
#else
           1;
#endif
}

-(BOOL)isReachableViaWiFiAndDirect {
    // reachable, direct and not on WWAN
    return (_flags & kSCNetworkReachabilityFlagsReachable) &&
           (_flags & kSCNetworkReachabilityFlagsIsDirect) &&
#if TARGET_OS_IPHONE
           !(_flags & kSCNetworkReachabilityFlagsIsWWAN);
#else
           1;
#endif
}

@end
