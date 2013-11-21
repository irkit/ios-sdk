// IRPeripheral is a IRKit device representation
#import <Foundation/Foundation.h>

@interface IRPeripheral : NSObject

// can be nil if CBPeripheral is found but UUID isn't,
// or loaded from NSUserDefaults but CBPeripheral not retrieved yet.
@property (nonatomic) CFUUIDRef UUID;
@property (nonatomic, copy) NSString *customizedName;
@property (nonatomic, copy) NSDate   *foundDate;
@property (nonatomic) BOOL authenticated;

@property (nonatomic) NSString *manufacturerName;
@property (nonatomic) NSString *modelName;
@property (nonatomic) NSString *hardwareRevision;
@property (nonatomic) NSString *firmwareRevision;
@property (nonatomic) NSString *softwareRevision;

- (BOOL) isReady;
- (NSComparisonResult) compareByFirstFoundDate: (IRPeripheral*) otherPeripheral;

- (void) didDiscoverWithAdvertisementData:(NSDictionary*)data
                                     RSSI:(NSNumber*)rssi;
- (void) didRetrieve;
- (void) didConnect;
- (void) disconnect;
- (void) didDisconnect;

//- (void) writeValueInBackground: (NSData*)value
//      forCharacteristicWithUUID: (CBUUID*)characteristicUUID
//              ofServiceWithUUID: (CBUUID*)serviceUUID
//                     completion: (void (^)(NSError *error))block;
//- (BOOL) writeValue: (NSData*)value
//forCharacteristicWithUUID: (CBUUID*)characteristicUUID
//  ofServiceWithUUID: (CBUUID*)serviceUUID;
//- (BOOL) readCharacteristicWithUUID:(CBUUID *)characteristicUUID
//                  ofServiceWithUUID:(CBUUID *)serviceUUID;

- (NSString*) modelNameAndRevision;
- (NSString*) iconURL;

//- (void)setManager: (CBCentralManager*)manager;
//- (void)setPeripheral: (CBPeripheral*)peripheral;

- (void)startAuthPolling;
- (void)stopAuthPolling;

@end
