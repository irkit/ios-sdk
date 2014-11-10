//
//  IRPeripherals+UIKit.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2014/04/01.
//
//

#import "IRPeripherals+UIKit.h"
#import "Log.h"
#import "IRPeripheralCell.h"
#import "IRConst.h"
#import "IRHelper.h"

@implementation IRPeripherals (UITableView)

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG(@"indexPath.row: %ld", (long)indexPath.row);

    IRPeripheralCell *cell = (IRPeripheralCell *)[tableView dequeueReusableCellWithIdentifier: IRKitCellIdentifierPeripheral];
    if (cell == nil) {
        [tableView registerNib: [UINib nibWithNibName: @"IRPeripheralCell" bundle: [IRHelper resources]]
         forCellReuseIdentifier: IRKitCellIdentifierPeripheral];

        cell = [tableView dequeueReusableCellWithIdentifier: IRKitCellIdentifierPeripheral];
    }
    cell.peripheral = [self objectAtIndex: indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    LOG_CURRENT_METHOD;
    return self.countOfReadyPeripherals;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;
    return [IRPeripheralCell height];
}

@end
