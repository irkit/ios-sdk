#include "Bounce.h"
#include "IrCtrl.h"

int PIN_LED      = 13;
int PIN_IR_IN    =  8; // PB0 ICP1 Counter1
int PIN_IR_OUT   =  3; // PD3 OC2B Timer2
int PIN_BUTTON_1 =  2;
int PIN_TEST_OUT =  7;

Bounce button1 = Bounce(20, PIN_BUTTON_1);

void setup()
{
    Serial.begin(115200);

    pinMode(PIN_LED,           OUTPUT);

    pinMode(PIN_BUTTON_1,      INPUT);
    digitalWrite(PIN_BUTTON_1, HIGH); // pull-up

    pinMode(PIN_IR_OUT,        OUTPUT);

    pinMode(PIN_IR_IN,         INPUT);
    digitalWrite(PIN_IR_IN,    HIGH); // pull-up

    pinMode(PIN_TEST_OUT,      OUTPUT);
    digitalWrite(PIN_TEST_OUT, HIGH); // pull-up

    IR_initialize();

    Serial.println("IR remote control test program");
}

void ir_recv_loop(void)
{
    if(IrCtrl.state!=IR_RECVED){
        return;
    }

    uint8_t d, i, l;
    uint16_t a;

    l = IrCtrl.len;
    switch (IrCtrl.fmt) {	/* Which frame arrived? */
#if IR_USE_NEC
    case NEC:	/* NEC format data frame */
        if (l == 32) {	/* Only 32-bit frame is valid */
            Serial.print("N ");
            Serial.print(IrCtrl.buff[0], HEX); Serial.print(" ");
            Serial.print(IrCtrl.buff[1], HEX); Serial.print(" ");
            Serial.print(IrCtrl.buff[2], HEX); Serial.print(" ");
            Serial.print(IrCtrl.buff[3], HEX); Serial.println();
        }
        break;
    case NEC|REPT:	/* NEC repeat frame */
        Serial.println("N repeat");
        break;
#endif
#if IR_USE_AEHA
    case AEHA:		/* AEHA format data frame */
        if ((l >= 48) && (l % 8 == 0)) {	/* Only multiple of 8 bit frame is valid */
            Serial.print("A");
            l /= 8;
            for (i = 0; i < l; i++){
                Serial.print(" ");
                Serial.print(IrCtrl.buff[i], HEX);
            }
            Serial.println();
        }
        break;
    case AEHA|REPT:	/* AEHA format repeat frame */
        Serial.println("A repeat");
        break;
#endif
#if IR_USE_SONY
    case SONY:
        d = IrCtrl.buff[0];
        a = ((uint16_t)IrCtrl.buff[2] << 9) + ((uint16_t)IrCtrl.buff[1] << 1) + ((d & 0x80) ? 1 : 0);
        d &= 0x7F;
        switch (l) {	/* Only 12, 15 or 20 bit frames are valid */
        case 12:
            //xprintf(PSTR("S12 %u %u\n"), d, a & 0x1F);
            Serial.print("S12 ");
            Serial.print(d, HEX);        Serial.print(" ");
            Serial.print(a & 0x1F, HEX); Serial.println();
            break;
        case 15:
            //xprintf(PSTR("S15 %u %u\n"), d, a & 0xFF);
            Serial.print("S15 ");
            Serial.print(d, HEX);        Serial.print(" ");
            Serial.print(a & 0xFF, HEX); Serial.println();
            break;
        case 20:
            //xprintf(PSTR("S20 %u %u\n"), d, a & 0x1FFF);
            Serial.print("S20 ");
            Serial.print(d, HEX);        Serial.print(" ");
            Serial.print(a & 0x1FFF, HEX); Serial.println();
            break;
        }
        break;
#endif
    }
    IrCtrl.state = IR_IDLE;		/* Ready to receive next frame */
}

void loop()
{
    // digitalWrite(PIN_LED, !digitalRead(PIN_IR));

    ir_recv_loop();

    if(button1.update() && !button1.read()){
        if (IR_xmit(AEHA, (uint8_t*)"\xAA\x5A\x8F\x12\x14\xF1", 6*8)){
            Serial.println("OK AQUOS VOLUME UP");
        }
    }
}
