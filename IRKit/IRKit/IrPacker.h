#ifndef __IRPACKER_H__
#define __IRPACKER_H__

#include "IrPackerConfig.h"
#include <inttypes.h>
#include <stdbool.h>

// 512(=IR_BUFF_SIZE) / 8
#define IRBITPACK_VALUE_SIZE 64

class IrBitPack
{
public:
    IrBitPack();
    // packing
#ifdef IRPACKER_SUPPORTS_PACK
    bool Add16(uint16_t val);
    uint8_t Write( uint8_t *out );
#endif

    // unpacking
    uint8_t StreamParse(uint8_t value, uint16_t *unpacked, uint16_t unpacked_index, uint16_t maxsize);

    void Clear();

    // class methods
    static bool IsStartOfBits( const uint16_t *data, uint16_t datasize, uint16_t input_index );
private:
    uint16_t val0_;
    uint16_t val1_;

#ifdef IRPACKER_SUPPORTS_PACK
    uint8_t values_[IRBITPACK_VALUE_SIZE];
#endif
    uint16_t bit_index_; // 0-511
    uint16_t bit_length_; // 0-511
    uint8_t  bit_length_received_count_; // 0-1

    void AddBit(bool value);
};

class IrPacker
{
public:
    IrPacker();
#ifdef IRPACKER_SUPPORTS_PACK
    uint16_t Pack( const uint16_t *data, uint8_t *packed, uint16_t datasize );
#endif
    uint16_t Unpack( const uint8_t *data, uint16_t *unpacked, uint16_t datasize, uint16_t maxsize );
    void Clear();

    // class methods
#ifdef IRPACKER_SUPPORTS_PACK
    static uint8_t BitPack( uint16_t value );
#endif
    static uint16_t BitUnpack( uint8_t value );

private:
    bool is_bit_packing_;
    IrBitPack bitpack_;

#ifdef IRPACKER_SUPPORTS_PACK
    void PackSingle( uint16_t value, uint8_t *packed_value, uint16_t packed_index );
#endif
    void UnpackSingle( uint8_t value, uint16_t *unpacked_value, uint16_t unpacked_index );
    bool IsStartOfAbsence( const uint16_t *data, uint16_t datasize, uint16_t input_index );
};

#endif // __IRPACKER_H__
