//
//  IRConst.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/18.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#ifndef IRKit_IRConst_h
#define IRKit_IRConst_h

#pragma Bluetooth definitions


#define IRKIT_SERVICE_UUID_STRING (@"33CE5403-ECD2-4B90-9922-490268BBC73E")
#define IRKIT_SERVICE_UUID        [CBUUID UUIDWithString: IRKIT_SERVICE_UUID_STRING]

#define IRKIT_CHARACTERISTIC_UUID_STRING (@"583EB51D-0D38-4060-89FE-5D9722C3F5C3")
#define IRKIT_CHARACTERISTIC_UUID [CBUUID UUIDWithString: IRKIT_CHARACTERISTIC_UUID_STRING]

// see https://www.bluetooth.org/en-us/specification/assigned-numbers-overview/service-discovery
#define BASE_UUID (@"00000000-0000-1000-8000-00805F9B34FB")


#pragma mark -
#pragma NSNotification names

#define IRKitDidDiscoverPeripheralNotification @"IRKit::DidDiscover"

#endif
