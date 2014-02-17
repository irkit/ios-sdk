#import <UIKit/UIKit.h>
#import "IRKeys.h"
#import "IRWifiAdhocViewController.h"

@protocol IRMorsePlayerViewControllerDelegate;

@interface IRMorsePlayerViewController : UIViewController

@property (nonatomic, weak) id<IRMorsePlayerViewControllerDelegate, IRWifiAdhocViewControllerDelegate> delegate;
@property (nonatomic) IRKeys *keys; // passed from IRNewPerpheralViewController
@property (nonatomic) BOOL showMorseNotWorkingButton;

@end

@protocol IRMorsePlayerViewControllerDelegate <NSObject>
@required

- (void)morsePlayerViewControllerDidStartPlaying:(IRMorsePlayerViewController *)viewController;

// Your implementation of this method should dismiss view controller.
- (void)morsePlayerViewController:(IRMorsePlayerViewController *)viewController didFinishWithInfo:(NSDictionary *)info;

@end
