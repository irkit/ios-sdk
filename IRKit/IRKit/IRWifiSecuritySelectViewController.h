#import <UIKit/UIKit.h>
#import "IRPeripheral.h"

NS_ENUM( uint8_t, IRSecurityType ) {
    IRSecurityTypeNone = 0,
    IRSecurityTypeWEP  = 2,
    IRSecurityTypeWPA  = 4,
    IRSecurityTypeWPA2 = 8,
};

@protocol IRWifiSecuritySelectViewControllerDelegate;

@interface IRWifiSecuritySelectViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) id<IRWifiSecuritySelectViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) enum IRSecurityType selectedSecurityType;

@end

@protocol IRWifiSecuritySelectViewControllerDelegate <NSObject>
@required

- (void)securitySelectviewController:(IRWifiSecuritySelectViewController *)viewController didFinishWithSecurityType:(uint8_t)securityType;

@end
