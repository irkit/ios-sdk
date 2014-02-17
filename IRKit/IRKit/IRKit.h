#import <Foundation/Foundation.h>
#import "IRConst.h"
#import "IRPeripherals.h"
#import "IRHelper.h"
#import "IRNewPeripheralViewController.h"
#import "IRNewSignalViewController.h"
#import "IRSignals.h"
#import "IRViewCustomizer.h"

@interface IRKit : NSObject

+ (instancetype)sharedInstance;
+ (void)startWithAPIKey:(NSString *)apikey;

- (void)save;

@property (nonatomic, readonly) NSUInteger countOfReadyPeripherals;
@property (nonatomic, readonly) IRPeripherals *peripherals;
@property (nonatomic, readonly, copy) NSString *apikey;

@end
