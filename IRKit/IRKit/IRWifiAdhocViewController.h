//
//  IRWifiAdhocViewController.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2014/01/05.
//
//

#import <UIKit/UIKit.h>
#import "IRKeys.h"

@protocol IRWifiAdhocViewControllerDelegate;

@interface IRWifiAdhocViewController : UIViewController

@property (nonatomic, weak) id<IRWifiAdhocViewControllerDelegate> delegate;
@property (nonatomic) IRKeys *keys; // passed from IRNewPerpheralViewController

@end

@protocol IRWifiAdhocViewControllerDelegate <NSObject>
@required

// Your implementation of this method should dismiss view controller.
- (void)wifiAdhocViewController:(IRWifiAdhocViewController *)viewController didFinishWithInfo:(NSDictionary*)info;

@end
