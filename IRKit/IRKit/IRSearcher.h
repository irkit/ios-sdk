//
//  IRSearcher.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/11/22.
//
//

#import <Foundation/Foundation.h>

@protocol IRSearcherDelegate;

@interface IRSearcher : NSObject<NSNetServiceBrowserDelegate,NSNetServiceDelegate>

@property (nonatomic, weak) id<IRSearcherDelegate> delegate;

+ (instancetype) sharedInstance;
- (void) start;
- (void) stop;

@end

@protocol IRSearcherDelegate <NSObject>

- (void)searcher:(IRSearcher *)searcher didResolveService:(NSNetService*)service;

@end
