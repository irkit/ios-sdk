#include "CRC8.h"

#define CRC8INIT 0x00
#define CRC8POLY 0x31 // = X^8+X^5+X^4+X^0

@implementation CRC8

+ (uint8_t)crc8:(uint8_t *)data size: (uint16_t)size {
    uint8_t crc, i;

    crc = CRC8INIT;

    while (size--) {
        crc ^= *data++;

        for (i = 0; i < 8; i++) {
            if (crc & 0x80) {
                crc = (crc << 1) ^ CRC8POLY;
            }
            else {
                crc <<= 1;
            }
        }
    }

    return crc;
}

@end
