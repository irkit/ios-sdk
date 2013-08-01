//
//  IRViewCustomizer.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/07/31.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRViewCustomizer.h"
#import "IRNewSignalScene1ViewController.h"
#import "IRNewSignalScene2ViewController.h"
#import "IRNewPeripheralScene1ViewController.h"
#import "IRNewPeripheralScene2ViewController.h"
#import "IRNewPeripheralScene3ViewController.h"
#import "IRWebViewController.h"
#import "IRHelper.h"

@implementation IRViewCustomizer

+ (instancetype) sharedInstance {
    static IRViewCustomizer* instance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        instance = [[IRViewCustomizer alloc] init];
    });
    return instance;
}

- (id) init {
    self = [super init];
    if ( ! self ) {
        return nil;
    }

    _viewDidLoad = ^(UIViewController* viewController) {
        
        if ([viewController isKindOfClass:[IRNewSignalScene1ViewController class]] ||
            [viewController isKindOfClass:[IRNewPeripheralScene1ViewController class]]) {
            // bar
            UINavigationBar *bar = viewController.navigationController.navigationBar;
            [IRViewCustomizer customizeNavigationBar:bar];

            // replace cancel button
            UIBarButtonItem *original = viewController.navigationItem.leftBarButtonItem;
            [IRViewCustomizer customizeCancelButton:original
                                  forViewController:viewController
                                     withImageNamed:@"icn_actionbar_cancel"];
        }
        else if ([viewController isKindOfClass:[IRNewPeripheralScene2ViewController class]] ||
                 [viewController isKindOfClass:[IRWebViewController class]]) {
            // bar
            UINavigationBar *bar = viewController.navigationController.navigationBar;
            [IRViewCustomizer customizeNavigationBar:bar];

            // custom back button
            UIBarButtonItem *original = viewController.navigationItem.leftBarButtonItem;
            [IRViewCustomizer customizeCancelButton:original
                                  forViewController:viewController
                                     withImageNamed:@"icn_actionbar_back"];
        }
        else if ([viewController isKindOfClass:[IRNewPeripheralScene3ViewController class]] ||
                 [viewController isKindOfClass:[IRNewSignalScene2ViewController class]]) {
            // bar
            UINavigationBar *bar = viewController.navigationController.navigationBar;
            [IRViewCustomizer customizeNavigationBar:bar];

            // custom done button
            UIBarButtonItem *original = viewController.navigationItem.rightBarButtonItem;

            UIImage *inactiveImage = [IRHelper imageInResourceNamed:@"btn_navibar_disable"];
            UIImage *activeImage   = [IRHelper imageInResourceNamed:@"btn_navibar"];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:@"Done" forState:UIControlStateNormal];
            [button setTitleColor:[IRViewCustomizer activeFontColor] forState:UIControlStateNormal];
            [button setTitleColor:[IRViewCustomizer inactiveFontColor] forState:UIControlStateDisabled];
            button.titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:12.];
            [button setBackgroundImage:inactiveImage
                              forState:UIControlStateDisabled];
            [button setBackgroundImage:activeImage
                              forState:UIControlStateNormal];
            button.frame = (CGRect){ 0, 0, 45, 30 };
            [button setImageEdgeInsets:UIEdgeInsetsMake(0,0,0,0)]; // move the button **px right
            [button addTarget:viewController
                       action:original.action
             forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];

            viewController.navigationItem.rightBarButtonItem = item;
        }
        viewController.view.backgroundColor = [IRViewCustomizer defaultViewBackgroundColor];
    };


    return self;
}

+ (UIColor*) activeFontColor {
    return [UIColor whiteColor];
}

+ (UIColor*) inactiveFontColor {
    return [UIColor colorWithRed:0x79/255. green:0x7a/255. blue:0x80/255. alpha:1.0];
}

+ (UIColor*) inactiveButtonBackgroundColor {
    return [UIColor colorWithRed:0x2b/255. green:0x2d/255. blue:0x33/255. alpha:1.0];
}

+ (UIColor*) activeButtonBackgroundColor {
    return [UIColor colorWithRed:0x00/255. green:0xcc/255. blue:0xcc/255. alpha:1.0];
}

+ (UIColor*) defaultViewBackgroundColor {
    return [UIColor colorWithRed:0x16/255. green:0x16/255. blue:0x1a/255. alpha:1.0];
}

+ (void)customizeCancelButton: (UIBarButtonItem*)original forViewController:(UIViewController*)viewController withImageNamed:(NSString*)name {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[IRHelper imageInResourceNamed:name]
            forState:UIControlStateNormal];
    [button sizeToFit];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0,0,0,-10)]; // move the button **px right
    [button addTarget:viewController
               action:original.action
     forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    viewController.navigationItem.leftBarButtonItem = item;
}

+ (void)customizeNavigationBar: (UINavigationBar*)bar {
    [bar setBackgroundImage:[IRHelper imageWithColor:[UIColor colorWithRed:0x16/255. green:0x16/255. blue:0x1a/255. alpha:1.0]]
              forBarMetrics:UIBarMetricsDefault];

    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    [attributes setObject:[UIFont fontWithName:@"Avenir-Light" size:20.]
                   forKey:UITextAttributeFont ];
    [bar setTitleTextAttributes: attributes];
}

@end
