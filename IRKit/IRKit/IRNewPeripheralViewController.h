#import <UIKit/UIKit.h>
#import "IRGuidePowerViewController.h"
#import "IRWifiEditViewController.h"
#import "IRPeripheralNameEditViewController.h"
#import "IRGuideWifiViewController.h"
#import "IRSearcher.h"

// pre definition for delegate
@protocol IRNewPeripheralViewControllerDelegate;

@interface IRNewPeripheralViewController : UIViewController<
        IRGuidePowerViewControllerDelegate,
        IRWifiEditViewControllerDelegate,
        IRGuideWifiViewControllerDelegate,
        IRPeripheralNameEditViewControllerDelegate,
        IRSearcherDelegate,
        UIAlertViewDelegate>

@property (nonatomic, weak) id<IRNewPeripheralViewControllerDelegate> delegate;
@property (nonatomic) UINavigationController *navController;

@end

@protocol IRNewPeripheralViewControllerDelegate <NSObject>

@required

// Your implementation of this method should dismiss view controller.
- (void)newPeripheralViewController:(IRNewPeripheralViewController *)viewController didFinishWithPeripheral:(IRPeripheral *)peripheral;

@end
