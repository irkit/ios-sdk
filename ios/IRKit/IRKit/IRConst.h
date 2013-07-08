//
//  IRConst.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/18.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#ifndef IRKit_IRConst_h
#define IRKit_IRConst_h

#pragma mark - Bluetooth definitions

#define IRKIT_SERVICE_UUID_STRING (@"195AE58A-437A-489B-B0CD-B7C9C394BAE4")
#define IRKIT_SERVICE_UUID        [CBUUID UUIDWithString: IRKIT_SERVICE_UUID_STRING]

#define IRKIT_CHARACTERISTIC_IR_DATA_UUID_STRING (@"5FC569A0-74A9-4FA4-B8B7-8354C86E45A4")
#define IRKIT_CHARACTERISTIC_IR_DATA_UUID [CBUUID UUIDWithString:IRKIT_CHARACTERISTIC_IR_DATA_UUID_STRING]

#define IRKIT_CHARACTERISTIC_UNREAD_STATUS_UUID_STRING (@"841B6310-CC62-4976-9C83-EB875AF7E007")
#define IRKIT_CHARACTERISTIC_UNREAD_STATUS_UUID [CBUUID UUIDWithString:IRKIT_CHARACTERISTIC_UNREAD_STATUS_UUID_STRING]

#define IRKIT_CHARACTERISTIC_CONTROL_POINT_UUID_STRING (@"CF746376-2FED-40FA-A232-C0BFF843AA94")
#define IRKIT_CHARACTERISTIC_CONTROL_POINT_UUID [CBUUID UUIDWithString:IRKIT_CHARACTERISTIC_CONTROL_POINT_UUID_STRING]

#define IRKIT_CHARACTERISTIC_CARRIER_FREQUENCY_UUID_STRING (@"21819AB0-C937-4188-B0DB-B9621E1696CD")
#define IRKIT_CHARACTERISTIC_CARRIER_FREQUENCY_UUID [CBUUID UUIDWithString:IRKIT_CHARACTERISTIC_CARRIER_FREQUENCY_UUID_STRING]

#define IRKIT_CHARACTERISTIC_AUTHORIZATION_UUID_STRING (@"6A936395-E774-4BC0-8B1D-6D14DAA5FC13")
#define IRKIT_CHARACTERISTIC_AUTHORIZATION_UUID [CBUUID UUIDWithString:IRKIT_CHARACTERISTIC_AUTHORIZATION_UUID_STRING]

#define IRKIT_CHARACTERISTICS @[ IRKIT_CHARACTERISTIC_IR_DATA_UUID, IRKIT_CHARACTERISTIC_UNREAD_STATUS_UUID, IRKIT_CHARACTERISTIC_CONTROL_POINT_UUID, IRKIT_CHARACTERISTIC_CARRIER_FREQUENCY_UUID, IRKIT_CHARACTERISTIC_AUTHORIZATION_UUID ]

#define IRKIT_CONTROL_POINT_VALUE_SEND 0

#pragma mark - For Your Information

// see https://www.bluetooth.org/en-us/specification/assigned-numbers-overview/service-discovery
#define IRKIT_SERVICE_BASE_UUID (@"00000000-0000-1000-8000-00805F9B34FB")

// org.bluetooth.service.immediate_alert
#define IRKIT_SERVICE_IMMEDIATE_ALERT    0x1802

// org.bluetooth.service.link_loss
#define IRKIT_SERVICE_LINK_LOSS          0x1803

// org.bluetooth.service.tx_power
#define IRKIT_SERVICE_TX_POWER           0x1804

// org.bluetooth.service.device_information
#define IRKIT_SERVICE_DEVICE_INFORMATION 0x180A

// org.bluetooth.service.battery_service
#define IRKIT_SERVICE_BATTERY_SERVICE    0x180F

#pragma mark - NSNotification names

#define IRKitDidConnectPeripheralNotification    @"IRKit::DidConnect"
#define IRKitDidDisconnectPeripheralNotification @"IRKit::DidDisconnect"
#define IRKitPeripheralAuthorizedNotification    @"IRKit::Authorized"
#define IRKitDidReceiveSignalNotification        @"IRKit::ReceivedSignal"

#define IRKitPeripheralUserInfoKey               @"peripheral"
#define IRKitSignalUserInfoKey                   @"signal"

#pragma mark - UITableViewCell identifiers

#define IRKitCellIdentifierSignal @"IRKit::UITableViewCell::Signal"

#pragma mark - IR*ViewControllerDelegate

#define IRViewControllerResultType           @"result"
#define IRViewControllerResultTypeCancelled  @"cancelled"
#define IRViewControllerResultTypeDone       @"done"
#define IRViewControllerResultPeripheral     IRKitPeripheralUserInfoKey
#define IRViewControllerResultSignal         IRKitSignalUserInfoKey
#define IRViewControllerResultText           @"text"

#pragma mark - Errors

#define IRKIT_ERROR_DOMAIN              @"irkit"
#define IRKIT_ERROR_CODE_NOT_READY      1
#define IRKIT_ERROR_CODE_DISCONNECTED   2
#define IRKIT_ERROR_CODE_C12C_NOT_FOUND 3

#endif
