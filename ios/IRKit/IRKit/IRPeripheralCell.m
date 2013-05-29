//
//  IRPeripheralCell.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRPeripheralCell.h"
#import "IR_ISNetwork.h"

// NSString *url = @"http://placehold.jp/ffffff/ffffff/1x1.png";
static const unsigned char whitePNGImage[] = {
    0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d, 0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1f, 0x15, 0xc4, 0x89, 0x00, 0x00, 0x00, 0x04, 0x73, 0x42, 0x49, 0x54, 0x08, 0x08, 0x08, 0x08, 0x7c, 0x08, 0x64, 0x88, 0x00, 0x00, 0x00, 0x09, 0x70, 0x48, 0x59, 0x73, 0x00, 0x00, 0x0b, 0x89, 0x00, 0x00, 0x0b, 0x89, 0x01, 0x37, 0xc9, 0xcb, 0xad, 0x00, 0x00, 0x00, 0x0d, 0x49, 0x44, 0x41, 0x54, 0x08, 0xd7, 0x63, 0xf8, 0xff, 0xff, 0xff, 0x7f, 0x00, 0x09, 0xfb, 0x03, 0xfd, 0xd1, 0x83, 0x8c, 0xf0, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82 };

@implementation IRPeripheralCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    LOG_CURRENT_METHOD;

    self = [super initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

        // image
        NSData* data = [NSData dataWithBytes:whitePNGImage
                                      length:sizeof(whitePNGImage)];
        self.imageView.image = [UIImage imageWithData:data];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    LOG_CURRENT_METHOD;
    
    self.imageView.frame = (CGRect){ 0., 0., 44., 44. };
    
    CGRect frame = self.textLabel.frame;
    frame.origin.x    = 50.;
    frame.size.width -= 50.;
    self.textLabel.frame = frame;
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

    // load image from internet
    NSString *url = @"http://maaash.jp/lab/irkit/irkit-board.png";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:60.];
    [IR_ISNetworkClient sendRequest:request
                  operationClass:[IR_ISImageNetworkOperation class]
                         handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
                             LOG( @"loaded: %@", response.URL);
                             if (error || response.statusCode != 200) {
                                 return;
                             }
                             self.imageView.image = object;
                         }];

    // TODO: draw graph?
}

@end
