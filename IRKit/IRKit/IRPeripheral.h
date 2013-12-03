// IRPeripheral is a IRKit device representation
#import <Foundation/Foundation.h>

@interface IRPeripheral : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *customizedName;
@property (nonatomic, copy) NSDate   *foundDate;
@property (nonatomic, copy) NSString *key;

@property (nonatomic, copy) NSString *modelName;
@property (nonatomic, copy) NSString *version;

@property (nonatomic) BOOL canResolve;

- (BOOL) hasKey;
- (BOOL) isReachableViaWifi;
- (void)getKeyWithCompletion:(void (^)())successfulCompletion;
- (void)getModelNameAndVersionWithCompletion:(void (^)())successfulCompletion;
- (NSComparisonResult) compareByFirstFoundDate: (IRPeripheral*) otherPeripheral;

- (NSString*) iconURL;
- (NSString*) modelNameAndRevision;

@end
