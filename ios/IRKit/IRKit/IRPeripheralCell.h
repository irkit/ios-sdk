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
+ (CGFloat)height;

@property (nonatomic, strong) IRPeripheral *peripheral;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@end
