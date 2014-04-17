//
//  IRSearcher.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/11/22.
//
//

#import <Foundation/Foundation.h>

@protocol IRSearcherDelegate;

@interface IRSearcher : NSObject<NSNetServiceBrowserDelegate, NSNetServiceDelegate>

@property (nonatomic, weak) id<IRSearcherDelegate> delegate;

+ (instancetype)sharedInstance;
- (void)startSearching;
- (void)startSearchingForTimeInterval:(NSTimeInterval)interval;
- (void)startSearchingAfterTimeInterval:(NSTimeInterval)waitInterval forTimeInterval:(NSTimeInterval)interval;
- (void)stop;

@end

@protocol IRSearcherDelegate <NSObject>

@required
- (void)searcherWillStartSearching:(IRSearcher*)searcher;
- (void)searcher:(IRSearcher *)searcher didResolveService:(NSNetService *)service;
- (void)searcherDidTimeout:(IRSearcher *)searcher;

@end
