#import <Foundation/Foundation.h>
#import "IRConst.h"
#import "IRNewPeripheralViewController.h"
#import "IRNewSignalViewController.h"
#import "IRPeripherals.h"
#import "IRSignals.h"
#import "IRSignal.h"
#import "IRHelper.h"
#import "IRViewCustomizer.h"

@interface IRKit : NSObject

+ (instancetype) sharedInstance;
+ (void) startWithAPIKey: (NSString*)apikey;

- (void) save;

@property (nonatomic, readonly) NSUInteger countOfReadyPeripherals;
@property (nonatomic, readonly) NSUInteger countOfPeripherals;
@property (nonatomic) IRPeripherals *peripherals;
@property (nonatomic, readonly, copy) NSString *apikey;

@end
