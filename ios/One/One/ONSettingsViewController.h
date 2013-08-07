#import <UIKit/UIKit.h>
#import <IRKit/IRKit.h>

@interface ONSettingsViewController : UITableViewController<IRNewPeripheralViewControllerDelegate,
    IRPeripheralNameEditViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *versionButton;

@end
