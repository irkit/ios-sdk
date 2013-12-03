#import <Foundation/Foundation.h>
#import "IRConst.h"
#import "IRNewPeripheralViewController.h"
#import "IRNewSignalViewController.h"
#import "IRWebViewController.h"
#import "IRPeripherals.h"
#import "IRSignals.h"
#import "IRSignal.h"
#import "IRChartView.h"
#import "IRHelper.h"
#import "IRViewCustomizer.h"
#import "IRSearcher.h"

@interface IRKit : NSObject<IRSearcherDelegate>

+ (instancetype) sharedInstance;

- (void) startSearch;
- (void) stopSearch;
- (void) save;

@property (nonatomic, readonly) NSUInteger countOfReadyPeripherals;
@property (nonatomic, readonly) NSUInteger countOfPeripherals;
@property (nonatomic) IRPeripherals *peripherals;

@end
