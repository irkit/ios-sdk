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

#ifndef __BGLIB_H__
#define __BGLIB_H__

#include "cmd_def.h"
#include <SoftwareSerial.h>

class BGLib {
    public:
        BGLib(SoftwareSerial *module=0, SoftwareSerial *output=0);

        void setModuleUART(SoftwareSerial *module);
        void setOutputUART(SoftwareSerial *debug);

        void start();
        void receive(void);
        bool receivedCommand();
        void printRaw();
        void processCommand();

        void clearError();
        void clearRXBuffer();

        enum errors {
            errno_success         = 0,
            errno_timeout         = 1,
            errno_unknown_message = 2,
            errno_invalid_header  = 3,
        };

        uint8_t errno;

    private:
        // incoming packet buffer vars
        uint8_t  *bgapiRXBuffer;
        uint8_t   bgapiRXBufferSize;
        uint8_t   bgapiRXBufferPos; // index of bgapiRXBuffer to be filled when next data arrives
        uint16_t  bgapiRXDataLen;

        SoftwareSerial *uModule; // required UART object with module connection
        SoftwareSerial *uOutput; // optional UART object for host/debug connection
};
#endif
