IRKit iOS SDK
===

[IRKit device](https://github.com/irkit/device) and SDK(this library) lets you control your home electronics from your iOS devices.
IRKit device has a Infrared LED and receiver, and a WiFi module inside.
Any device with internet or local wifi connection can use IRKit devices to make it send IR signals.

This library does:
* provide UIViewController subclasses that wraps complex procedures to connect and learn IR signals from IRKit devices
* provide a simple interface to send IR signals

## Get IRKit Device

see [IRKit device](https://github.com/irkit/device)

## Installing

Use [cocoapods](http://cocoapods.org/) 0.35.x or higher  
Currently under heavy development.

```sh
$ cat podfile
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '7.0'
pod 'IRKit', :git => 'https://github.com/irkit/ios-sdk.git'
workspace 'MyApp.xcworkspace'
xcodeproj 'MyApp/MyApp.xcodeproj'

$ pod install
```

## Usage

See [Minimal app](https://github.com/irkit/ios-sdk/tree/master/Minimal/Minimal) for a working minimal IR remote controller application.

### Include header

```objective-c
#import <IRKit/IRKit.h>
```

### Initialize

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [IRKit startWithAPIKey:@"#{ fill in your apikey }"];
    return YES;
}
```

### Get API key

```sh
% curl -d "email={your email}" "http://api.getirkit.com/1/apps"
{"message":"You will receive an email shortly, please click the URL in it to get an apikey"}
```

and open the URL in the email.

### Sending IR signals

IR signal is represented as a  [IRSignal](https://github.com/irkit/ios-sdk/blob/master/IRKit/IRKit/IRSignal.h) instance.

```objective-c
[signal sendWithCompletion:^(NSError *error) {
    NSLog(@"sent error: %@", error);
}];
```

### How to get an IRSignal?

You get your first `IRSignal` by *learning* it, which means: you point your old infrared remote controller at IRKit device's IR receiver, and press it's button.
IRKit device will send it over to your app(with IRKit iOS SDK).

But first, you need to *pair* with an IRKit device.

```objective-c
// in your main view controller
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // find IRKit if none is known
    if ([IRKit sharedInstance].countOfReadyPeripherals == 0) {
        IRNewPeripheralViewController *vc = [[IRNewPeripheralViewController alloc] init];
        vc.delegate = self;
        [self presentViewController:vc
                           animated:YES
                         completion:^{
                             NSLog(@"presented");
                         }];
    }
}

#pragma mark - IRNewPeripheralViewControllerDelegate

- (void)newPeripheralViewController:(IRNewPeripheralViewController *)viewController
            didFinishWithPeripheral:(IRPeripheral *)peripheral {
    NSLog( @"peripheral: %@", peripheral );

    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 NSLog(@"dismissed");
                             }];
}
```

When pairing is done, you're ready to learn an IRSignal from it.

```objective-c
IRNewSignalViewController *vc = [[IRNewSignalViewController alloc] init];
vc.delegate = self;
[self presentViewController:vc
                   animated:YES
                 completion:^{
                     NSLog(@"presented");
                 }];

#pragma mark - IRNewSignalViewControllerDelegate

- (void)newSignalViewController:(IRNewSignalViewController *)viewController
            didFinishWithSignal:(IRSignal *)signal {
    NSLog( @"signal: %@", signal );

    if (signal) {
        // successfully learned!
        _signal = signal;
    }
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 LOG(@"dismissed");
                             }];
}

```

### Collection of multiple IRSignals

Most remote controllers have more than 1 button, so you'll want to manage a collection of IRSignals.
`IRSignals` (with a `s` postfix) is it.

```objective-c
_signals = [[IRSignals alloc] init];

// and add a signal to the collection
[_signals addSignalsObject:_signal];

// send multiple IRSignal-s sequentially
[_signals sendSequentiallyWithCompletion:^(NSError *error) {
    NSLog( @"sent with error: %@", error );
}];

// and save it in NSUserDefaults
[_signals saveToStandardUserDefaultsWithKey:@"irkit.signals"];

// or load it from NSUserDefaults
[_signals loadFromStandardUserDefaultsKey:@"irkit.signals"];

// or send it elsewhere
NSData *data = [_signals data];

// or as JSON
NSString *json = [_signals JSONRepresentation];
```

## [Contributing](Contributing.md)

