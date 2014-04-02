//  our SDK does not pollute global namespace or objects
//  only classes prefixed with IR*

#define LOG_DISABLED 1
#import "Log.h"
#import "IRHelper.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import <SystemConfiguration/CaptiveNetwork.h>

NSString * IRLocalizedString(NSString *key, NSString *comment) {
    return [[IRHelper resources] localizedStringForKey: key value: key table: nil];
}

@implementation IRHelper

+ (NSArray *)mapObjects:(NSArray *)array usingBlock:(id (^)(id obj, NSUInteger idx))block {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity: [array count]];

    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject: block(obj, idx)];
    }];
    return result;
}

+ (NSBundle *)resources {
    NSBundle *main      = [NSBundle mainBundle];
    NSBundle *resources = [NSBundle bundleWithPath: [main pathForResource: @"IRKit"
                                                                   ofType: @"bundle"]];

    return resources;
}

#pragma mark - Network related

// thanks to http://stackoverflow.com/questions/6807788/how-to-get-ip-address-of-iphone-programatically
+ (NSString *)localIPAddress {
    NSString *address          = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr  = NULL;
    int success                = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String: temp_addr->ifa_name] isEqualToString: @"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String: inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

#if TARGET_OS_IPHONE
// thanks to http://stackoverflow.com/a/15236634/105194
+ (NSString *)currentWifiSSID {
    // Does not work on the simulator.
    NSString *ssid = nil;
    NSArray *ifs   = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        LOG( @"info: %@", info );
        if (info[@"SSID"]) {
            ssid = info[@"SSID"];
        }
    }
    return ssid;
}
#endif // TARGET_OS_IPHONE

@end
