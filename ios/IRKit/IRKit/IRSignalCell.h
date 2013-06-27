//
//  IRSignalCell.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRSignal.h"

@interface IRSignalCell : UITableViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
+ (CGFloat)height;

@property (nonatomic, strong) IRSignal *signal;

@end
