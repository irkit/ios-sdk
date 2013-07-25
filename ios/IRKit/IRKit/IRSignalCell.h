//
//  IRSignalCell.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRSignal.h"
#import "IRChartView.h"

@interface IRSignalCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *receivedDateLabel;
@property (weak, nonatomic) IBOutlet IRChartView *signalChartView;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
+ (CGFloat)height;
- (void)inflateFromSignal:(IRSignal*)signal;

@end
