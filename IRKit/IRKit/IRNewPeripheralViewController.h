#import <UIKit/UIKit.h>
#import "IRNewPeripheralScene1ViewController.h"
#import "IRNewPeripheralScene2ViewController.h"
#import "IRWifiEditViewController.h"
#import "IRPeripheralNameEditViewController.h"
#import "IRMorsePlayerViewController.h"
#import "IRSearcher.h"

// pre definition for delegate
@protocol IRNewPeripheralViewControllerDelegate;

@interface IRNewPeripheralViewController : UIViewController<
IRNewPeripheralScene1ViewControllerDelegate,
IRNewPeripheralScene2ViewControllerDelegate,
IRWifiEditViewControllerDelegate,
IRMorsePlayerViewControllerDelegate,
IRPeripheralNameEditViewControllerDelegate,
IRSearcherDelegate,
UIAlertViewDelegate>

@property (nonatomic, weak) id<IRNewPeripheralViewControllerDelegate> delegate;

@end

@protocol IRNewPeripheralViewControllerDelegate <NSObject>

@required

// Your implementation of this method should dismiss view controller.
- (void)newPeripheralViewController:(IRNewPeripheralViewController*)viewController didFinishWithPeripheral:(IRPeripheral*)peripheral;

@end
