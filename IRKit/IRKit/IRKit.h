#import <Foundation/Foundation.h>
#import "IRConst.h"
#import "IRPeripherals.h"
#import "IRHelper.h"
#import "IRSignals.h"
#import "IRSignalSequence.h"
#import "IRPersistentStore.h"
#if TARGET_OS_IPHONE
# import "IRPeripheralCell.h"
# import "IRPeripherals+UIKit.h"
# import "IRNewPeripheralViewController.h"
# import "IRNewSignalViewController.h"
# import "IRViewCustomizer.h"
#endif

@interface IRKit : NSObject

+ (instancetype)sharedInstance;
+ (void)startWithAPIKey:(NSString *)apikey;

/// call before startWithAPIKey,
/// to save clientkey and peripherals information into somewhere else than NSUserDefaults
+ (void)setPersistentStore:(id<IRPersistentStore>)store;

- (void)save;

@property (nonatomic, readonly) NSUInteger countOfReadyPeripherals;
@property (nonatomic, readonly) IRPeripherals *peripherals;
@property (nonatomic, readonly, copy) NSString *apikey;
@property (nonatomic, copy) NSString *clientkey; // TODO readonly
@property (nonatomic) id<IRPersistentStore> store;

@end
