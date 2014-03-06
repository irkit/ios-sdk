#import "Log.h"
#import "IRSamplesTableViewController.h"
#import "IRconst.h"
#import "IRGuidePowerViewController.h"
#import "IRPeripheralNameEditViewController.h"
#import "IRNewSignalScene1ViewController.h"
#import "IRSignalNameEditViewController.h"
#import "IRSignal.h"
#import "IRPeripheralCell.h"
#import "IRWifiEditViewController.h"
#import "IRHelper.h"

@interface IRSamplesTableViewController ()

@end

@implementation IRSamplesTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle: style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    [self.tableView registerNib: [UINib nibWithNibName: @"IRSignalCell" bundle: [IRHelper resources]]
         forCellReuseIdentifier: IRKitCellIdentifierSignal];
    [self.tableView registerNib: [UINib nibWithNibName: @"IRPeripheralCell" bundle: [IRHelper resources]]
         forCellReuseIdentifier: IRKitCellIdentifierPeripheral];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IRGuidePowerViewControllerDelegate

- (void)scene1ViewController:(id)viewController didFinishWithInfo:(NSDictionary*)info {
    LOG_CURRENT_METHOD;
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark - IRWifiEditViewControllerDelegate

- (void)wifiEditViewController:(IRWifiEditViewController *)viewController
             didFinishWithInfo:(NSDictionary*)info {
    LOG(@"info: %@", info);
    IRKeys *key = info[IRViewControllerResultKeys];
    [key setKeys: @{ @"clientkey": @"A", @"devicekey": @"B" }]; // we're testing morse
    LOG(@"morse: %@", key.morseStringRepresentation);
}

#pragma mark - IRGuideWifiViewControllerDelegate

- (void)guideWifiViewController:(IRGuideWifiViewController *)viewController didFinishWithInfo:(NSDictionary *)info {
    LOG_CURRENT_METHOD;
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark - IRPeripheralNameEditViewControllerDelegate

- (void)nameEditViewController:(IRPeripheralNameEditViewController *)viewController
             didFinishWithInfo:(NSDictionary*)info {
    LOG_CURRENT_METHOD;
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark - IRSignalNameEditViewControllerDelegate

- (void)signalNameEditViewController:(IRSignalNameEditViewController *)viewController didFinishWithInfo:(NSDictionary*)info {
    LOG_CURRENT_METHOD;
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
    case 0:
        return [tableView dequeueReusableCellWithIdentifier: @"IRGuidePower"];
    case 1:
        return [tableView dequeueReusableCellWithIdentifier: @"IRWifiEdit"];
    case 2:
        return [tableView dequeueReusableCellWithIdentifier: @"IRGuideWifi"];
    case 3:
        return [tableView dequeueReusableCellWithIdentifier: @"IRPeripheralNameEdit"];
    case 4:
        return [tableView dequeueReusableCellWithIdentifier: @"IRNewSignalScene1"];
    case 5:
        return [tableView dequeueReusableCellWithIdentifier: @"IRSignalNameEdit"];
    case 6:
    {
        IRPeripheralCell *cell   = [tableView dequeueReusableCellWithIdentifier: IRKitCellIdentifierPeripheral];
        IRPeripheral *peripheral = [[IRPeripheral alloc] init];
        peripheral.customizedName = @"my IRKit";
        cell.peripheral           = peripheral;
        return cell;
    }
    default:
        return [tableView dequeueReusableCellWithIdentifier: @"IRNewSignalScene1"];
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
    case 6:
        return [IRPeripheralCell height];

    default:
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;
    [tableView deselectRowAtIndexPath: indexPath animated: YES];

    NSBundle *resources = [IRHelper resources];
    switch (indexPath.row) {
    case 0:
    {
        IRGuidePowerViewController *c = [[IRGuidePowerViewController alloc] initWithNibName: @"IRGuidePowerViewController"
                                                                                     bundle: resources];
        c.delegate = self;

        [self.navigationController pushViewController: c animated: YES];
    }
    break;
    case 1:
    {
        IRWifiEditViewController *c = [[IRWifiEditViewController alloc] initWithNibName: @"IRWifiEditViewController" bundle: resources];
        c.delegate = self;
        [self.navigationController pushViewController: c animated: YES];
    }
    break;
    case 2:
    {
        IRGuideWifiViewController *c = [[IRGuideWifiViewController alloc] initWithNibName: @"IRGuideWifiViewController"
                                                                                   bundle: resources];
        c.delegate = self;

        [self.navigationController pushViewController: c animated: YES];
    }
    break;
    case 3:
    {
        IRPeripheralNameEditViewController *c = [[IRPeripheralNameEditViewController alloc] initWithNibName: @"IRPeripheralNameEditViewController"
                                                                                                     bundle: resources];
        c.delegate = self;
        IRPeripheral *peripheral = [[IRPeripheral alloc] init];
        c.peripheral = peripheral;

        [self.navigationController pushViewController: c animated: YES];
    }
    break;
    case 4:
    {
        IRNewSignalScene1ViewController *c = [[IRNewSignalScene1ViewController alloc] initWithNibName: @"IRNewSignalScene1ViewController"
                                                                                               bundle: resources];
        c.delegate = self;

        [self.navigationController pushViewController: c animated: YES];
    }
    break;
    case 5:
    {
        IRSignalNameEditViewController *c = [[IRSignalNameEditViewController alloc] initWithNibName: @"IRSignalNameEditViewController"
                                                                                             bundle: resources];
        c.delegate = self;
        unsigned short data[10] = { 100,100,100,100,100,100,100,100,100,100 };
        NSData *irdata          = [NSData dataWithBytes: data length: 10];
        IRSignal *signal        = [[IRSignal alloc] initWithDictionary: @{
                                       @"data": @[ @100,@100,@100,@100,@100,@100,@100,@100,@100,@100 ],
                                       @"format": @"raw",
                                       @"freq": @38,
                                   }];
        c.signal = signal;

        [self.navigationController pushViewController: c animated: YES];
    }
    break;
    default:
        break;
    }
}

@end
