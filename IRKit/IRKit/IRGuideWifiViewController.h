//
//  IRWifiAdhocViewController.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2014/01/05.
//
//

#import <UIKit/UIKit.h>
#import "IRKeys.h"

@protocol IRGuideWifiViewControllerDelegate;

@interface IRGuideWifiViewController : UIViewController

@property (nonatomic, weak) id<IRGuideWifiViewControllerDelegate> delegate;
@property (nonatomic) IRKeys *keys; // passed from IRNewPerpheralViewController

@end

@protocol IRGuideWifiViewControllerDelegate <NSObject>
@required

// Your implementation of this method should dismiss view controller.
- (void)guideWifiViewController:(IRGuideWifiViewController *)viewController didFinishWithInfo:(NSDictionary *)info;

@end
