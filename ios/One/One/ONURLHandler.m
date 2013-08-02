//
//  ONURLHandler.m
//  One
//
//  Created by Masakazu Ohtsuka on 2013/07/26.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "ONURLHandler.h"
#import "ONSignals.h"

@implementation ONURLHandler

+(BOOL)canHandleOpenURL: (NSURL*)url {
    LOG_CURRENT_METHOD;

    NSArray *knownSchemes = @[ @"irkit-one" ];
    if ([knownSchemes indexOfObject:url.scheme] == NSNotFound) {
        return NO;
    }

    NSArray *knownHosts = @[ @"send" ];
    if ([knownHosts indexOfObject:url.host] == NSNotFound) {
        return NO;
    }

    return YES;
}

+(void)handleOpenURL:(NSURL *)url {
    LOG( @"url: ", [url absoluteString] );

    IRSignals *signals = [self signalsFromURL:(NSURL*)url];
    ONSignals *instance = [ONSignals sharedInstance];
    instance.signals = signals;
    [instance sendSequentiallyWithCompletion:^(NSError *error) {
        LOG( @"sent error: ", error );
    }];
}

+(NSArray*)signalsDictionariesFromURL:(NSURL*)url {
    LOG_CURRENT_METHOD;
    NSDictionary *queryParameters = [self queryParametersForURL:url];
    NSString *signalsJSON = queryParameters[@"irsignals"];
    if ( ! signalsJSON ) {
        return nil;
    }
    NSString *signalsString = [self urlDecode:signalsJSON];
    NSError *error;
    NSArray *signals = [NSJSONSerialization JSONObjectWithData:[signalsString dataUsingEncoding:NSUTF8StringEncoding]
                                                       options:0
                                                         error:&error];
    return signals;
}

+ (IRSignals*)signalsFromURL:(NSURL*)url {
    LOG_CURRENT_METHOD;

    IRSignals *ret = [[IRSignals alloc] init];

    NSArray *signalDictionaries = [self signalsDictionariesFromURL:url];
    [signalDictionaries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *signalDictionary = (NSDictionary*)obj;
        [ret addSignalsObject:[[IRSignal alloc] initWithDictionary: signalDictionary]];
    }];
    return ret;
}

+ (NSDictionary*)queryParametersForURL:(NSURL*)url {
    NSMutableDictionary *queryParameters = [NSMutableDictionary dictionary];
    for(NSString *keyValuePair in [url.query componentsSeparatedByString: @"&"]) {
        NSArray *keyValue = [keyValuePair componentsSeparatedByString:@"="];
        if (keyValue.count != 2) {
            continue;
        }
        [queryParameters setObject: keyValue[1] forKey: keyValue[0]];
    }
    return queryParameters;
}

+ (NSString*)urlDecode:(NSString*)raw {
    NSString *result = [raw stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    return [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
