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
    [super viewDidAppear:YES];

    if ([IRKit sharedInstance].numberOfPeripherals == 0) {
        IRNewPeripheralViewController* c = [[IRNewPeripheralViewController alloc] init];
        c.delegate = (id<IRNewPeripheralViewControllerDelegate>)self;
        [self presentViewController:c animated:YES completion:^{
            LOG( @"presented" );
        }];
    }
}

- (IBAction)addBarButtonPressed:(id)sender {
    LOG_CURRENT_METHOD;
    
    IRNewPeripheralViewController* c = [[IRNewPeripheralViewController alloc] init];
    c.delegate = (id<IRNewPeripheralViewControllerDelegate>)self;
    [self presentViewController:c animated:YES completion:^{
        LOG( @"presented" );
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark IRNewPeripheralViewControllerDelegate

- (void)newPeripheralViewController:(IRReceiveViewController *)viewController
                  didFinishWithInfo:(NSDictionary*)info {
    LOG( @"result: %@", info );
 
    [self dismissViewControllerAnimated:YES completion:^{
        LOG(@"dismissed");
    }];
}


@end
