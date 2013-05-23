//
//  IRPeripheralCell.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRPeripheralCell.h"

@implementation IRPeripheralCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    LOG_CURRENT_METHOD;
    
    self = [super initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

        CGRect cellFrame = self.frame;
        
        // image
        self.imageView.image = [UIImage imageNamed:@"kayac_logo.jpg"];
        
        // text label
        self.textLabel.text = @"peripheral";
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPeripheral:(IRPeripheral *)peripheral {
    LOG( @"peripheral: %@", peripheral);
    
    self.textLabel.text = peripheral.customizedName;
    self.detailTextLabel.text = [peripheral.foundDate description];
    
    // TODO: draw graph?
}

@end
