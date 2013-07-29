//
//  IRPeripheralCell.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRPeripheralCell.h"
#import "IRHelper.h"
#import <QuartzCore/QuartzCore.h>

@interface IRPeripheralCell ()

@end

@implementation IRPeripheralCell

- (void)awakeFromNib {
    LOG_CURRENT_METHOD;
    [super awakeFromNib];

    self.iconView.layer.cornerRadius = 6.;
    self.iconView.layer.masksToBounds = YES;
}

- (void)dealloc {
    LOG_CURRENT_METHOD;
    [_peripheral removeObserver:self
                     forKeyPath:@"peripheral"];
}

- (void)setPeripheral:(IRPeripheral *)peripheral {
    LOG( @"peripheral: %@", peripheral);

    _peripheral = peripheral;
    
    self.nameLabel.text = peripheral.customizedName;
    self.detailLabel.text = peripheral.modelNameAndRevision;

    // load image from internet
    NSString *url = @"http://getirkit.appspot.com/static/images/icon.png";
    [IRHelper loadImage:url completionHandler:^(NSHTTPURLResponse *response, UIImage *image, NSError *error) {
        if (error || (response.statusCode != 200) || ! image) {
            return;
        }
        self.iconView.image = image;
    }];

    [_peripheral addObserver:self
                  forKeyPath:@"peripheral"
                     options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                     context:NULL];
}

+ (CGFloat)height {
    return 58;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    LOG( @"keyPath: %@", keyPath );

    self.nameLabel.text = _peripheral.customizedName;
    self.detailLabel.text = _peripheral.modelNameAndRevision;
    [self setNeedsDisplay];
}

@end
