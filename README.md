IRKit iOS SDK
===

[IRKit device](https://github.com/irkit/device) and SDK(this library) lets you control your home electronics from your iOS devices.
IRKit device has a Infrared LED and receiver, and a BluetoothLE module inside.
BluetoothLE enabled devices can connect with IRKit devices, and make it send IR signals for you.

This library does:
* provide UIViewController subclasses that wraps complex procedures to connect, pair and receive IR signals(to learn before sending) from IRKit devices
* provide a simple interface to send IR signals

## Get IRKit Device

see [IRKit device](https://github.com/irkit/device)

## Installing

Use [cocoapods](http://cocoapods.org/)

```sh
$ cat podfile
platform :ios, '6.0'
pod 'IRKit', '~> 0.0.2'
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

### Sending IR signals

IR signal is represented as a  [IRSignal](https://github.com/irkit/ios-sdk/blob/master/IRKit/IRKit/IRSignal.h) instance.

```objective-c
[signal sendWithCompletion:^(NSError *error) {
    NSLog(@"sent error: %@", error);
}];
```

### How to get an IRSignal?

You get your first `IRSignal` by *learning* it, which means: you point your old infrared remote controller at IRKit device's IR receiver, and press it's button.
IRKit device will send it over Bluetooth to your paired iOS device.

But first, you need to *pair* with an IRKit device.

```objective-c
// in your main view controller
- (void)viewDidAppear:(BOOL)animated {
    // pair if you haven't
    if (! _peripheral) {
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

    if (peripheral) {
        _peripheral = peripheral;
    }
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

// send multiple IRSignals sequentially
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

See more in [One Remote](https://github.com/irkit/one) working example.

### Displaying IRSignals

IRSignals conforms to `UITableViewDelegate` and `UITableViewDataSource` protocols, and provides a neat `IRSignalCell`.

See more in [One Remote](https://github.com/irkit/one) working example.
