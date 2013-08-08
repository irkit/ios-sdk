#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface IRPeripheralWriteOperationQueue : NSOperationQueue

- (void) didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
                                  error:(NSError *)error;

@end
