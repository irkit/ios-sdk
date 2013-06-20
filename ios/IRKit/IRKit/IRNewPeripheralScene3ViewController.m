//
//  IRNewPeripheralScene3ViewController.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRNewPeripheralScene3ViewController.h"
#import "IRKit.h"

@interface IRNewPeripheralScene3ViewController ()

@property (nonatomic) UILabel *label;
@property (nonatomic) id observer;
@property (nonatomic) UITextField *textField;

@end

@implementation IRNewPeripheralScene3ViewController

- (void)loadView {
    LOG_CURRENT_METHOD;

    CGRect frame = [[UIScreen mainScreen] bounds];
    LOG(@"frame: %@", NSStringFromCGRect(frame));
    UIView *view = [[UIView alloc] initWithFrame:frame];

    // image
    UIImageView *imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"IRKitResources.bundle/scene3.png"]];
    imageView.frame = frame;
    [view addSubview: imageView];

    // label
    _label = [[UILabel alloc] init];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.opaque        = NO;
    _label.textColor       = [UIColor whiteColor];
    _label.backgroundColor = [UIColor clearColor];
    _label.adjustsFontSizeToFitWidth = YES;
    frame.origin.x = 0;
    frame.origin.y = 50;
    frame.size.height = 30;
    LOG(@"label.frame: %@", NSStringFromCGRect(frame));
    _label.frame = frame;
    [view addSubview:_label];
    
    // input
    _textField = [[UITextField alloc] init];
    _textField.placeholder = @"IRKitの名前";
    _textField.textColor   = [UIColor blackColor];
    _textField.textAlignment = NSTextAlignmentLeft;
    _textField.adjustsFontSizeToFitWidth = YES;
    _textField.borderStyle = UITextBorderStyleLine;
    _textField.backgroundColor = [UIColor whiteColor];
    _textField.returnKeyType = UIReturnKeyDone;
    _textField.delegate = self;
    frame.origin.x = 10;
    frame.origin.y = 130;
    frame.size.width = 300;
    frame.size.height = 30;
    _textField.frame = frame;
    LOG(@"textField.frame: %@", NSStringFromCGRect(frame));
    [view addSubview:_textField];

    self.view = view;
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];

    _label.text = @"IRKitデバイスを認識しました!!! このIRKitに名前をつけてください";
}

- (void) viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillAppear:animated];

    self.title = @"Scene 3";
    self.navigationItem.hidesBackButton    = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
         initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                              target:self
                              action:@selector(doneButtonPressed:)];
}

- (void) viewWillDisappear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillDisappear:animated];
}

- (void) processTextField {
    LOG( @"text: %@", _textField.text );
    
    if (! _textField.text) {
        return;
    }

    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"^\s*$"
                                                       options:nil
                                                         error:nil];
    NSUInteger matches = [regex numberOfMatchesInString:_textField.text
                                                options:nil
                                                  range:NSMakeRange(0,_textField.text.length)];
    
    if (matches > 0) {
        // empty or whitespace only
        return;
    }
    IRPeripheral *peripheral = [[IRKit sharedInstance].peripherals objectAtIndex:0];
    peripheral.customizedName = _textField.text;
    [[IRKit sharedInstance] save];
    
    IRNewPeripheralViewController *c = (IRNewPeripheralViewController*)self.navigationController.delegate;
    [c doneButtonPressed:nil];
}

#pragma mark -
#pragma mark UI events

- (void)didReceiveMemoryWarning
{
    LOG_CURRENT_METHOD;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doneButtonPressed:(id)selector
{
    LOG(@"text: %@", self.textField.text);
    [self processTextField];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [self processTextField];
    return NO;
}

@end
