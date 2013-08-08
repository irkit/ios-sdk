// IRPeripheral stores additional info related to CBPeripheral

#import <Foundation/Foundation.h>

@interface IRPeripheral : NSObject<CBPeripheralDelegate>

// can be nil if CBPeripheral is found but UUID isn't,
// or loaded from NSUserDefaults but CBPeripheral not retrieved yet.
@property (nonatomic) CFUUIDRef UUID;
@property (nonatomic, copy) NSString *customizedName;
@property (nonatomic, copy) NSDate   *foundDate;
@property (nonatomic) BOOL authorized;

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

- (void) writeValueInBackground: (NSData*)value
      forCharacteristicWithUUID: (CBUUID*)characteristicUUID
              ofServiceWithUUID: (CBUUID*)serviceUUID
                     completion: (void (^)(NSError *error))block;
- (BOOL) writeValue: (NSData*)value
forCharacteristicWithUUID: (CBUUID*)characteristicUUID
  ofServiceWithUUID: (CBUUID*)serviceUUID;

- (NSString*) modelNameAndRevision;
- (NSString*) iconURL;

- (void)setManager: (CBCentralManager*)manager;
- (void)setPeripheral: (CBPeripheral*)peripheral;

@end
