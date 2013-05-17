//
//  IRReceiveViewController.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IRReceiveViewDelegate <NSObject>
@end

@interface IRReceiveViewController : UIViewController

@property (nonatomic, assign) id<IRReceiveViewDelegate> delegate;

@end
