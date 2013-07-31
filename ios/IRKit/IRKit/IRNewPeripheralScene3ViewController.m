//
//  IRNewPeripheralScene3ViewController.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRNewPeripheralScene3ViewController.h"
#import "IRConst.h"
#import "IRViewCustomizer.h"

@interface IRNewPeripheralScene3ViewController ()

@end

@implementation IRNewPeripheralScene3ViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    LOG_CURRENT_METHOD;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];

    [IRViewCustomizer sharedInstance].viewDidLoad(self);
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
    
    [self.delegate scene3ViewController:self
                      didFinishWithInfo:@{
        IRViewControllerResultType: IRViewControllerResultTypeDone,
        IRViewControllerResultText: _textField.text
     }];
}

#pragma mark - UI events

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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [self processTextField];
    return NO;
}

@end
