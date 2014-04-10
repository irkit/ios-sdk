//
//  IRFAQViewController.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2014/04/10.
//
//

#import "IRFAQViewController.h"
#import "Log.h"
#import "IRConst.h"
#import "IRHelper.h"
#import "IRViewCustomizer.h"

@interface IRFAQViewController ()

@end

@implementation IRFAQViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title             = IRLocalizedString(@"FAQ", @"title of IRFAQViewController");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                                                                          target: self
                                                                                          action: @selector(cancelButtonPressed:)];

    [IRViewCustomizer sharedInstance].viewDidLoad(self);

    UIWebView *webView = (UIWebView*)self.view;
    NSURL *url         = [NSURL URLWithString: @"/faq" relativeToURL: [NSURL URLWithString: STATICENDPOINT_BASE]];
    [webView loadRequest: [NSURLRequest requestWithURL: url]];
}

- (void)cancelButtonPressed:(id)sender {
    [self.delegate faqViewControllerDidFinish: self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
