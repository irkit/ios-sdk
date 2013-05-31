//
//  IRPeripheralCell.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRPeripheral.h"

@interface IRPeripheralCell : UITableViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, strong) IRPeripheral *peripheral;

@end
