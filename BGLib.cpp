// Bluegiga BGLib Arduino interface library
// 2012-11-14 by Jeff Rowberg <jeff@rowberg.net>
// Updates should (hopefully) always be available at https://github.com/jrowberg/bglib
// Modified by mash <o.masakazu@gmail.com>

/* ============================================
BGLib library code is placed under the MIT license
Copyright (c) 2012 Jeff Rowberg

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
===============================================
*/

#include "BGLib.h"
#include "BGAPIDebugger.h"

BGLib::BGLib(SoftwareSerial *module, SoftwareSerial *output) {
    uModule = module;
    uOutput = output;

    // initialize packet buffers
    bgapiRXBuffer    = (uint8_t *)malloc(bgapiRXBufferSize = 255);
    bgapiRXBufferPos = 0;
}

// set/update UART port objects
void BGLib::setModuleUART(SoftwareSerial *module) {
    uModule = module;
}

void BGLib::setOutputUART(SoftwareSerial *output) {
    uOutput = output;
}

void BGLib::start() {
    // can't make event driven work.. it stops receiving GAP scan responses
    // uModule->attach( this, &BGLib::received, Serial::RxIrq );
}

void BGLib::receive(void) {
    // see https://mbed.org/cookbook/Serial-Interrupts
    // Loop just in case more than one character is in UART's receive FIFO buffer
    while ( uModule->available() && ( bgapiRXDataLen < bgapiRXBufferSize ) ) {
        // led1=1;
        bgapiRXBuffer[ bgapiRXBufferPos ] = uModule->read();

        // echo to USB serial to watch data flow
        if ( uOutput ) {
            uOutput->write( bgapiRXBuffer[ bgapiRXBufferPos ] );
        }

        bgapiRXBufferPos = (bgapiRXBufferPos + 1) % bgapiRXBufferSize;
        bgapiRXDataLen ++;
    }
    // led1=0;

    // for test only
    // while (uModule->available()) {
    //     uint8_t received = uModule->read();
    //     printf( "%02X ", received );
    // }
}

bool BGLib::receivedCommand() {

    receive();

    if ( bgapiRXDataLen >= 4 ) {
        // return error and reset before receiving something weird
        uint8_t headIndex = (bgapiRXBufferPos + bgapiRXBufferSize - bgapiRXDataLen) % bgapiRXBufferSize;
        if ( bgapiRXBuffer[ headIndex ] != 0x0 && bgapiRXBuffer[ headIndex ] != 0x80 ) {
            // invalid octet 0, it should be 0x0 or 0x80
            errno = errno_invalid_header;
            return false;
        }

        // 1: offset of "lolen" from head
        uint8_t lolen = bgapiRXBuffer[ (bgapiRXBufferPos + bgapiRXBufferSize - bgapiRXDataLen + 1) % bgapiRXBufferSize ];

        // TODO check uint8array?
        // 4 bytes for sizeof(ble_header)
        if ( bgapiRXDataLen - 4 >= lolen ) {
            printf( "<\thead: %d lolen: %d len: %d pos: %d\r\n",
                    headIndex, lolen, bgapiRXDataLen, bgapiRXBufferPos );
            return true;
        }
    }
    return false;
}

void BGLib::printRaw() {
    printf( "<\traw: " );

    // initialized to headIndex
    uint8_t printIndex = (bgapiRXBufferPos + bgapiRXBufferSize - bgapiRXDataLen) % bgapiRXBufferSize;
    uint8_t lolen      = bgapiRXBuffer[ (printIndex + 1) % bgapiRXBufferSize ];
    uint8_t endIndex   = (printIndex + 4 + lolen) % bgapiRXBufferSize;

    while (printIndex != endIndex) {
        printf( "%02X ", bgapiRXBuffer[ printIndex ]);
        printIndex = (printIndex + 1) % bgapiRXBufferSize;
    }

    printf( "\r\n" );
}

void BGLib::processCommand() {
    // copy cyclic buffer to straight lined buffer
    uint8_t buf[ 255 ];
    uint8_t bufferHead = (bgapiRXBufferPos + bgapiRXBufferSize - bgapiRXDataLen) % bgapiRXBufferSize;

    // 4(header) + lolen
    uint8_t packetSize   = 4 + bgapiRXBuffer[ (bufferHead + 1) % bgapiRXBufferSize ];
    uint8_t copySize     = packetSize;
    uint8_t leftoverSize = 0;
    if (bufferHead + packetSize > bgapiRXBufferSize) {
        copySize     = bgapiRXBufferSize - bufferHead;
        leftoverSize = packetSize - copySize;
    }
    memcpy( buf,
            & bgapiRXBuffer[ bufferHead ],
            copySize );
    if ( leftoverSize ) {
        // single packet remainds in the beginning of cylic buffer
        memcpy( & buf[ copySize ],
                & bgapiRXBuffer[ (bufferHead + copySize) % bgapiRXBufferSize ],
                leftoverSize );
    }

    bgapiRXDataLen -= packetSize;

    struct ble_header    *h   = (struct ble_header*)( buf );
    const struct ble_msg *msg = ble_get_msg_hdr( *h );
    if ( ! msg ) {
        errno = errno_unknown_message;
        return;
    }

    int16_t index = printBGAPICommand( buf );
    if ( index < 0 ) {
        printRaw();
    }

    // handler wants only data (not headers)
    msg->handler( (const void*)( & buf[ 4 ] ) );
}

void BGLib::clearError() {
    errno = errno_success;
}

// TODO need critical section?
void BGLib::clearRXBuffer() {
    bgapiRXDataLen = 0;
}
