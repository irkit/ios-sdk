#include "IrPacker.h"

#ifndef ARDUINO
# include <stdio.h>
#endif

// Packing/Unpacking uint16_t data into uint8_t data
//
// Raw data is:
// Sequence of number of Timer/Counter1 ticks between Falling/Rising edge of input (IR data).
// IR data commonly (but not limited to) have:
// * A fixed size header
// * A fixed size trailer
// * A mutable size of 1/0
// * Sequence of 0xFFFF 0x0000 means: 2 x 65536 number of ticks without any edges
// * High accuracy not required (5% seems fine)
//
// So, we're going to:
// * Use this reccurence formula: `y(x) = 1.05 * y(x-1)` to map uint16_t values into uint8_t values
// * If pair of 0/1 values are found, pack it specially
//
// sample data:
// 461A 231D 0491 0476 0490 0D24 0493 0D24 0492 0D23 0494 0475 0493 0D22 0495 0D21
// 0494 0D21 0495 0D20 0496 0D1F 0496 0D20 0496 0472 0495 0472 0493 0473 0494 0473
// 0493 0D30 0495 0D20 0494 0D21 0496 0472 0492 0D21 0495 0473 0493 0474 0493 0474
// 0492 0474 0492 0474 0492 0D22 0493 0D22 0494 0474 0492 0D21 0494 0474 0491 0D22
// 0493 0477 0492 FFFF 0000 229F 4623 1164 0494
//
// becomes:
// 0xd7 0xc3 0x00 0x41 0x00 0x88 0xa7 0x15
// 0x15 0x54 0x01 0x51 0x00 0x14 0x44 0x00
// 0xff 0xc3 0xd7 0xaf 0x88

//

// these should be set in Arduino.h
#ifndef bitRead
# define bitRead(value, bit) (((value) >> (bit)) & 0x01)
#endif
#ifndef bitSet
# define bitSet(value, bit) ((value) |= (1UL << (bit)))
#endif
#ifndef bitClear
# define bitClear(value, bit) ((value) &= ~(1UL << (bit)))
#endif

#ifndef ARDUINO

static void dump8( const uint8_t *data, uint16_t datasize )
{
    uint16_t i;

    printf("{ ");
    for (i=0; i<datasize; i++) {
        printf("0x%02x ",data[i]);
    }
    printf("}\n");
}

static void dump16( const uint16_t *data, uint16_t datasize )
{
    uint16_t i;

    printf("{ ");
    for (i=0; i<datasize; i++) {
        printf("0x%04x ",data[i]);
    }
    printf("}\n");
}

#endif // ARDUINO

IrBitPack::IrBitPack()
{
    Clear();
}

#ifdef IRPACKER_SUPPORTS_PACK

bool IrBitPack::Add16(uint16_t val)
{
    uint8_t packed = IrPacker::BitPack(val);
    if ( ! val0_ ) {
        val0_ = packed;
        AddBit(0);
        return 1;
    }
    // 2: less than 12% (3.5 * 3.5) error rate
    if ( ( (packed <= val0_) && (val0_ - packed <= 2) ) ||
         ( (val0_ <= packed) && (packed - val0_ <= 2) ) ) {
        AddBit(0);
        return 1;
    }
    if ( ! val1_ ) {
        val1_ = packed;
        AddBit(1);
        return 1;
    }
    if ( ( (packed <= val1_) && (val1_ - packed <= 2) ) ||
         ( (val1_ <= packed) && (packed - val1_ <= 2) ) ) {
        AddBit(1);
        return 1;
    }
    return 0;
}

void IrBitPack::AddBit(bool value)
{
    uint16_t byte_index = bit_index_ / 8;
    if (value) {
        bitSet  ( values_[byte_index], 7 - (bit_index_ % 8) );
    }
    else {
        bitClear( values_[byte_index], 7 - (bit_index_ % 8) );
    }
    bit_index_ ++;
}

bool IrBitPack::IsStartOfBits( const uint16_t *data, uint16_t datasize, uint16_t input_index )
{
    if (input_index < 2) {
        // 1st and 2nd values tend to be start seqeunce
        return 0;
    }
    if (datasize - input_index < 3) {
        // needs at least 3 data in front of us
        return 0;
    }
    IrBitPack ret;
    uint8_t i;
    for (i=0; i<3; i++) {
        bool added = ret.Add16( data[ input_index + i ] );
        if ( ! added ) {
            return 0;
        }
    }
    return 1;
}

uint8_t IrBitPack::Write( uint8_t *out )
{
    uint8_t i;
    uint8_t ret = 0;

    out[ ret ] = 0x00;
    ret ++;

    // uint16_t little endian
    out[ ret ] = bit_index_;
    ret ++;
    ret ++;

    // TODO swap 0/1 bits if val0_ > val1_
    out[ ret ] = val0_;
    ret ++;

    if (val1_) {
        out[ ret ] = val1_;
    }
    else {
        out[ ret ] = 0xFE;
    }
    ret ++;

    for (i=0; i<(bit_index_/8 + 1); i++) {
        out[ ret ] = values_[i];
        ret ++;
    }
    return ret;
}

#endif // IRPACKER_SUPPORTS_PACK

// 0x00 - marker
// uint16_t bit_length
// val0
// val1
// bits
uint8_t IrBitPack::StreamParse(uint8_t value, uint16_t *unpacked, uint16_t unpacked_index, uint16_t maxsize)
{
    if (! maxsize) {
        return 0;
    }
    if (! bit_length_received_count_) {
        bit_length_received_count_ ++;
        bit_length_ = value; // little endian
        return 0;
    }
    if (bit_length_received_count_ == 1) {
        bit_length_received_count_ ++;
        bit_length_ |= (((uint16_t)value) << 8);
        return 0;
    }
    if (! val0_) {
        val0_ = IrPacker::BitUnpack(value);
        return 0;
    }
    if (! val1_) {
        val1_ = IrPacker::BitUnpack(value);
        return 0;
    }
    uint8_t i;
    uint8_t ret = 0;
    for (i=7; i>=0; i--) {
        if (unpacked_index + ret == maxsize) {
            break;
        }
        if (bit_length_ == 0) {
            break;
        }
        bit_length_ --;

        if (bitRead(value,i)) {
            unpacked[ unpacked_index + ret ] = val1_;
        }
        else {
            unpacked[ unpacked_index + ret ] = val0_;
        }
        ret ++;
    }
    return ret;
}

void IrBitPack::Clear()
{
    val0_      = 0;
    val1_      = 0;
    bit_length_ = 0;
    bit_length_received_count_ = 0;
#ifdef IRPACKER_SUPPORTS_PACK
    bit_index_ = 0;
    uint8_t i;
    for (i=0; i<IRBITPACK_VALUE_SIZE; i++) {
        values_[i] = 0;
    }
#endif
}

IrPacker::IrPacker()
{
    Clear();
}

void IrPacker::Clear()
{
    is_bit_packing_ = 0;
    bitpack_.Clear();
}

#ifdef IRPACKER_SUPPORTS_PACK

// * data : input
// * packed : packed output
// * datasize : number of uint16_t entries in data
uint16_t IrPacker::Pack( const uint16_t *data, uint8_t *packed, uint16_t datasize )
{
#ifndef ARDUINO
    printf("[pack]input: ");
    dump16( data, datasize );
#endif
    uint16_t input_index = 0;
    uint16_t packed_index = 0;
    while (input_index < datasize) {
        uint16_t value = data[input_index];
        if (is_bit_packing_) {
            bool added = bitpack_.Add16(value);
            if (added) {
                // ok
            }
            else {
                uint16_t written_bytes = bitpack_.Write(packed + packed_index);
                packed_index += written_bytes;
                is_bit_packing_ = 0;
                continue; // don't run input_index ++, process the same index again
            }
        }
        else if (IsStartOfAbsence(data, datasize, input_index)) {
            packed[packed_index] = 0xFF;
            packed_index ++;
            input_index ++; // skip 0x0000 too
        }
        else {
            if (IrBitPack::IsStartOfBits(data, datasize, input_index)) {
                is_bit_packing_ = 1;
                bitpack_.Clear();
                bitpack_.Add16(value);
            }
            else {
                PackSingle(value, packed, packed_index);
                packed_index ++;
            }
        }

        input_index++;
    }
    if (is_bit_packing_) {
        uint16_t written_bytes = bitpack_.Write(packed + packed_index);
        packed_index += written_bytes;
        is_bit_packing_ = 0;
    }

#ifndef ARDUINO
    printf("[pack]packed: ");
    dump8( packed, packed_index );
#endif

    return packed_index;
}

bool IrPacker::IsStartOfAbsence( const uint16_t *data, uint16_t datasize, uint16_t input_index )
{
    if (datasize - input_index >= 2) {
        if ( (data[input_index  ] == 0xFFFF) &&
             (data[input_index+1] == 0x0000) ) {
            return 1;
        }
    }
    return 0;
}

#endif // IRPACKER_SUPPORTS_PACK

// * data : input
// * unpacked : unpacked output
// * datasize : number of uint8_t entries in data
uint16_t IrPacker::Unpack( const uint8_t *data, uint16_t *unpacked, uint16_t datasize, uint16_t maxsize )
{
#ifndef ARDUINO
    printf("[unpack]input: ");
    dump8( data, datasize );
#endif
    uint16_t input_index    = 0;
    uint16_t unpacked_index = 0;
    while ( (input_index < datasize) && (unpacked_index < maxsize) ) {
        uint8_t value = data[input_index];

        if (is_bit_packing_) {
            uint8_t written_bytes = bitpack_.StreamParse(value, unpacked, unpacked_index, maxsize);
            if (written_bytes) {
                unpacked_index += (uint16_t)written_bytes;
                is_bit_packing_ = 0;
            }
        }
        else if (value == 0x00) {
            is_bit_packing_ = 1;
            bitpack_.Clear();
        }
        else if (value == 0xFF) {
            unpacked[ unpacked_index ] = 0xFFFF;
            unpacked_index ++;
            unpacked[ unpacked_index ] = 0x0000;
            unpacked_index ++;
        }
        else {
            UnpackSingle(value, unpacked, unpacked_index);
            unpacked_index ++;
        }

        input_index++;
    }

#ifndef ARDUINO
    printf("[unpack]unpacked: ");
    dump16( unpacked, unpacked_index );
#endif

    return unpacked_index;
}

#ifdef IRPACKER_SUPPORTS_PACK

// maps 30-65535 values into 30-255
// using "if" binary search !!
// generated by: perl print_fixed_binary_search.pl 30 1.035
void IrPacker::PackSingle( uint16_t value, uint8_t *packed_value, uint16_t packed_index )
{
    uint8_t ret = IrPacker::BitPack( value );
    packed_value[ packed_index ] = ret;
}

#endif // IRPACKER_SUPPORTS_PACK

// maps 30-255 values into 30-65535
// using "if" binary search !!
// generated by: perl print_fixed_binary_search.pl 30 1.035
void IrPacker::UnpackSingle( uint8_t value, uint16_t *unpacked_value, uint16_t unpacked_index )
{
    uint16_t ret = IrPacker::BitUnpack( value );
    unpacked_value[ unpacked_index ] = ret;
}

#ifdef IRPACKER_SUPPORTS_PACK

uint8_t IrPacker::BitPack( uint16_t value )
{
    uint8_t ret;
    if (value < 1413) {
        if (value < 205) {
            if (value < 78) {
                if (value < 48) {
                    if (value < 38) {
                        if (value < 33) {
                            if (value < 31) {
                                ret = 30;

                            }
                            else {
                                if (value < 32) {
                                    ret = 31;
                                }
                                else {
                                    ret = 32;
                                }

                            }

                        }
                        else {
                            if (value < 35) {
                                if (value < 34) {
                                    ret = 33;
                                }
                                else {
                                    ret = 34;
                                }

                            }
                            else {
                                if (value < 36) {
                                    ret = 35;
                                }
                                else {
                                    ret = 36;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 42) {
                            if (value < 39) {
                                ret = 37;

                            }
                            else {
                                if (value < 40) {
                                    ret = 38;
                                }
                                else {
                                    ret = 39;
                                }

                            }

                        }
                        else {
                            if (value < 45) {
                                if (value < 43) {
                                    ret = 40;
                                }
                                else {
                                    ret = 41;
                                }

                            }
                            else {
                                if (value < 46) {
                                    ret = 42;
                                }
                                else {
                                    ret = 43;
                                }

                            }

                        }

                    }

                }
                else {
                    if (value < 61) {
                        if (value < 53) {
                            if (value < 50) {
                                ret = 44;

                            }
                            else {
                                if (value < 52) {
                                    ret = 45;
                                }
                                else {
                                    ret = 46;
                                }

                            }

                        }
                        else {
                            if (value < 57) {
                                if (value < 55) {
                                    ret = 47;
                                }
                                else {
                                    ret = 48;
                                }

                            }
                            else {
                                if (value < 59) {
                                    ret = 49;
                                }
                                else {
                                    ret = 50;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 68) {
                            if (value < 63) {
                                ret = 51;

                            }
                            else {
                                if (value < 66) {
                                    ret = 52;
                                }
                                else {
                                    ret = 53;
                                }

                            }

                        }
                        else {
                            if (value < 73) {
                                if (value < 70) {
                                    ret = 54;
                                }
                                else {
                                    ret = 55;
                                }

                            }
                            else {
                                if (value < 75) {
                                    ret = 56;
                                }
                                else {
                                    ret = 57;
                                }

                            }

                        }

                    }

                }

            }
            else {
                if (value < 127) {
                    if (value < 100) {
                        if (value < 87) {
                            if (value < 81) {
                                ret = 58;

                            }
                            else {
                                if (value < 84) {
                                    ret = 59;
                                }
                                else {
                                    ret = 60;
                                }

                            }

                        }
                        else {
                            if (value < 93) {
                                if (value < 90) {
                                    ret = 61;
                                }
                                else {
                                    ret = 62;
                                }

                            }
                            else {
                                if (value < 96) {
                                    ret = 63;
                                }
                                else {
                                    ret = 64;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 110) {
                            if (value < 103) {
                                ret = 65;

                            }
                            else {
                                if (value < 107) {
                                    ret = 66;
                                }
                                else {
                                    ret = 67;
                                }

                            }

                        }
                        else {
                            if (value < 118) {
                                if (value < 114) {
                                    ret = 68;
                                }
                                else {
                                    ret = 69;
                                }

                            }
                            else {
                                if (value < 122) {
                                    ret = 70;
                                }
                                else {
                                    ret = 71;
                                }

                            }

                        }

                    }

                }
                else {
                    if (value < 161) {
                        if (value < 141) {
                            if (value < 131) {
                                ret = 72;

                            }
                            else {
                                if (value < 136) {
                                    ret = 73;
                                }
                                else {
                                    ret = 74;
                                }

                            }

                        }
                        else {
                            if (value < 151) {
                                if (value < 146) {
                                    ret = 75;
                                }
                                else {
                                    ret = 76;
                                }

                            }
                            else {
                                if (value < 156) {
                                    ret = 77;
                                }
                                else {
                                    ret = 78;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 179) {
                            if (value < 167) {
                                ret = 79;

                            }
                            else {
                                if (value < 173) {
                                    ret = 80;
                                }
                                else {
                                    ret = 81;
                                }

                            }

                        }
                        else {
                            if (value < 192) {
                                if (value < 185) {
                                    ret = 82;
                                }
                                else {
                                    ret = 83;
                                }

                            }
                            else {
                                if (value < 198) {
                                    ret = 84;
                                }
                                else {
                                    ret = 85;
                                }

                            }

                        }

                    }

                }

            }

        }
        else {
            if (value < 539) {
                if (value < 333) {
                    if (value < 262) {
                        if (value < 228) {
                            if (value < 213) {
                                ret = 86;

                            }
                            else {
                                if (value < 220) {
                                    ret = 87;
                                }
                                else {
                                    ret = 88;
                                }

                            }

                        }
                        else {
                            if (value < 244) {
                                if (value < 236) {
                                    ret = 89;
                                }
                                else {
                                    ret = 90;
                                }

                            }
                            else {
                                if (value < 253) {
                                    ret = 91;
                                }
                                else {
                                    ret = 92;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 290) {
                            if (value < 271) {
                                ret = 93;

                            }
                            else {
                                if (value < 280) {
                                    ret = 94;
                                }
                                else {
                                    ret = 95;
                                }

                            }

                        }
                        else {
                            if (value < 311) {
                                if (value < 300) {
                                    ret = 96;
                                }
                                else {
                                    ret = 97;
                                }

                            }
                            else {
                                if (value < 322) {
                                    ret = 98;
                                }
                                else {
                                    ret = 99;
                                }

                            }

                        }

                    }

                }
                else {
                    if (value < 424) {
                        if (value < 369) {
                            if (value < 345) {
                                ret = 100;

                            }
                            else {
                                if (value < 357) {
                                    ret = 101;
                                }
                                else {
                                    ret = 102;
                                }

                            }

                        }
                        else {
                            if (value < 395) {
                                if (value < 382) {
                                    ret = 103;
                                }
                                else {
                                    ret = 104;
                                }

                            }
                            else {
                                if (value < 409) {
                                    ret = 105;
                                }
                                else {
                                    ret = 106;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 470) {
                            if (value < 439) {
                                ret = 107;

                            }
                            else {
                                if (value < 454) {
                                    ret = 108;
                                }
                                else {
                                    ret = 109;
                                }

                            }

                        }
                        else {
                            if (value < 503) {
                                if (value < 486) {
                                    ret = 110;
                                }
                                else {
                                    ret = 111;
                                }

                            }
                            else {
                                if (value < 521) {
                                    ret = 112;
                                }
                                else {
                                    ret = 113;
                                }

                            }

                        }

                    }

                }

            }
            else {
                if (value < 873) {
                    if (value < 686) {
                        if (value < 598) {
                            if (value < 558) {
                                ret = 114;

                            }
                            else {
                                if (value < 578) {
                                    ret = 115;
                                }
                                else {
                                    ret = 116;
                                }

                            }

                        }
                        else {
                            if (value < 640) {
                                if (value < 619) {
                                    ret = 117;
                                }
                                else {
                                    ret = 118;
                                }

                            }
                            else {
                                if (value < 663) {
                                    ret = 119;
                                }
                                else {
                                    ret = 120;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 761) {
                            if (value < 710) {
                                ret = 121;

                            }
                            else {
                                if (value < 735) {
                                    ret = 122;
                                }
                                else {
                                    ret = 123;
                                }

                            }

                        }
                        else {
                            if (value < 815) {
                                if (value < 787) {
                                    ret = 124;
                                }
                                else {
                                    ret = 125;
                                }

                            }
                            else {
                                if (value < 843) {
                                    ret = 126;
                                }
                                else {
                                    ret = 127;
                                }

                            }

                        }

                    }

                }
                else {
                    if (value < 1111) {
                        if (value < 968) {
                            if (value < 904) {
                                ret = 128;

                            }
                            else {
                                if (value < 935) {
                                    ret = 129;
                                }
                                else {
                                    ret = 130;
                                }

                            }

                        }
                        else {
                            if (value < 1037) {
                                if (value < 1002) {
                                    ret = 131;
                                }
                                else {
                                    ret = 132;
                                }

                            }
                            else {
                                if (value < 1073) {
                                    ret = 133;
                                }
                                else {
                                    ret = 134;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 1232) {
                            if (value < 1150) {
                                ret = 135;

                            }
                            else {
                                if (value < 1190) {
                                    ret = 136;
                                }
                                else {
                                    ret = 137;
                                }

                            }

                        }
                        else {
                            if (value < 1319) {
                                if (value < 1275) {
                                    ret = 138;
                                }
                                else {
                                    ret = 139;
                                }

                            }
                            else {
                                if (value < 1366) {
                                    ret = 140;
                                }
                                else {
                                    ret = 141;
                                }

                            }

                        }

                    }

                }

            }

        }

    }
    else {
        if (value < 9707) {
            if (value < 3704) {
                if (value < 2288) {
                    if (value < 1798) {
                        if (value < 1567) {
                            if (value < 1463) {
                                ret = 142;

                            }
                            else {
                                if (value < 1514) {
                                    ret = 143;
                                }
                                else {
                                    ret = 144;
                                }

                            }

                        }
                        else {
                            if (value < 1679) {
                                if (value < 1622) {
                                    ret = 145;
                                }
                                else {
                                    ret = 146;
                                }

                            }
                            else {
                                if (value < 1738) {
                                    ret = 147;
                                }
                                else {
                                    ret = 148;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 1994) {
                            if (value < 1861) {
                                ret = 149;

                            }
                            else {
                                if (value < 1927) {
                                    ret = 150;
                                }
                                else {
                                    ret = 151;
                                }

                            }

                        }
                        else {
                            if (value < 2136) {
                                if (value < 2064) {
                                    ret = 152;
                                }
                                else {
                                    ret = 153;
                                }

                            }
                            else {
                                if (value < 2211) {
                                    ret = 154;
                                }
                                else {
                                    ret = 155;
                                }

                            }

                        }

                    }

                }
                else {
                    if (value < 2911) {
                        if (value < 2537) {
                            if (value < 2368) {
                                ret = 156;

                            }
                            else {
                                if (value < 2451) {
                                    ret = 157;
                                }
                                else {
                                    ret = 158;
                                }

                            }

                        }
                        else {
                            if (value < 2718) {
                                if (value < 2626) {
                                    ret = 159;
                                }
                                else {
                                    ret = 160;
                                }

                            }
                            else {
                                if (value < 2813) {
                                    ret = 161;
                                }
                                else {
                                    ret = 162;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 3228) {
                            if (value < 3013) {
                                ret = 163;

                            }
                            else {
                                if (value < 3119) {
                                    ret = 164;
                                }
                                else {
                                    ret = 165;
                                }

                            }

                        }
                        else {
                            if (value < 3458) {
                                if (value < 3341) {
                                    ret = 166;
                                }
                                else {
                                    ret = 167;
                                }

                            }
                            else {
                                if (value < 3579) {
                                    ret = 168;
                                }
                                else {
                                    ret = 169;
                                }

                            }

                        }

                    }

                }

            }
            else {
                if (value < 5997) {
                    if (value < 4713) {
                        if (value < 4107) {
                            if (value < 3834) {
                                ret = 170;

                            }
                            else {
                                if (value < 3968) {
                                    ret = 171;
                                }
                                else {
                                    ret = 172;
                                }

                            }

                        }
                        else {
                            if (value < 4400) {
                                if (value < 4251) {
                                    ret = 173;
                                }
                                else {
                                    ret = 174;
                                }

                            }
                            else {
                                if (value < 4554) {
                                    ret = 175;
                                }
                                else {
                                    ret = 176;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 5226) {
                            if (value < 4878) {
                                ret = 177;

                            }
                            else {
                                if (value < 5049) {
                                    ret = 178;
                                }
                                else {
                                    ret = 179;
                                }

                            }

                        }
                        else {
                            if (value < 5598) {
                                if (value < 5408) {
                                    ret = 180;
                                }
                                else {
                                    ret = 181;
                                }

                            }
                            else {
                                if (value < 5794) {
                                    ret = 182;
                                }
                                else {
                                    ret = 183;
                                }

                            }

                        }

                    }

                }
                else {
                    if (value < 7629) {
                        if (value < 6648) {
                            if (value < 6206) {
                                ret = 184;

                            }
                            else {
                                if (value < 6424) {
                                    ret = 185;
                                }
                                else {
                                    ret = 186;
                                }

                            }

                        }
                        else {
                            if (value < 7122) {
                                if (value < 6881) {
                                    ret = 187;
                                }
                                else {
                                    ret = 188;
                                }

                            }
                            else {
                                if (value < 7371) {
                                    ret = 189;
                                }
                                else {
                                    ret = 190;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 8459) {
                            if (value < 7896) {
                                ret = 191;

                            }
                            else {
                                if (value < 8173) {
                                    ret = 192;
                                }
                                else {
                                    ret = 193;
                                }

                            }

                        }
                        else {
                            if (value < 9061) {
                                if (value < 8755) {
                                    ret = 194;
                                }
                                else {
                                    ret = 195;
                                }

                            }
                            else {
                                if (value < 9379) {
                                    ret = 196;
                                }
                                else {
                                    ret = 197;
                                }

                            }

                        }

                    }

                }

            }

        }
        else {
            if (value < 25434) {
                if (value < 15713) {
                    if (value < 12350) {
                        if (value < 10762) {
                            if (value < 10047) {
                                ret = 198;

                            }
                            else {
                                if (value < 10398) {
                                    ret = 199;
                                }
                                else {
                                    ret = 200;
                                }

                            }

                        }
                        else {
                            if (value < 11529) {
                                if (value < 11139) {
                                    ret = 201;
                                }
                                else {
                                    ret = 202;
                                }

                            }
                            else {
                                if (value < 11932) {
                                    ret = 203;
                                }
                                else {
                                    ret = 204;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 13693) {
                            if (value < 12782) {
                                ret = 205;

                            }
                            else {
                                if (value < 13230) {
                                    ret = 206;
                                }
                                else {
                                    ret = 207;
                                }

                            }

                        }
                        else {
                            if (value < 14668) {
                                if (value < 14172) {
                                    ret = 208;
                                }
                                else {
                                    ret = 209;
                                }

                            }
                            else {
                                if (value < 15181) {
                                    ret = 210;
                                }
                                else {
                                    ret = 211;
                                }

                            }

                        }

                    }

                }
                else {
                    if (value < 19991) {
                        if (value < 17421) {
                            if (value < 16263) {
                                ret = 212;

                            }
                            else {
                                if (value < 16832) {
                                    ret = 213;
                                }
                                else {
                                    ret = 214;
                                }

                            }

                        }
                        else {
                            if (value < 18662) {
                                if (value < 18031) {
                                    ret = 215;
                                }
                                else {
                                    ret = 216;
                                }

                            }
                            else {
                                if (value < 19315) {
                                    ret = 217;
                                }
                                else {
                                    ret = 218;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 22165) {
                            if (value < 20691) {
                                ret = 219;

                            }
                            else {
                                if (value < 21415) {
                                    ret = 220;
                                }
                                else {
                                    ret = 221;
                                }

                            }

                        }
                        else {
                            if (value < 23743) {
                                if (value < 22940) {
                                    ret = 222;
                                }
                                else {
                                    ret = 223;
                                }

                            }
                            else {
                                if (value < 24574) {
                                    ret = 224;
                                }
                                else {
                                    ret = 225;
                                }

                            }

                        }

                    }

                }

            }
            else {
                if (value < 41171) {
                    if (value < 32360) {
                        if (value < 28200) {
                            if (value < 26325) {
                                ret = 226;

                            }
                            else {
                                if (value < 27246) {
                                    ret = 227;
                                }
                                else {
                                    ret = 228;
                                }

                            }

                        }
                        else {
                            if (value < 30208) {
                                if (value < 29187) {
                                    ret = 229;
                                }
                                else {
                                    ret = 230;
                                }

                            }
                            else {
                                if (value < 31265) {
                                    ret = 231;
                                }
                                else {
                                    ret = 232;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 35878) {
                            if (value < 33492) {
                                ret = 233;

                            }
                            else {
                                if (value < 34665) {
                                    ret = 234;
                                }
                                else {
                                    ret = 235;
                                }

                            }

                        }
                        else {
                            if (value < 38433) {
                                if (value < 37134) {
                                    ret = 236;
                                }
                                else {
                                    ret = 237;
                                }

                            }
                            else {
                                if (value < 39779) {
                                    ret = 238;
                                }
                                else {
                                    ret = 239;
                                }

                            }

                        }

                    }

                }
                else {
                    if (value < 52381) {
                        if (value < 45647) {
                            if (value < 42612) {
                                ret = 240;

                            }
                            else {
                                if (value < 44103) {
                                    ret = 241;
                                }
                                else {
                                    ret = 242;
                                }

                            }

                        }
                        else {
                            if (value < 48898) {
                                if (value < 47245) {
                                    ret = 243;
                                }
                                else {
                                    ret = 244;
                                }

                            }
                            else {
                                if (value < 50610) {
                                    ret = 245;
                                }
                                else {
                                    ret = 246;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 58076) {
                            if (value < 54214) {
                                ret = 247;

                            }
                            else {
                                if (value < 56112) {
                                    ret = 248;
                                }
                                else {
                                    ret = 249;
                                }

                            }

                        }
                        else {
                            if (value < 62212) {
                                if (value < 60108) {
                                    ret = 250;
                                }
                                else {
                                    ret = 251;
                                }

                            }
                            else {
                                if (value < 64390) {
                                    ret = 252;
                                }
                                else {
                                    ret = 253;
                                }

                            }

                        }

                    }

                }

            }

        }

    }
    return ret;
}

#endif // IRPACKER_SUPPORTS_PACK

uint16_t IrPacker::BitUnpack( uint8_t value )
{
    uint16_t ret;
    if (value < 142) {
        if (value < 86) {
            if (value < 58) {
                if (value < 44) {
                    if (value < 37) {
                        if (value < 33) {
                            if (value < 31) {
                                ret = 30;

                            }
                            else {
                                if (value < 32) {
                                    ret = 31;
                                }
                                else {
                                    ret = 32;
                                }

                            }

                        }
                        else {
                            if (value < 35) {
                                if (value < 34) {
                                    ret = 33;
                                }
                                else {
                                    ret = 34;
                                }

                            }
                            else {
                                if (value < 36) {
                                    ret = 35;
                                }
                                else {
                                    ret = 36;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 40) {
                            if (value < 38) {
                                ret = 38;

                            }
                            else {
                                if (value < 39) {
                                    ret = 39;
                                }
                                else {
                                    ret = 40;
                                }

                            }

                        }
                        else {
                            if (value < 42) {
                                if (value < 41) {
                                    ret = 42;
                                }
                                else {
                                    ret = 43;
                                }

                            }
                            else {
                                if (value < 43) {
                                    ret = 45;
                                }
                                else {
                                    ret = 46;
                                }

                            }

                        }

                    }

                }
                else {
                    if (value < 51) {
                        if (value < 47) {
                            if (value < 45) {
                                ret = 48;

                            }
                            else {
                                if (value < 46) {
                                    ret = 50;
                                }
                                else {
                                    ret = 52;
                                }

                            }

                        }
                        else {
                            if (value < 49) {
                                if (value < 48) {
                                    ret = 53;
                                }
                                else {
                                    ret = 55;
                                }

                            }
                            else {
                                if (value < 50) {
                                    ret = 57;
                                }
                                else {
                                    ret = 59;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 54) {
                            if (value < 52) {
                                ret = 61;

                            }
                            else {
                                if (value < 53) {
                                    ret = 63;
                                }
                                else {
                                    ret = 66;
                                }

                            }

                        }
                        else {
                            if (value < 56) {
                                if (value < 55) {
                                    ret = 68;
                                }
                                else {
                                    ret = 70;
                                }

                            }
                            else {
                                if (value < 57) {
                                    ret = 73;
                                }
                                else {
                                    ret = 75;
                                }

                            }

                        }

                    }

                }

            }
            else {
                if (value < 72) {
                    if (value < 65) {
                        if (value < 61) {
                            if (value < 59) {
                                ret = 78;

                            }
                            else {
                                if (value < 60) {
                                    ret = 81;
                                }
                                else {
                                    ret = 84;
                                }

                            }

                        }
                        else {
                            if (value < 63) {
                                if (value < 62) {
                                    ret = 87;
                                }
                                else {
                                    ret = 90;
                                }

                            }
                            else {
                                if (value < 64) {
                                    ret = 93;
                                }
                                else {
                                    ret = 96;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 68) {
                            if (value < 66) {
                                ret = 100;

                            }
                            else {
                                if (value < 67) {
                                    ret = 103;
                                }
                                else {
                                    ret = 107;
                                }

                            }

                        }
                        else {
                            if (value < 70) {
                                if (value < 69) {
                                    ret = 110;
                                }
                                else {
                                    ret = 114;
                                }

                            }
                            else {
                                if (value < 71) {
                                    ret = 118;
                                }
                                else {
                                    ret = 122;
                                }

                            }

                        }

                    }

                }
                else {
                    if (value < 79) {
                        if (value < 75) {
                            if (value < 73) {
                                ret = 127;

                            }
                            else {
                                if (value < 74) {
                                    ret = 131;
                                }
                                else {
                                    ret = 136;
                                }

                            }

                        }
                        else {
                            if (value < 77) {
                                if (value < 76) {
                                    ret = 141;
                                }
                                else {
                                    ret = 146;
                                }

                            }
                            else {
                                if (value < 78) {
                                    ret = 151;
                                }
                                else {
                                    ret = 156;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 82) {
                            if (value < 80) {
                                ret = 161;

                            }
                            else {
                                if (value < 81) {
                                    ret = 167;
                                }
                                else {
                                    ret = 173;
                                }

                            }

                        }
                        else {
                            if (value < 84) {
                                if (value < 83) {
                                    ret = 179;
                                }
                                else {
                                    ret = 185;
                                }

                            }
                            else {
                                if (value < 85) {
                                    ret = 192;
                                }
                                else {
                                    ret = 198;
                                }

                            }

                        }

                    }

                }

            }

        }
        else {
            if (value < 114) {
                if (value < 100) {
                    if (value < 93) {
                        if (value < 89) {
                            if (value < 87) {
                                ret = 205;

                            }
                            else {
                                if (value < 88) {
                                    ret = 213;
                                }
                                else {
                                    ret = 220;
                                }

                            }

                        }
                        else {
                            if (value < 91) {
                                if (value < 90) {
                                    ret = 228;
                                }
                                else {
                                    ret = 236;
                                }

                            }
                            else {
                                if (value < 92) {
                                    ret = 244;
                                }
                                else {
                                    ret = 253;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 96) {
                            if (value < 94) {
                                ret = 262;

                            }
                            else {
                                if (value < 95) {
                                    ret = 271;
                                }
                                else {
                                    ret = 280;
                                }

                            }

                        }
                        else {
                            if (value < 98) {
                                if (value < 97) {
                                    ret = 290;
                                }
                                else {
                                    ret = 300;
                                }

                            }
                            else {
                                if (value < 99) {
                                    ret = 311;
                                }
                                else {
                                    ret = 322;
                                }

                            }

                        }

                    }

                }
                else {
                    if (value < 107) {
                        if (value < 103) {
                            if (value < 101) {
                                ret = 333;

                            }
                            else {
                                if (value < 102) {
                                    ret = 345;
                                }
                                else {
                                    ret = 357;
                                }

                            }

                        }
                        else {
                            if (value < 105) {
                                if (value < 104) {
                                    ret = 369;
                                }
                                else {
                                    ret = 382;
                                }

                            }
                            else {
                                if (value < 106) {
                                    ret = 395;
                                }
                                else {
                                    ret = 409;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 110) {
                            if (value < 108) {
                                ret = 424;

                            }
                            else {
                                if (value < 109) {
                                    ret = 439;
                                }
                                else {
                                    ret = 454;
                                }

                            }

                        }
                        else {
                            if (value < 112) {
                                if (value < 111) {
                                    ret = 470;
                                }
                                else {
                                    ret = 486;
                                }

                            }
                            else {
                                if (value < 113) {
                                    ret = 503;
                                }
                                else {
                                    ret = 521;
                                }

                            }

                        }

                    }

                }

            }
            else {
                if (value < 128) {
                    if (value < 121) {
                        if (value < 117) {
                            if (value < 115) {
                                ret = 539;

                            }
                            else {
                                if (value < 116) {
                                    ret = 558;
                                }
                                else {
                                    ret = 578;
                                }

                            }

                        }
                        else {
                            if (value < 119) {
                                if (value < 118) {
                                    ret = 598;
                                }
                                else {
                                    ret = 619;
                                }

                            }
                            else {
                                if (value < 120) {
                                    ret = 640;
                                }
                                else {
                                    ret = 663;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 124) {
                            if (value < 122) {
                                ret = 686;

                            }
                            else {
                                if (value < 123) {
                                    ret = 710;
                                }
                                else {
                                    ret = 735;
                                }

                            }

                        }
                        else {
                            if (value < 126) {
                                if (value < 125) {
                                    ret = 761;
                                }
                                else {
                                    ret = 787;
                                }

                            }
                            else {
                                if (value < 127) {
                                    ret = 815;
                                }
                                else {
                                    ret = 843;
                                }

                            }

                        }

                    }

                }
                else {
                    if (value < 135) {
                        if (value < 131) {
                            if (value < 129) {
                                ret = 873;

                            }
                            else {
                                if (value < 130) {
                                    ret = 904;
                                }
                                else {
                                    ret = 935;
                                }

                            }

                        }
                        else {
                            if (value < 133) {
                                if (value < 132) {
                                    ret = 968;
                                }
                                else {
                                    ret = 1002;
                                }

                            }
                            else {
                                if (value < 134) {
                                    ret = 1037;
                                }
                                else {
                                    ret = 1073;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 138) {
                            if (value < 136) {
                                ret = 1111;

                            }
                            else {
                                if (value < 137) {
                                    ret = 1150;
                                }
                                else {
                                    ret = 1190;
                                }

                            }

                        }
                        else {
                            if (value < 140) {
                                if (value < 139) {
                                    ret = 1232;
                                }
                                else {
                                    ret = 1275;
                                }

                            }
                            else {
                                if (value < 141) {
                                    ret = 1319;
                                }
                                else {
                                    ret = 1366;
                                }

                            }

                        }

                    }

                }

            }

        }

    }
    else {
        if (value < 198) {
            if (value < 170) {
                if (value < 156) {
                    if (value < 149) {
                        if (value < 145) {
                            if (value < 143) {
                                ret = 1413;

                            }
                            else {
                                if (value < 144) {
                                    ret = 1463;
                                }
                                else {
                                    ret = 1514;
                                }

                            }

                        }
                        else {
                            if (value < 147) {
                                if (value < 146) {
                                    ret = 1567;
                                }
                                else {
                                    ret = 1622;
                                }

                            }
                            else {
                                if (value < 148) {
                                    ret = 1679;
                                }
                                else {
                                    ret = 1738;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 152) {
                            if (value < 150) {
                                ret = 1798;

                            }
                            else {
                                if (value < 151) {
                                    ret = 1861;
                                }
                                else {
                                    ret = 1927;
                                }

                            }

                        }
                        else {
                            if (value < 154) {
                                if (value < 153) {
                                    ret = 1994;
                                }
                                else {
                                    ret = 2064;
                                }

                            }
                            else {
                                if (value < 155) {
                                    ret = 2136;
                                }
                                else {
                                    ret = 2211;
                                }

                            }

                        }

                    }

                }
                else {
                    if (value < 163) {
                        if (value < 159) {
                            if (value < 157) {
                                ret = 2288;

                            }
                            else {
                                if (value < 158) {
                                    ret = 2368;
                                }
                                else {
                                    ret = 2451;
                                }

                            }

                        }
                        else {
                            if (value < 161) {
                                if (value < 160) {
                                    ret = 2537;
                                }
                                else {
                                    ret = 2626;
                                }

                            }
                            else {
                                if (value < 162) {
                                    ret = 2718;
                                }
                                else {
                                    ret = 2813;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 166) {
                            if (value < 164) {
                                ret = 2911;

                            }
                            else {
                                if (value < 165) {
                                    ret = 3013;
                                }
                                else {
                                    ret = 3119;
                                }

                            }

                        }
                        else {
                            if (value < 168) {
                                if (value < 167) {
                                    ret = 3228;
                                }
                                else {
                                    ret = 3341;
                                }

                            }
                            else {
                                if (value < 169) {
                                    ret = 3458;
                                }
                                else {
                                    ret = 3579;
                                }

                            }

                        }

                    }

                }

            }
            else {
                if (value < 184) {
                    if (value < 177) {
                        if (value < 173) {
                            if (value < 171) {
                                ret = 3704;

                            }
                            else {
                                if (value < 172) {
                                    ret = 3834;
                                }
                                else {
                                    ret = 3968;
                                }

                            }

                        }
                        else {
                            if (value < 175) {
                                if (value < 174) {
                                    ret = 4107;
                                }
                                else {
                                    ret = 4251;
                                }

                            }
                            else {
                                if (value < 176) {
                                    ret = 4400;
                                }
                                else {
                                    ret = 4554;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 180) {
                            if (value < 178) {
                                ret = 4713;

                            }
                            else {
                                if (value < 179) {
                                    ret = 4878;
                                }
                                else {
                                    ret = 5049;
                                }

                            }

                        }
                        else {
                            if (value < 182) {
                                if (value < 181) {
                                    ret = 5226;
                                }
                                else {
                                    ret = 5408;
                                }

                            }
                            else {
                                if (value < 183) {
                                    ret = 5598;
                                }
                                else {
                                    ret = 5794;
                                }

                            }

                        }

                    }

                }
                else {
                    if (value < 191) {
                        if (value < 187) {
                            if (value < 185) {
                                ret = 5997;

                            }
                            else {
                                if (value < 186) {
                                    ret = 6206;
                                }
                                else {
                                    ret = 6424;
                                }

                            }

                        }
                        else {
                            if (value < 189) {
                                if (value < 188) {
                                    ret = 6648;
                                }
                                else {
                                    ret = 6881;
                                }

                            }
                            else {
                                if (value < 190) {
                                    ret = 7122;
                                }
                                else {
                                    ret = 7371;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 194) {
                            if (value < 192) {
                                ret = 7629;

                            }
                            else {
                                if (value < 193) {
                                    ret = 7896;
                                }
                                else {
                                    ret = 8173;
                                }

                            }

                        }
                        else {
                            if (value < 196) {
                                if (value < 195) {
                                    ret = 8459;
                                }
                                else {
                                    ret = 8755;
                                }

                            }
                            else {
                                if (value < 197) {
                                    ret = 9061;
                                }
                                else {
                                    ret = 9379;
                                }

                            }

                        }

                    }

                }

            }

        }
        else {
            if (value < 226) {
                if (value < 212) {
                    if (value < 205) {
                        if (value < 201) {
                            if (value < 199) {
                                ret = 9707;

                            }
                            else {
                                if (value < 200) {
                                    ret = 10047;
                                }
                                else {
                                    ret = 10398;
                                }

                            }

                        }
                        else {
                            if (value < 203) {
                                if (value < 202) {
                                    ret = 10762;
                                }
                                else {
                                    ret = 11139;
                                }

                            }
                            else {
                                if (value < 204) {
                                    ret = 11529;
                                }
                                else {
                                    ret = 11932;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 208) {
                            if (value < 206) {
                                ret = 12350;

                            }
                            else {
                                if (value < 207) {
                                    ret = 12782;
                                }
                                else {
                                    ret = 13230;
                                }

                            }

                        }
                        else {
                            if (value < 210) {
                                if (value < 209) {
                                    ret = 13693;
                                }
                                else {
                                    ret = 14172;
                                }

                            }
                            else {
                                if (value < 211) {
                                    ret = 14668;
                                }
                                else {
                                    ret = 15181;
                                }

                            }

                        }

                    }

                }
                else {
                    if (value < 219) {
                        if (value < 215) {
                            if (value < 213) {
                                ret = 15713;

                            }
                            else {
                                if (value < 214) {
                                    ret = 16263;
                                }
                                else {
                                    ret = 16832;
                                }

                            }

                        }
                        else {
                            if (value < 217) {
                                if (value < 216) {
                                    ret = 17421;
                                }
                                else {
                                    ret = 18031;
                                }

                            }
                            else {
                                if (value < 218) {
                                    ret = 18662;
                                }
                                else {
                                    ret = 19315;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 222) {
                            if (value < 220) {
                                ret = 19991;

                            }
                            else {
                                if (value < 221) {
                                    ret = 20691;
                                }
                                else {
                                    ret = 21415;
                                }

                            }

                        }
                        else {
                            if (value < 224) {
                                if (value < 223) {
                                    ret = 22165;
                                }
                                else {
                                    ret = 22940;
                                }

                            }
                            else {
                                if (value < 225) {
                                    ret = 23743;
                                }
                                else {
                                    ret = 24574;
                                }

                            }

                        }

                    }

                }

            }
            else {
                if (value < 240) {
                    if (value < 233) {
                        if (value < 229) {
                            if (value < 227) {
                                ret = 25434;

                            }
                            else {
                                if (value < 228) {
                                    ret = 26325;
                                }
                                else {
                                    ret = 27246;
                                }

                            }

                        }
                        else {
                            if (value < 231) {
                                if (value < 230) {
                                    ret = 28200;
                                }
                                else {
                                    ret = 29187;
                                }

                            }
                            else {
                                if (value < 232) {
                                    ret = 30208;
                                }
                                else {
                                    ret = 31265;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 236) {
                            if (value < 234) {
                                ret = 32360;

                            }
                            else {
                                if (value < 235) {
                                    ret = 33492;
                                }
                                else {
                                    ret = 34665;
                                }

                            }

                        }
                        else {
                            if (value < 238) {
                                if (value < 237) {
                                    ret = 35878;
                                }
                                else {
                                    ret = 37134;
                                }

                            }
                            else {
                                if (value < 239) {
                                    ret = 38433;
                                }
                                else {
                                    ret = 39779;
                                }

                            }

                        }

                    }

                }
                else {
                    if (value < 247) {
                        if (value < 243) {
                            if (value < 241) {
                                ret = 41171;

                            }
                            else {
                                if (value < 242) {
                                    ret = 42612;
                                }
                                else {
                                    ret = 44103;
                                }

                            }

                        }
                        else {
                            if (value < 245) {
                                if (value < 244) {
                                    ret = 45647;
                                }
                                else {
                                    ret = 47245;
                                }

                            }
                            else {
                                if (value < 246) {
                                    ret = 48898;
                                }
                                else {
                                    ret = 50610;
                                }

                            }

                        }

                    }
                    else {
                        if (value < 250) {
                            if (value < 248) {
                                ret = 52381;

                            }
                            else {
                                if (value < 249) {
                                    ret = 54214;
                                }
                                else {
                                    ret = 56112;
                                }

                            }

                        }
                        else {
                            if (value < 252) {
                                if (value < 251) {
                                    ret = 58076;
                                }
                                else {
                                    ret = 60108;
                                }

                            }
                            else {
                                if (value < 253) {
                                    ret = 62212;
                                }
                                else {
                                    ret = 64390;
                                }

                            }

                        }

                    }

                }

            }

        }

    }
    return ret;
}
