//
//  SRMainViewController.m
//  SimpleRemote
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "SRMainViewController.h"

@interface SRMainViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBarButtonItem;

@end

@implementation SRMainViewController

- (void)viewDidLoad
{
    LOG_CURRENT_METHOD;
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    
    if ([IRKit sharedInstance].numberOfPeripherals == 0) {
        //[self addBarButtonPressed: nil];
        IRNewPeripheralViewController* c = [[IRNewPeripheralViewController alloc] init];
        c.delegate = self;
        [self presentViewController:c animated:YES completion:^{
            LOG( @"presented" );
        }];
    }
}

- (IBAction)addBarButtonPressed:(id)sender {
    LOG_CURRENT_METHOD;
    
//    IRReceiveViewController* receiver = [[IRReceiveViewController alloc] init];
//    receiver.delegate = self;
//    [self presentViewController:receiver animated:YES completion:^{
//        LOG( @"presented" );
//    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark IRReceiveViewDelegate

- (void)receiveViewControllerDidFinish:(IRReceiveViewController *)viewController {
    LOG_CURRENT_METHOD;
    
}

#pragma mark -
#pragma mark IRNewPeripheralViewControllerDelegate

- (void)newPeripheralViewControllerDidFinish:(IRReceiveViewController *)viewController {
    LOG_CURRENT_METHOD;
    
}


@end
