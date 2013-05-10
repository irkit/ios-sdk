#include "Arduino.h"
#include <SoftwareSerial.h>
#include "BGLib.h"

// BLE112 module connections:
// - BLE P0_2 -> GND (CTS tied to ground to bypass flow control)
// - BLE P0_4 -> Arduino Digital Pin 6 (BLE TX -> Arduino soft RX)
// - BLE P0_5 -> Arduino Digital Pin 5 (BLE RX -> Arduino soft TX)

// NOTE: this demo REQUIRES the BLE112 be programmed with the UART connected
// to the "api" endpoint in hardware.xml, have "mode" set to "packet", and be
// configured for 38400 baud, 8/N/1. This may change in the future, but be
// aware. The BLE SDK archive contains an /examples/uartdemo project which is
// a good starting point for this communication, though some changes are
// required to enable packet mode and change the baud rate. The BGLib
// repository also includes a project you can use for this in the folder
// /BLEFirmware/BGLib_U1A1P_38400_noflow_wake16_hwake15.

// iMote git:8fa00b089894132e3f6906fea1009a4e53ce5834
SoftwareSerial ble112uart( 6, 5 ); // RX, TX
BGLib ble112( &ble112uart /*, &mac */ );

uint8_t isScanActive = 0;

#define LED_PIN 13 // Arduino Uno LED

void ble_rsp_system_hello(const void *nul) {
}

void ble_rsp_gap_set_scan_parameters(const struct ble_msg_gap_set_scan_parameters_rsp_t *msg) {
}

void ble_rsp_gap_discover(const struct ble_msg_gap_discover_rsp_t *msg) {
}

void ble_rsp_gap_end_procedure(const struct ble_msg_gap_end_procedure_rsp_t *msg) {
}

void ble_evt_system_boot(const struct ble_msg_system_boot_evt_t *msg) {
}

void ble_evt_gap_scan_response(const struct ble_msg_gap_scan_response_evt_t *msg) {
}

void ble_evt_connection_disconnected(const struct ble_msg_connection_disconnected_evt_t *msg) {
    printf( "reconnecting\r\n" );

    ble_cmd_gap_set_mode( gap_general_discoverable, gap_undirected_connectable );
}

void output(uint8 len1, uint8* data1, uint16 len2, uint8* data2) {
    printf( ">\traw: " );

    ble112uart.write( len1 + len2 );
    printf( "%02X ", len1 + len2 );

    unsigned int index = 0;
    for ( index=0; index < len1; index++ ) {
        ble112uart.write( data1[ index ] );
        printf( "%02X ", data1[ index ] );
    }

    index = 0;
    for ( index=0; index < len2; index++ ) {
        ble112uart.write( data2[ index ] );
        printf( "%02X ", data2[ index ] );
    }

    printf( "\r\n" );
}

void setup() {
    // initialize status LED
    pinMode(LED_PIN, OUTPUT);
    digitalWrite(LED_PIN, LOW);

    // open Arduino USB serial (and wait, if we're using Leonardo)
    Serial.begin(115200);

    // set the data rate for the SoftwareSerial port
    ble112uart.begin(38400);

    // welcome!
    Serial.println("BLE112 BGAPI Scanner Demo");

    // bglib_output:
    // void (*bglib_output)(uint8 len1,uint8* data1,uint16 len2,uint8* data2)=0;
    bglib_output = output;

    ble112.start();
}

void readMac() {
    static uint8_t write_count = 1;

    if ( Serial.available() > 0 ) {
        uint8_t ch = Serial.read();

        // echo
        printf("serial: %c\r\n", ch);

        if (ch == '0') {
            // Reset BLE112 module
            Serial.println(">\tsystem_reset: { boot_in_dfu: 0 }");
            ble_cmd_system_reset(0);
        }
        if (ch == '1') {
            // Say hello to the BLE112 and wait for response
            Serial.println(">\tsystem_hello");
            ble_cmd_system_hello();
        }
        else if (ch == '2') {
            // Toggle scanning for advertising BLE devices
            if (isScanActive) {
                isScanActive = 0;
                Serial.println(">\tgap_end_procedure");
                ble_cmd_gap_end_procedure();
            } else {
                isScanActive = 1;
                Serial.println(">\tgap_set_scan_parameters: { scan_interval: 0xC8, scan_window: 0xC8, active: 1 }");
                ble_cmd_gap_set_scan_parameters(0xC8, 0xC8, 1);

                Serial.println(">\tgap_discover: { mode: 2 (GENERIC) }");
                ble_cmd_gap_discover( gap_discover_generic );
            }
        }
        else if (ch == '3') {
            Serial.println(">\tgap_set_mode: { discover: 0x2, connect: 0x2 }");
            ble_cmd_gap_set_mode( gap_general_discoverable, gap_undirected_connectable );
        }
        else if (ch == '4') {
            Serial.println(">\tattributes_write");
            uint8_t data[] = { write_count ++ };
            ble_cmd_attributes_write( 0x0014,       // handle
                                      0,            // offset
                                      sizeof(data), // value_len
                                      &data         // value_data
                                      );
        }
        else if (ch == '5') {
            Serial.println(">\tget_rssi");
            ble_cmd_connection_get_rssi( 0x00 );
        }
    }
}

void loop() {
    readMac();

    while ( ble112.receivedCommand() ) {
        ble112.processCommand();
    }
    if ( ble112.errno ) {
        printf( "\r\n\r\n!!! ble112 error: %d !!! \r\n\r\n", ble112.errno );
        ble112.clearError();
        ble112.clearRXBuffer();
    }
}
