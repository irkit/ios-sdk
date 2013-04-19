/*----------------------------------------------------------------------------/
/  IR_CTRL - IR remote control module  R0.01                  (C)ChaN, 2008
/-----------------------------------------------------------------------------/
/  Common include file for IR_CTRL module and application
/----------------------------------------------------------------------------*/

#include <stdint.h>

/* Put hardware dependent include files here */
#include <avr/io.h>
#include <avr/interrupt.h>


/* Enable/Disable transmission/reception functions <1/0> */
#define IR_USE_XMIT     1
#define IR_USE_RCVR     1
#define IR_USE_NEC      1
#define IR_USE_AEHA     1
#define IR_USE_SONY     1


/* Structure of IR function work area */
typedef struct _irstruct {
	uint8_t state;		/* Communication state */
	uint8_t fmt;		/* Frame format */
	uint8_t len;		/* Number of bits received */
	uint8_t phase;		/* Bit counter */
	uint8_t buff[28];	/* Data buffer */
} IR_STRUCT;

/* The work area for IR_CTRL is defined in ir_ctrl.c */
extern
volatile IR_STRUCT IrCtrl;

/* IR control state (state) */
#define IR_IDLE	0	/* In idle state, ready to receive/transmit */
#define IR_RECVING  1	/* An IR frame is being received */
#define IR_RECVED   2	/* An IR frame has been received and data is valid */
#define IR_XMIT     3	/* IR transmission is initiated */
#define IR_XMITING  4	/* IR transmission is in progress */

/* Format ID (fmt) */
#define REPT    0x01
#define NEC     0x02
#define AEHA    0x04
#define SONY    0x08

/* Prototypes */
void IR_initialize (void);
int IR_xmit (uint8_t, const uint8_t*, uint8_t);
