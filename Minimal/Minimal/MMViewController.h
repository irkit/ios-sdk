#import <UIKit/UIKit.h>
#import <IRKit/IRKit.h>

@interface MMViewController : UITableViewController<IRNewPeripheralViewControllerDelegate, IRNewSignalViewControllerDelegate>

@property (nonatomic) IRSignals *signals;
@property (nonatomic) IRPeripheral *peripheral;

@end
