#import <UIKit/UIKit.h>
#import "IRPeripheral.h"
#import "IRWifiSecuritySelectViewController.h"

@protocol IRWifiEditViewControllerDelegate;

@interface IRWifiEditViewController : UIViewController<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, IRWifiSecuritySelectViewControllerDelegate>

@property (nonatomic, assign) id<IRWifiEditViewControllerDelegate> delegate;
@property (nonatomic) IRPeripheral *peripheral;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//@property (weak, nonatomic) IBOutlet UITextField *ssidField;
//@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@end

@protocol IRWifiEditViewControllerDelegate <NSObject>
@required

// Your implementation of this method should dismiss view controller.
- (void)wifiEditViewController:(IRWifiEditViewController *)viewController didFinishWithInfo:(NSDictionary*)info;

@end
