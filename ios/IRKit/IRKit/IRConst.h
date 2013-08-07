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

#define IRKIT_CHARACTERISTIC_MANUFACTURER_NAME_UUID_STRING (@"2A29")
#define IRKIT_CHARACTERISTIC_MANUFACTURER_NAME_UUID [CBUUID UUIDWithString:IRKIT_CHARACTERISTIC_MANUFACTURER_NAME_UUID_STRING]
#define IRKIT_CHARACTERISTIC_MODEL_NAME_UUID_STRING        (@"2A24")
#define IRKIT_CHARACTERISTIC_MODEL_NAME_UUID [CBUUID UUIDWithString:IRKIT_CHARACTERISTIC_MODEL_NAME_UUID_STRING]
#define IRKIT_CHARACTERISTIC_HARDWARE_REVISION_UUID_STRING (@"2A27")
#define IRKIT_CHARACTERISTIC_HARDWARE_REVISION_UUID [CBUUID UUIDWithString:IRKIT_CHARACTERISTIC_HARDWARE_REVISION_UUID_STRING]
#define IRKIT_CHARACTERISTIC_FIRMWARE_REVISION_UUID_STRING (@"2A26")
#define IRKIT_CHARACTERISTIC_FIRMWARE_REVISION_UUID [CBUUID UUIDWithString:IRKIT_CHARACTERISTIC_FIRMWARE_REVISION_UUID_STRING]
#define IRKIT_CHARACTERISTIC_SOFTWARE_REVISION_UUID_STRING (@"2A28")
#define IRKIT_CHARACTERISTIC_SOFTWARE_REVISION_UUID [CBUUID UUIDWithString:IRKIT_CHARACTERISTIC_SOFTWARE_REVISION_UUID_STRING]

#define IRKIT_CONTROL_POINT_VALUE_SEND 0

#pragma mark - For Your Information

// see https://www.bluetooth.org/en-us/specification/assigned-numbers-overview/service-discovery
#define IRKIT_SERVICE_BASE_UUID (@"00000000-0000-1000-8000-00805F9B34FB")

// org.bluetooth.service.immediate_alert
#define IRKIT_SERVICE_IMMEDIATE_ALERT    [CBUUID UUIDWithString: @"1802"]

// org.bluetooth.service.link_loss
#define IRKIT_SERVICE_LINK_LOSS          [CBUUID UUIDWithString: @"1803"]

// org.bluetooth.service.tx_power
#define IRKIT_SERVICE_TX_POWER           [CBUUID UUIDWithString: @"1804"]

// org.bluetooth.service.device_information
#define IRKIT_SERVICE_DEVICE_INFORMATION [CBUUID UUIDWithString: @"180A"]

// org.bluetooth.service.battery_service
#define IRKIT_SERVICE_BATTERY_SERVICE    [CBUUID UUIDWithString: @"180F"]

#pragma mark - NSNotification names

// discovered unauthorized peripheral
#define IRKitDidDiscoverUnauthorizedPeripheralNotification @"IRKit::DiscoveredUnauthorized"

// user authorized peripheral for the 1st time
#define IRKitDidAuthorizePeripheralNotification            @"IRKit::Authorized"

// connected to peripheral and ready to send
#define IRKitDidConnectPeripheralNotification              @"IRKit::DidConnect"
#define IRKitDidDisconnectPeripheralNotification           @"IRKit::DidDisconnect"
#define IRKitDidReceiveSignalNotification                  @"IRKit::ReceivedSignal"

#define IRKitSignalUserInfoKey                   @"signal"

#pragma mark - UITableViewCell identifiers

#define IRKitCellIdentifierSignal                          @"IRSignalCell"
#define IRKitCellIdentifierPeripheral                      @"IRPeripheralCell"

#pragma mark - IR*ViewControllerDelegate

#define IRViewControllerResultType           @"result"
#define IRViewControllerResultTypeCancelled  @"cancelled"
#define IRViewControllerResultTypeDone       @"done"
#define IRViewControllerResultPeripheral     @"peripheral"
#define IRViewControllerResultSignal         @"signal"
#define IRViewControllerResultText           @"text"

#pragma mark - Errors

#define IRKIT_ERROR_DOMAIN              @"irkit"
#define IRKIT_ERROR_CODE_NOT_READY      1
#define IRKIT_ERROR_CODE_DISCONNECTED   2
#define IRKIT_ERROR_CODE_C12C_NOT_FOUND 3

#pragma mark - URLs

#define ONURL_BASE @"http://getirkit.appspot.com"

#endif
