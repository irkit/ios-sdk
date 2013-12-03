#import "Log.h"
#import "IRPeripheralWriteOperation.h"
#import "IRConst.h"
#import "IRHelper.h"

@interface IRPeripheralWriteOperation ()

@property BOOL isExecuting;
@property BOOL isFinished;

@property (nonatomic) IRPeripheral *peripheral;
@property (nonatomic) NSData *data;
//@property (nonatomic) CBUUID *characteristicUUID;
//@property (nonatomic) CBUUID *serviceUUID;
@property (nonatomic, copy) void (^completion)(NSError *error);

@end

@implementation IRPeripheralWriteOperation

- (void) start {
    LOG_CURRENT_METHOD;
    
    self.isExecuting = YES;
    self.isFinished  = NO;

    if ( ! _peripheral.hasKey ) {
        // should be connected when started
        dispatch_async( dispatch_get_main_queue(),
                       ^{
                           NSError *error = [NSError errorWithDomain:IRKitErrorDomain
                                                                code:IRKIT_ERROR_CODE_DISCONNECTED
                                                            userInfo:nil];
                           _completion( error );
                           self.isExecuting = NO;
                           self.isFinished  = YES;
                       });
        return;
    }

//    BOOL wrote = [_peripheral writeValue:_data
//               forCharacteristicWithUUID:_characteristicUUID
//                       ofServiceWithUUID:_serviceUUID];
//    if (wrote) {
//        return;
//    }
//    dispatch_async( dispatch_get_main_queue(), ^{
//        LOG( @"not found service: %@ c12c: %@", _serviceUUID, _characteristicUUID );
//        NSError *error = [NSError errorWithDomain:IRKIT_ERROR_DOMAIN
//                                             code:IRKIT_ERROR_CODE_C12C_NOT_FOUND
//                                         userInfo:nil];
//        _completion( error );
//        self.isExecuting = NO;
//        self.isFinished  = YES;
//    });
}

//- (void) didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
//                                  error:(NSError *)error {
//    LOG_CURRENT_METHOD;
//    dispatch_async( dispatch_get_main_queue(), ^{
//        _completion( error );
//        self.isExecuting = NO;
//        self.isFinished  = YES;
//    });
//}
//
//+ (IRPeripheralWriteOperation*) operationToPeripheral:(IRPeripheral*) peripheral
//                                   withData:(NSData*)data
//                  forCharacteristicWithUUID:(CBUUID*)characteristicUUID
//                          ofServiceWithUUID:(CBUUID*)serviceUUID
//                                 completion:(void (^)(NSError *error))completion {
//    LOG_CURRENT_METHOD;
//    IRPeripheralWriteOperation *op = [[IRPeripheralWriteOperation alloc] init];
//    op.peripheral         = peripheral;
//    op.data               = data;
//    op.characteristicUUID = characteristicUUID;
//    op.serviceUUID        = serviceUUID;
//    op.completion         = completion;
//    return op;
//}

#pragma mark - KVO

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    if ([key isEqualToString:@"isExecuting"] || [key isEqualToString:@"isFinished"]) {
        return YES;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}

- (BOOL)isConcurrent
{
    return NO;
}

@end
