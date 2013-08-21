//
//  IRPackerWrapper.mm
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/08/21.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRPackerWrapper.h"
#import "IrPacker.h"
#import "Log.h"

struct IRPackerOpaque {
public:
    IRPackerOpaque() {};
    IrPacker wrapped;
};

@interface IRPackerWrapper ()

@end

@implementation IRPackerWrapper

- (id)init {
    LOG_CURRENT_METHOD;
    self = [super init];
    if (self != nil) {
        _cpp = new IRPackerOpaque();
    }
    return self;
}

- (void)dealloc {
    LOG_CURRENT_METHOD;
    delete _cpp;
    _cpp = NULL;
}

- (NSData*) packData: (NSData*)data {
    uint8_t packed[512] = { 0 };
    // Pack's 3rd argument is: number of uint16_t
    uint16_t length = _cpp->wrapped.Pack((const uint16_t *)data.bytes, packed, data.length/2);
    return [NSData dataWithBytes:packed length:length];
}

@end
