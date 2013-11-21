#import <UIKit/UIKit.h>
#import "IRKeys.h"

@protocol IRMorsePlayerViewControllerDelegate;

@interface IRMorsePlayerViewController : UIViewController

@property (nonatomic, assign) id<IRMorsePlayerViewControllerDelegate> delegate;
@property (nonatomic) IRKeys *keys;

@end

@protocol IRMorsePlayerViewControllerDelegate <NSObject>
@required

// Your implementation of this method should dismiss view controller.
- (void)morsePlayerViewController:(IRMorsePlayerViewController *)viewController didFinishWithInfo:(NSDictionary*)info;

@end
