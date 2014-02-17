#import "IRViewCustomizer.h"
#import "IRNewSignalScene1ViewController.h"
#import "IRSignalNameEditViewController.h"
#import "IRNewPeripheralScene1ViewController.h"
#import "IRNewPeripheralScene2ViewController.h"
#import "IRPeripheralNameEditViewController.h"
#import "IRWifiEditViewController.h"
#import "IRMorsePlayerViewController.h"
#import "IRHelper.h"

@implementation IRViewCustomizer

+ (instancetype)sharedInstance {
    static IRViewCustomizer *instance;
    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        instance = [[IRViewCustomizer alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    __weak IRViewCustomizer *_self = self;
    _viewDidLoad = ^(UIViewController *viewController) {
        viewController.edgesForExtendedLayout = UIRectEdgeNone;
        viewController.view.backgroundColor = [IRViewCustomizer defaultViewBackgroundColor];
        [_self customizeLabelFonts:viewController.view];

        if ([viewController isKindOfClass:[IRNewSignalScene1ViewController class]] ||
            [viewController isKindOfClass:[IRNewPeripheralScene1ViewController class]])
        {
            // bar
            UINavigationBar *bar = viewController.navigationController.navigationBar;
            [IRViewCustomizer customizeNavigationBar:bar];

            // replace cancel button
            UIBarButtonItem *original = viewController.navigationItem.leftBarButtonItem;
            [IRViewCustomizer customizeCancelButton:original
                                  forViewController:viewController
                                     withImageNamed:@"icn_navibar_cancel"];
        }
        else if ([viewController isKindOfClass:[IRNewPeripheralScene2ViewController class]] ||
                 [viewController isKindOfClass:[IRWifiEditViewController class]] ||
                 [viewController isKindOfClass:[IRMorsePlayerViewController class]] ||
                 [viewController isKindOfClass:[IRSignalNameEditViewController class]])
        {
            // bar
            UINavigationBar *bar = viewController.navigationController.navigationBar;
            [IRViewCustomizer customizeNavigationBar:bar];

            // custom back button
            // this is nil :(
            // UIBarButtonItem *original = viewController.navigationItem.leftBarButtonItem;
            [IRViewCustomizer customizeCancelButton:nil
                                  forViewController:viewController
                                     withImageNamed:@"icn_navibar_back"];
        }
        else if ([viewController isKindOfClass:[IRPeripheralNameEditViewController class]]) {
            // bar
            UINavigationBar *bar = viewController.navigationController.navigationBar;
            [IRViewCustomizer customizeNavigationBar:bar];
        }
    };


    return self;
}

- (void)customizeLabelFonts:(UIView *)rootView {
    if (![[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:@"ja"]) {
        // only ja needs to change font
        return;
    }

    [IRHelper enumerateSubviewsOfRootView:rootView usingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)obj;
            UIFont *font   = label.font;
            label.font     = [IRHelper fontWithSize:font.pointSize];
        }
    }];
}

+ (UIColor *)keyColor {
    return [UIColor colorWithRed:0x00 / 255. green:0xa8 / 255. blue:0xff / 255. alpha:1.0];
}

// for navigationbar, normal text
+ (UIColor *)textColor {
    return [UIColor colorWithRed:0x33 / 255. green:0x33 / 255. blue:0x33 / 255. alpha:1.0];
}

// for buttons
+ (UIColor *)activeFontColor {
    return [self keyColor];
}

+ (UIColor *)inactiveFontColor {
    return [UIColor colorWithRed:0x79 / 255. green:0x7a / 255. blue:0x80 / 255. alpha:1.0];
}

+ (UIColor *)defaultViewBackgroundColor {
    return [UIColor colorWithRed:0xE5 / 255. green:0xE5 / 255. blue:0xE5 / 255. alpha:1.0];
}

+ (void)customizeCancelButton:(UIBarButtonItem *)original
    forViewController:(UIViewController *)viewController
    withImageNamed:(NSString *)name {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image   = [IRHelper imageInResourceNamed:name];

    [button setImage:image
            forState:UIControlStateNormal];
    [button sizeToFit];
    // [button setImageEdgeInsets:UIEdgeInsetsMake(0,0,0,-10)]; // move the button **px right
    if (original) {
        [button addTarget:viewController
                   action:original.action
         forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [button addTarget:viewController.navigationController
                   action:@selector(popViewControllerAnimated:)
         forControlEvents:UIControlEventTouchUpInside];
    }
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    viewController.navigationItem.leftBarButtonItem = item;
}

+ (void)customizeNavigationBar:(UINavigationBar *)bar {
    bar.barTintColor = [UIColor colorWithRed:0xF5 / 255. green:0xF5 / 255. blue:0xF5 / 255. alpha:1.0];
    bar.tintColor = [self activeFontColor];
    bar.translucent = NO; // if we don't want transparency

    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[[UINavigationBar appearance] titleTextAttributes]];
    [attributes setObject:[UIFont fontWithName:@"HelveticaNeue-Light" size:20.]
                   forKey:NSFontAttributeName ];
    [attributes setObject:[self textColor]
                   forKey:NSForegroundColorAttributeName];
    [bar setTitleTextAttributes:attributes];
}

@end
