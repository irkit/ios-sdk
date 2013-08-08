//  our SDK does not pollute global namespace or objects
//  only classes prefixed with IR*

#define LOG_DISABLED 1
#import "Log.h"
#import "IRHelper.h"
#import <CommonCrypto/CommonDigest.h>

@implementation IRHelper

+ (NSArray *)mapObjects:(NSArray *)array usingBlock:(id (^)(id obj, NSUInteger idx))block {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[array count]];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject:block(obj, idx)];
    }];
    return result;
}

// array of short values
+ (NSString*) sha1:(NSArray*) array {
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];

    CC_SHA1_CTX ctx;
    CC_SHA1_Init(&ctx);
    for (size_t i = 0; i < array.count; i++) {
        uint16_t val = [array[i] shortValue];
        CC_SHA1_Update(&ctx, &val, sizeof(uint16_t));
    }
    CC_SHA1_Final(digest, &ctx);

    NSString *s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",digest[0], digest[1], digest[2], digest[3], digest[4], digest[5], digest[6], digest[7], digest[8], digest[9], digest[10], digest[11], digest[12], digest[13], digest[14], digest[15], digest[16], digest[17], digest[18], digest[19]];
    return s;
}

#pragma mark - View related

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

+ (UIImage *)imageInResourceNamed:(NSString*)name {
    NSBundle *main = [NSBundle mainBundle];
    NSBundle *resources = [NSBundle bundleWithPath:[main pathForResource:@"IRKitResources"
                                                                  ofType:@"bundle"]];
    return [UIImage imageWithContentsOfFile:[resources pathForResource:name
                                                                ofType:@"png"]];
}

#pragma mark - UUID related

+ (NSString*)stringFromCFUUID: (CFUUIDRef) uuid {
    if ( ! uuid ) {
        return nil;
    }
    CFStringRef string = CFUUIDCreateString(NULL, uuid);
    return (__bridge_transfer NSString *)string;
}

// CBUUID isEqual only compares pointer
// isEqual is fine if both uuids resides in the same thread
+ (BOOL)CBUUID: (CBUUID*)uuid1 isEqualToCBUUID: (CBUUID*)uuid2 {
    return [uuid1.data isEqualToData:uuid2.data];
}

#pragma mark - CoreBluetooth related

+ (CBService*)findServiceInPeripheral:(CBPeripheral*)peripheral withUUID:(CBUUID*)serviceUUID {
    LOG_CURRENT_METHOD;

    for (CBService *service in peripheral.services) {
        if (! [IRHelper CBUUID:service.UUID isEqualToCBUUID:serviceUUID]) {
            continue;
        }
        return service;
    }
    return nil;
}

+ (CBCharacteristic*)findCharacteristicInPeripheral:(CBPeripheral*)peripheral withCBUUID:(CBUUID*)uuid {
    LOG_CURRENT_METHOD;

    for (CBService *service in peripheral.services) {
        for (CBCharacteristic *c12c in service.characteristics) {
            if ([IRHelper CBUUID:c12c.UUID isEqualToCBUUID:uuid]) {
                return c12c;
            }
        }
    }
    return nil;
}

+ (CBCharacteristic*)findCharacteristicInService:(CBService*)service
                                      withCBUUID:(CBUUID*)characteristicUUID {
    LOG_CURRENT_METHOD;
    for (CBCharacteristic *c12c in service.characteristics) {
        if (! [IRHelper CBUUID:c12c.UUID isEqualToCBUUID:characteristicUUID]) {
            continue;
        }
        return c12c;
    }
    return nil;
}

+ (CBCharacteristic*)findCharacteristicInPeripheral:(CBPeripheral*)peripheral
                                         withCBUUID:(CBUUID*)characteristicUUID
                                inServiceWithCBUUID:(CBUUID*)serviceUUID {
    LOG_CURRENT_METHOD;

    CBService *service = [self findServiceInPeripheral:peripheral withUUID:serviceUUID];
    return [self findCharacteristicInService:service withCBUUID:characteristicUUID];
}

+ (CBCharacteristic*)findCharacteristicInSameServiceWithCharacteristic:(CBCharacteristic*)characteristic
                                                            withCBUUID:(CBUUID*)uuid {
    LOG_CURRENT_METHOD;

    CBService *service = characteristic.service;
    if ( ! service ) {
        return nil;
    }
    return [self findCharacteristicInService:service withCBUUID:uuid];
}

#pragma mark - Network related

+ (void)loadImage:(NSString*)url
completionHandler:(void (^)(NSHTTPURLResponse *response, UIImage *image, NSError *error)) handler {
    LOG_CURRENT_METHOD;

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *res, NSData *data, NSError *error) {
                               UIImage *ret;
                               if (! error) {
                                   ret = [UIImage imageWithData:data];
                               }
                               if (! handler) {
                                   return;
                               }
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   handler((NSHTTPURLResponse*)res,ret,error);
                               });
                           }];
}

@end
