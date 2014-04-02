//
//  IRPeripherals+UITableView.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2014/04/01.
//
//

#import "IRPeripherals.h"
#import <UIKit/UIKit.h>

@interface IRPeripherals (UITableView) <UITableViewDataSource,UITableViewDelegate>

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
