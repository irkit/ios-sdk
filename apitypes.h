
#ifndef APITYPES_H_
#define APITYPES_H_


// edited by mash
#include "stdint.h"
#define PACKED __attribute__((packed))
#define ALIGNED __attribute__((aligned(0x4)))
typedef uint8_t    uint8;
typedef uint16_t   uint16;
typedef int16_t    int16;
typedef uint32_t   uint32;
typedef int8_t     int8;

typedef struct bd_addr_t
{
    uint8 addr[6];

}bd_addr;

typedef bd_addr hwaddr;
typedef struct
{
    uint8 len;
    uint8 data[];
}uint8array;

typedef struct
{
    uint8 len;
    int8 data[];
}string;


#endif
