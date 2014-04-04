#import <Foundation/Foundation.h>
#import "IRConst.h"
#import "IRPeripherals.h"
#import "IRHelper.h"
#import "IRSignals.h"
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

- (void)save;

@property (nonatomic, readonly) NSUInteger countOfReadyPeripherals;
@property (nonatomic, readonly) IRPeripherals *peripherals;
@property (nonatomic, readonly, copy) NSString *apikey;

@end
