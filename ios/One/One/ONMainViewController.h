#import <IRKit/IRKit.h>
#import "ONImagePickerViewController.h"

@interface ONMainViewController : UITableViewController <IRNewPeripheralViewControllerDelegate,
    IRNewSignalViewControllerDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    IRAnimatingControllerDelegate,
    ONImagePickerViewControllerDelegate>

@property (nonatomic) IRSignals *signals;

@end
