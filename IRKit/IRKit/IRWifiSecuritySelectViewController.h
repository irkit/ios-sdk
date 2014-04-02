#import <UIKit/UIKit.h>
#import "IRKeys.h"

@protocol IRWifiSecuritySelectViewControllerDelegate;

@interface IRWifiSecuritySelectViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<IRWifiSecuritySelectViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) enum IRSecurityType selectedSecurityType;

@end

@protocol IRWifiSecuritySelectViewControllerDelegate <NSObject>
@required

- (void)securitySelectviewController:(IRWifiSecuritySelectViewController *)viewController didFinishWithSecurityType:(enum IRSecurityType)securityType;

@end
