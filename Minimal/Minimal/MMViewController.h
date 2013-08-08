#import <UIKit/UIKit.h>
#import <IRKit/IRKit.h>

@interface MMViewController : UIViewController<IRNewPeripheralViewControllerDelegate, IRNewSignalViewControllerDelegate>

@property (nonatomic) NSMutableArray *signals; // of IRSignal

@property (nonatomic) IRPeripheral *peripheral;

@end
