//
//  IRSignalLoadingCell.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRSignalLoadingCell.h"

@implementation IRSignalLoadingCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGRect cellFrame = self.frame;
        
        // activity indicator
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityView startAnimating];
        CGRect frame = activityView.frame;
        frame.origin.y = (cellFrame.size.height - activityView.frame.size.height) / 2;
        frame.origin.x = cellFrame.size.width - activityView.frame.size.width - 30;
        activityView.frame = frame;
        [self.contentView addSubview: activityView];
        
        // text label
        frame = self.textLabel.frame;
        frame.origin.x = 40;
        frame.origin.y = 0;
        self.textLabel.frame = frame;
        self.textLabel.text = @"waiting for signal ...";
        self.textLabel.opaque = NO;
        self.textLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
