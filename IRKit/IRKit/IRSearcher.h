//
//  IRSearcher.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/11/22.
//
//

#import <Foundation/Foundation.h>

@interface IRSearcher : NSObject<NSNetServiceBrowserDelegate,NSNetServiceDelegate>

- (void) start;
- (void) stop;

@end
