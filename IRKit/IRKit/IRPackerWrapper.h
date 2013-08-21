//
//  IRPackerWrapper.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/08/21.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

struct IRPackerOpaque;

@interface IRPackerWrapper : NSObject {
    struct IRPackerOpaque *_cpp;
}

- (NSData*) packData: (NSData*)data;

@end
