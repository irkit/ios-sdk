#import <Foundation/Foundation.h>

@interface IRPeripheralWriteOperationQueue : NSOperationQueue

- (void) didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
                                  error:(NSError *)error;

@end
