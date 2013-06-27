//
//  IRSignalCell.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRSignalCell.h"
#import "IRChartView.h"

@interface IRSignalCell ()

@property (nonatomic, strong) IRChartView *chartView;

@end

@implementation IRSignalCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    LOG_CURRENT_METHOD;
    
    self = [super initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

        CGRect cellFrame = self.frame;
        
        // image
        self.imageView.image = [UIImage imageNamed:@"kayac_logo.jpg"];
        
        // text label
        self.textLabel.text = @"signal 1";
        
        int margin = 20;
        int height = 200;
        self.chartView = [[IRChartView alloc] initWithFrame: (CGRect){ margin, margin, 300 - margin*2, height - margin*2 }];
        [self.contentView addSubview: self.chartView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setSignal:(IRSignal *)signal {
    LOG( @"signal: %@", signal);
    
    self.textLabel.text = signal.name;
    self.detailTextLabel.text = signal.name;
    self.chartView.data = signal.data;
}

+ (CGFloat)height {
    return 200;
}

@end
