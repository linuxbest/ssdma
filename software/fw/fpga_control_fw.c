/*----------------------------------------------------------------------------*\
|                                                                              |
| Copyright (C) 2003,  James A. Cureington                                     |
|                      tonycu * users_sourceforge_net                          |
|                                                                              |
| This program is free software; you can redistribute it and/or                |
| modify it under the terms of the GNU General Public License                  |
| as published by the Free Software Foundation; either version 2               |
| of the License, or any later version.                                        |
|                                                                              |
| This program is distributed in the hope that it will be useful,              |
| but WITHOUT ANY WARRANTY; without even the implied warranty of               |
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                |
| GNU General Public License for more details.                                 |
|                                                                              |
| You should have received a copy of the GNU General Public License            |
| along with this program; if not, write to the Free Software                  |
| Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.                    |
|                                                                              |
|                                                                              |
| Tony Cureington                                                              |
| November 30, 2002                                                            |
|                                                                              |
|                                                                              |
| This file is associated with the ezusb2131 Linux downloader project. The     |
| project can be found at http://ezusb2131.sourceforge.net.                    |
|                                                                              |
|  this file derived from pp.c                                                 |
|                                                                              |
|  pp.c Copyright (C) 2002, Michael Hetherington                               |
|  chinook * pacific_net_sg                                                    |
|                                                                              |
|  pp.c based on sunkbd_hid.c                                                  |
|  sunkbd_hid.c Copyright (C) 2001, Arnim Laeuger                              |
|  arnim * users_sourceforge_net                                               |
|                                                                              |
|  :set tabstop=3                                                              |
|  :set softtabstop=3                                                          |
|  :set shiftwidth=3                                                           |
|  :set smarttab                                                               |
|  :mkv ~/.vimrc                                                               |
|                                                                              |
|  X:set expandtab                                                             |
|                                                                              |
\*----------------------------------------------------------------------------*/

/*******************************************************************************
 *
 * $Id: cam_control_fw.c,v 1.1 2003/02/21 06:50:35 tonycu Exp $
 *
 ******************************************************************************/


#include <stdio.h>
#include <string.h>
#include <8051.h>
#include "fpga_common.h"
#include "fpga_control_fw.h"

#include "../include/fw.h"

#define HEART_BEAT_A7	0	/* only one of the "BEAT" define should be true */
#define HEART_BEAT_C3	0	/* at one time                                  */
#define DATA_BEAT_A7		0
#define DATA_BEAT_C3		1

#define DELAY_PER_PERIOD	0	/* number of extra servo periods per degree
								 * of movement - makes the servo move slower
								 */
extern void wait_msec(unsigned short);

static xdata setup_data * data sdata = (xdata setup_data *)&SETUPDAT;

static xdata ep1_command * data ep = (xdata ep1_command *)&OUT1BUF;
static xdata ep1_info * data ep1_in = (xdata ep1_info *)&IN1BUF;
static xdata ep2_command * data ep2_out = (xdata ep2_command *)&OUT2BUF;

idata static unsigned short center_usecs;
idata static unsigned short pulse_frequency;

idata static unsigned char ep3_sizeH, sizeH;
idata static unsigned char ep3_sizeL, sizeL;

idata static volatile char timer1_action;
idata unsigned volatile short usecs;
idata unsigned volatile short timer1_usecs_remaining;
idata static byte th1_remaining;
idata static byte tl1_remaining;
idata static unsigned char FPGA_STATUS;

/* below vars are assigned only in timer0_isr, the are global only */
/* for other functions to read - not write!                        */
idata static short current_horizontal_pos;
idata static short current_vertical_pos;

idata static char ep1in_pending;
idata static char ep2in_pending;
idata static char ep4in_pending;
idata static char ep6in_pending;

#if DELAY_PER_PERIOD
idata char servo_delay_count;
#endif /* DELAY_PER_PERIOD */

/* blink port A7 the number of specified times      */
/* with a one second pause between the number of    */
/* specified blinks - used for debugging            */
#if 1 /* EZUSB_DEBUG */
static void
blink_portA7(unsigned char blinks, unsigned char forever)
{
	unsigned int i;

	PORTACFG &= ~0x80;
	OEA |= 0x80;

	do {
		for (i=0; i < (blinks*2); i++) {
			if (i%2) {
				OUTA &= ~0x80; /* off */
			} else {
				OUTA |= 0x80; /* on  */
			}
			wait_msec(1000);
		}
		OUTA &= ~0x80; /* off */
		wait_msec(2000);
	} while (forever);

	return; /* not reached */
}
#endif /* EZUSB_DEBUG */


/****************************************************
 * get_descriptor()
 * see TRM v1.9 page 7-12 (133) for info on Get_Descriptor 
 * requests
 ****************************************************/
static void 
get_descriptor(void) using 1
{
	switch (sdata->wValueH) {
		case GET_DEVICE_DESCRIPTOR:
			CLEAR_HSNAK(); /* clr hsnak first, per TRM v1.9 page 7-14 (135) */
			SUDPTRH = HI_BYTE(dev_desc);
			SUDPTRL = LOW_BYTE(dev_desc);
			break;

		case GET_CONFIG_DESCRIPTOR:
			CLEAR_HSNAK();
			SUDPTRH = HI_BYTE(conf_desc);
			SUDPTRL = LOW_BYTE(conf_desc);
			break;

		case GET_STRING_DESCRIPTOR:
			if (sdata->wValueL < NUM_STRINGS) {
				CLEAR_HSNAK();
				SUDPTRH = HI_BYTE(string_index[sdata->wValueL]);
				SUDPTRL = LOW_BYTE(string_index[sdata->wValueL]);
			} else {
				EP0_STALL();
			}
			break;   

		default:
			EP0_STALL();
			break;
  }
}


/****************************************************
 * get_status()
 ****************************************************/
static void 
get_status(void) using 1
{
	switch (sdata->bmRequestType) {
					 /* device status */
		case 0x80:
			/* bus powered/no wakeup */
			in0buf[0] = 0;
			in0buf[1] = 0;
			IN0BC = 0x02;
			CLEAR_HSNAK();
			break;

		/* interface status */
		case 0x81:
			if(sdata->wIndexL == 0){
				in0buf[0] = 0;
				in0buf[1] = 0;
				IN0BC = 0x02;
				CLEAR_HSNAK();
			} else {
				EP0_STALL();
			}
			break;

		/* endpoint status */
		case 0x82:
			switch (sdata->wIndexL) {
				/* endpoint 0 IN/OUT */
				case 0x00:
				case 0x80:
					in0buf[0] = 0;
					in0buf[1] = 0;
					IN0BC = 0x02;
					CLEAR_HSNAK();
					break;

				/* endpoint 1 IN/OUT */
				case 0x01:
				case 0x81:
					in0buf[0] = 0;
					in0buf[1] = 0;
					IN0BC = 0x02;
					CLEAR_HSNAK();
					break;

				default:
					EP0_STALL();
					break;
			}
			break;

		default:
			EP0_STALL();
			break;
	}
}


/****************************************************
 * set_interface()
 ****************************************************/
static void 
set_interface(void) using 1
{
	/* below is left here as a place holder... */
#ifdef DONT_DO
  /* only one interface supported */
  if (sdata->bmRequestType == 0x01 && sdata->wIndexL == 0x00) {
	switch (sdata->wValueL) {
		 case 0x00:
			 TOGCTL      = 0x01; /* select endpoint 1 OUT */
			 TOGCTL      = 0x21; /* toggle */
			 OUT1BC      = 0x00; /* write any value */
		
			 TOGCTL      = 0x12; /* select endpoint 2 IN */
			 TOGCTL      = 0x32; /* toggle */
			 IN2CS      |= 0x02; /* clear busy bit */
		
			 TOGCTL      = 0x14; /* select endpoint 4 IN */
			 TOGCTL      = 0x34; /* toggle */
			 IN4CS      |= 0x02; /* clear busy bit */
			 CLEAR_HSNAK();
			 break;
		 default:
			 EP0_STALL();
			 break;
	}
  } else {
	 EP0_STALL();
  }
#else  /* DONT_DO */
  EP0_STALL();
#endif /* DONT_DO */

}


/****************************************************
 * send cc_info struct in ep0in buffer
 ****************************************************/
void
send_cc_info(void)
{
	if (IN1CS & 0x02) {
		/* buffer is busy (being used by SIE?) */
		ep1in_pending = 1;
		return;
	}

	ep1_in->control = EP1_INFO;
	
	ep1_in->PINSA = PINSA;
	ep1_in->OEA = OEA;
	ep1_in->OUTA = OUTA;
	ep1_in->PORTACFG = PORTACFG;
	
	ep1_in->PINSC = PINSC;
	ep1_in->OEC = OEC;
	ep1_in->OUTC = OUTC;
	ep1_in->PORTCCFG = PORTCCFG;

	ep1_in->FASTXFR = FASTXFR;
	ep1_in->CKCON = CKCON;

	ep1_in->sizeH = sizeH;
	ep1_in->sizeL = sizeL;

    ep1_in->FPGA_STATUS = FPGA_STATUS;
    
    ep1_in->FIFO_RD = PINSC & FPGA_FIFO_RD;

    ep1_in->MAGIC = 0xAA;

	IN1BC = sizeof(ep1_info);
}

/****************************************************
 * endpoint0_out()
 * process command from host
 * the pwm_message is handled in timer0_isr
 ****************************************************/
void
endpoint1_out(void)
{
	/* PORT A */
	if (ep->control & E_OEA)
		OEA = ep->OEA;
	if (ep->control & E_OUTA)
		OUTA = ep->OUTA;
	if (ep->control & E_ACFG)
		PORTACFG = ep->PORTACFG;

	/* PORT C */
	if (ep->control & E_OEC)
		OEC = ep->OEC;
	if (ep->control & E_OUTC)
		OUTC = ep->OUTC;
	if (ep->control & E_CCFG)
		PORTCCFG = ep->PORTCCFG;
	if (ep->tog_control & E_CKCON) 
		CKCON = ep->CKCON;
	if (ep->tog_control & E_FASTXFR)
		FASTXFR = ep->FASTXFR;
	if (ep->tog_control & (TOG_INIT | TOG_EXIT)) {
		int i;
		for(i = 0; i < 7; i++) {
			TOGCTL = 0x10 + i;
			TOGCTL = 0x30 + i;
			TOGCTL = i;           // clear EP in toggle
			// clear EP out toggle (only if console app exited)
			if (ep->tog_control & TOG_EXIT)
				TOGCTL = 0x20 + i;
		}
		return;
	}

	if (ep->control & EP1_INFO)
		send_cc_info();
}

static xdata unsigned char * ep2_in = (xdata unsigned char *)&IN2BUF;

xdata at 0x8000 unsigned char FIFO;

void 
send_ep2_info(void)
{
	unsigned char len, i = 0;
	
	if (IN2CS & 0x02) {
		/* buffer is busy (being used by SIE?) */
		ep2in_pending = 1;
		return;
	}
	AUTOPTRH = 0x7e;
	AUTOPTRL = 0x02;
    len = 64 - 2;
    while (i < len) {
        if (!(PINSC & FPGA_FIFO_RD))
            break;
        _asm
            mov   dptr,#0x7fe5; /* AUTODATA */
            movx  @dptr,a 
        _endasm;
        i ++;
    }
    ep2_in[0] = 0xAA;
    ep2_in[1] = i;
    ep2in_pending = PINSC & FPGA_FIFO_RD;
	IN2BC = i + 2;
}
void send_ep4_data(void);

void
endpoint2_out(void)
{
	/* reset the FPGA fifo */
	sizeH = 0;
	sizeL = 0;
	if (ep2_out->control & TO_FIFO) {
		/* nothing to do */
	} else if (ep2_out->control & FROM_FIFO) {
		send_ep2_info();
	} 
}

static void
endpoint3_out(void)
{
	unsigned char len;

	len = OUT3BC / 8;
	AUTOPTRH = 0x7D;
	AUTOPTRL = 0x40;

	while (len) {
        _asm
            mov   dptr,#0x7fe5; /* AUTODATA */
            movx  a,@dptr 
            movx  a,@dptr
            movx  a,@dptr 
            movx  a,@dptr
            movx  a,@dptr 
            movx  a,@dptr
            movx  a,@dptr 
            movx  a,@dptr
        _endasm;
		len --;
	}
}

void
endpoint5_out(void)
{
	unsigned char len;

	len = OUT5BC;
	AUTOPTRH = HI_BYTE(OUT5BUF);
	AUTOPTRL = LOW_BYTE(OUT5BUF);

	while (len > 0) {
		FIFO = AUTODATA;
		len --;
	}
}

/* read i2c data */
void send_ep4_data()
{
    ep4_data *ep = &IN4BUF;

    if (IN4CS & 0x02) {
		/* buffer is busy (being used by SIE?) */
		ep4in_pending = 1;
		return;
	}

    ep->I2CS = I2CS;
    ep->I2DAT = I2DAT;

	IN4BC = sizeof(*ep);
}

/* write */
void 
endpoint4_out(void)
{
    ep4_command *ep = &OUT4BUF;
   
    if (ep->control & E_I2CS)
        I2CS = ep->I2CS;
    if (ep->control & E_I2DAT){
        I2DAT = ep->I2DAT;
        while((I2CS & I2DONE) == 0);
    }
    if (ep->control & E_READ)
        send_ep4_data();
}

unsigned char ep6in_len;

/* this idea take from PonyProg2000 spi-bus.* */
/* set clk line to 0 */
static void spi_clearSCK(void)
{
    OUTA &= ~FPGA_CCLK;
}
/* set clk line to 1 */
static void spi_setSCK(void)
{
    OUTA |= FPGA_CCLK;
}

/* out the bit to DI */
static void spi_bitMOSI(int b)
{
    FIFO = b ? (1<<3) : 0;
}

static void spi_setMOSI(void)
{
    spi_bitMOSI(1);
}

/* read the bit from DO */
static unsigned char spi_getMISO(void)
{
    return FIFO & 1;
}

static void spi_ClearReset(void)
{
    OEC &= ~SPI_SEL;
}

static void spi_SetReset(void)
{
    OEC |= SPI_SEL;
}

static unsigned char spi_RecDataBit(void)
{
    unsigned char b;

    spi_clearSCK();
    //wait_msec(1);
    spi_setSCK();
    //wait_msec(1);
    b = spi_getMISO();
    spi_clearSCK();

    return b;
}
           
static void spi_sendDataBit(int b)
{
    spi_clearSCK();
    spi_bitMOSI(b);
    //wait_msec(1);
    spi_setSCK();
    //wait_msec(1);
    spi_clearSCK();
}
static void spi_send_byte(unsigned char t)
{
    char i;

    spi_clearSCK();
    for (i = 7; i >= 0; i --)
        spi_sendDataBit(t & (1<<i));
    spi_setMOSI();

}
static unsigned char spi_recv_byte(void)
{
    char i;
    unsigned char t = 0;

    spi_clearSCK();
    for (i = 7; i >= 0; i--)
        if (spi_RecDataBit())
            t |= (1<<i);
    spi_setMOSI();

    return t;
}
/*
 * read spi 
 */
void send_ep6_data()
{
    ep6_data *ep = &IN6BUF;
    unsigned char j;

    if (IN6CS & 0x02) {
		/* buffer is busy (being used by SIE?) */
		ep6in_pending = 1;
		return;
	}
    ep->dlen = ep6in_len;
    PORTACFG &= ~FPGA_CCLK;

    for (j = 0; j < ep->dlen; j++) {
        ep->buf[j] = spi_recv_byte();
    }
    PORTACFG |= FPGA_CCLK;

    /* Head + Buffer len */
	IN6BC = 1 + ep6in_len;
}

/* 210 * 128 * 64 = 210K byte */
static void spi_read_data(void)
{
    unsigned char size = 200;
    /* from 0x7b40 we have 1024 byte data */
    while (size) {
        char len = 8;
        AUTOPTRH = 0x7B; AUTOPTRL = 0x40;
        while (len) {
            char j = 128;
            while (j) {
                _asm
                    mov   dptr,#0x7fe5; /* AUTODATA */
                    movx  a,@dptr movx  a,@dptr
                    movx  a,@dptr movx  a,@dptr
                    movx  a,@dptr movx  a,@dptr
                    movx  a,@dptr movx  a,@dptr
                    movx  a,@dptr movx  a,@dptr
                    movx  a,@dptr movx  a,@dptr
                    movx  a,@dptr movx  a,@dptr
                    movx  a,@dptr movx  a,@dptr
                _endasm;
                j--;
            }
            len --;
        }
        size --;
    }
}

void spi_read_flash(void)
{
    OUTC &= ~FPGA_PROG_M0; 

    PORTACFG &= ~FPGA_CCLK;
    spi_send_byte(3); 
    spi_send_byte(0); 
    spi_send_byte(0); 
    spi_send_byte(0);
    PORTACFG |= FPGA_CCLK;

    spi_read_data();
    
    if ((PINSC & FPGA_DONE)) {
        FPGA_STATUS |= FPGA_BOOT;
    }
}

void 
spi_reset(void)
{
    OEC |= SPI_SEL;

    spi_clearSCK();
    spi_setMOSI();

    /* device reset */
    OUTC |= SPI_SEL;
    wait_msec(1);
    OUTC &= ~SPI_SEL;
    wait_msec(1);

    OUTC |= SPI_SEL;
}
/*
 * Set the PROGRAM signal low.
 * Check that the DONE and INIT are both LOW
 * Set the PROGRAM signal high
 * Wait for INIT to go HIGH
 * Wait 5 more microseconds
 * Start sending data
 */
static void 
spi_boot_fpga(int serial)
{
    spi_reset();

    /* LOW M0 */
    OEC |= FPGA_PROG_M0 | FPGA_PROG_B;
    OEC &= ~FPGA_INIT_B;
    OEC &= ~FPGA_DONE;
    
    /* LOW PROGB */
    OUTC &= ~FPGA_PROG_B;
    wait_msec(100);
    
    FPGA_STATUS = 0;

    if (PINSC & FPGA_INIT_B) {
        FPGA_STATUS |= ERR_INIT_B;
        goto out;
    }
    if (PINSC & FPGA_DONE) {
        FPGA_STATUS |= ERR_DONE;
        goto out;
    }

    if (serial)
        OUTC |= FPGA_PROG_M0;
    else
        OUTC &= ~FPGA_PROG_M0;
    
    /* HIGH PROG_B */
    OUTC |= FPGA_PROG_B;

    /* Wait for INIT_B to High
     * sample the M0-3 to select mode
     */ 
    while ((PINSC & FPGA_INIT_B) == 0) {
        wait_msec(1); 
    }
    OUTC |= FPGA_PROG_M0;

    /*spi_read_flash();*/

out:
}

/* 
 * write spi 
 */
static void 
endpoint6_out(void)
{
    ep6_command *ep = &OUT6BUF;
    unsigned char t, j;

    if (ep->control & SPI_BOOT_FPGA) {
        spi_boot_fpga(ep->dout_len);
        if (ep->din_len)
            spi_read_flash();
    }

    if (ep->control & SPI_INIT) {
        spi_reset();
    }

    if (ep->control & SPI_CS_SEL)
        OUTC &= ~SPI_SEL;

    if (ep->control & SPI_WRITE) {
    PORTACFG &= ~FPGA_CCLK;
        for (j = 0; j < ep->dout_len; j ++) {
            /* SPI OUT */
            t = ep->dout[j];
            spi_send_byte(t);
        }
    PORTACFG |= FPGA_CCLK;
    }

    if (ep->control & SPI_READ) {
        ep6in_len = ep->din_len;
        send_ep6_data();
    }

    if (ep->control & SPI_CS_REL)
        OUTC |= SPI_SEL;

    if (ep->control & SPI_EXIT) {
        OEC &= ~SPI_SEL;
    }
}
static int out3data = 0;
/****************************************************
 * usb_isr()
 *
 ****************************************************/
static void 
usb_isr(void) interrupt 8 using 1 
{

	CLEAR_INT2(); /* clear INT2 interrupt */

#if DATA_BEAT_A7
	OUTA |= 0x80; /* turn port A7 on, it is turned off in the isr  */
#endif /* DATA_BEAT_A7 */

#if DATA_BEAT_C3
	OUTC &= ~0x08; /* turn port C3 on (low), it is turned off in the isr  */
#endif /* DATA_BEAT_C3 */

	if (USBIRQ & 0x01) {
		/* this is an SUDAV interrupt */

		USBIRQ = 0x01; /* clear SUDAV interrupt */

		/* standard requests */
		if ((sdata->bmRequestType & REQUEST_TYPE_MASK) == STANDARD_REQUEST_TYPE) {
			switch (sdata->bRequest) {
				case GET_STATUS_REQUEST:
					get_status();
					break;

				case GET_DESCRIPTOR_REQUEST:
					get_descriptor();
					break;

				case GET_CONFIG_REQUEST:
					/* only one configuration is supported */
					if (sdata->bmRequestType == 0x80 && sdata->wLengthL == 0x01) {
						in0buf[0] = 0x01;
						IN0BC     = 0x01;
						CLEAR_HSNAK();
					} else {
						EP0_STALL();
					}
					break;

				case SET_CONFIG_REQUEST:
					/* only one configuration is supported */
					if (sdata->bmRequestType == 0 && sdata->wValueL == 0x01) {
						CLEAR_HSNAK();
					} else {
						EP0_STALL();
					}
					break;

				case GET_INTERFACE_REQUEST:
					/* only one interface */
					if(sdata->bmRequestType == 0x81 &&
						sdata->wIndexL == 0x00 &&
						sdata->wLengthL == 0x01) {
 
						in0buf[0] = 0;
						IN0BC = 0x01;
						CLEAR_HSNAK();
					} else {
						EP0_STALL();
					}
					break;

				case SET_INTERFACE_REQUEST:
					set_interface();
					break;

				default:
					EP0_STALL();
					break;
			}
		} else {
			EP0_STALL();
		}
	} else if (IN07IRQ & 0x01) {
		/* IN 0 interrupt */
		IN07IRQ = 0x01;
	} else if (OUT07IRQ & 0x01) {
		/* OUT 0 interrupt */
		OUT0BC = 0;
		OUT07IRQ = 0x01;  
	} else if (OUT07IRQ & 0x02) {
		/* OUT 1 interrupt */
		endpoint1_out();
		OUT1BC = 64;
		OUT07IRQ = 0x02;
	} else if (IN07IRQ & 0x02) {
		/* IN 1 interrupt */
		IN07IRQ = 0x02;
		if (ep1in_pending) {
			ep1in_pending = 0;
			send_cc_info();
		}
	} else if (OUT07IRQ & 0x4) {
		/* OUT 2 interrupt */
		endpoint2_out();
		OUT2BC = 0;
		OUT07IRQ = 0x04;
	} else if (IN07IRQ & 0x4) {
		/* IN 2 interrupt */
		IN07IRQ = 0x04;
		if (ep2in_pending) {
			ep2in_pending = 0;
			send_ep2_info();
		}
	} else if (OUT07IRQ & 0x8) {
		/* OUT 3 interrupt */
        out3data ++;
		OUT07IRQ = 0x08;
	} else if (OUT07IRQ & 0x10) {
        /* OUT 4 interrupt */
		endpoint4_out();
		OUT4BC = 0;
		OUT07IRQ = 0x10;
    } else if (IN07IRQ & 0x10) {
		/* IN 4 interrupt */
		IN07IRQ = 0x10;
		if (ep4in_pending) {
			ep4in_pending = 0;
			send_ep4_data();
		}
    } else if (OUT07IRQ & 0x20) {
        /* OUT 5 interrupt */
        endpoint5_out();
        OUT5BC = 0;
        OUT07IRQ = 0x20;
    } else if (IN07IRQ & 0x40) {
        /* IN 6 interrupt */
		IN07IRQ = 0x40;
		if (ep6in_pending) {
			ep6in_pending = 0;
			send_ep6_data();
		}
    } else if (OUT07IRQ & 0x40) {
        /* OUT 6 interrupt */
        endpoint6_out();
        OUT6BC = 0;
        OUT07IRQ = 0x40;
    }

	/* reset - don't reset, servers may go crazy */
	if (USBIRQ & 0x10){
	 USBIRQ = 0x10;
	}

}


/****************************************************
 * reset_ezusb
 ****************************************************/
static void 
reset_ezusb(void)
{
	EA = 0;          /* disable global interrupts */

	USBCS &= 0xF3;   /* Clear DISCON, DISCOE */
	wait_msec(200);  /* give host plenty of time to respond to disconnect */

    USBPAIR = 0;
	USBBAV = 0;      /* clear autovectoring and break reporting         */
	USBIRQ = 0xFF;   /* clear SUDAV interrupt and all other interrupts  */
	USBIEN = 0x11;   /* enable SUDAV interrupt and RESET interrupt      */

	IN07IRQ = 0xFF;  /* clear all IN interrupts       */
	IN07IEN = 0x77;  /* enable IN0 & IN1 & IN2 & IN4 interrupts   */
	IN07VAL = 0x77;  /* make endpoint IN0 & IN1 & IN2 & IN4 & IN6 valid */

	OUT07IRQ = 0xFF; /* clear all OUT interrupts         */
	OUT07IEN = 0x7F; /* enable OUT0 & OUT1 & OUT2 & OUT3 & OUT4 interrupts    */
	OUT07VAL = 0x7F; /* make endpoint OUT0 & OUT1 & OUT2 & OUT3 & OUT4 & IN6 valid */
  
	USBCS |= 0x06;   /* Set DISCOE to enable pullup resistor 
					  * Set RENUM so that 8051 handles USB requests
					  */

	PORTACFG &= ~0x80;   /* port A7 has LED attached for blinking */
	PORTACFG |= BIT_4 | BIT_5; /* Enable FAST Write/Read */
	OEA |= 0x80 | FPGA_CCLK;
	OUTA &= ~0x80;       /* initial state of LED is off */

	PORTCCFG = 0;
	PORTCCFG &= ~0x08;   /* on DeVaSys board blink port C3 */
	OEC |= 0x08 | 1<<6 | 1<<7;
    OEC &= ~FPGA_FIFO_RD;
	OUTC = 0;
	OUTC |= ~0xF7;       /* initial state of LED is off (led is tied to +v) */
	                     /* so bring port high to turn it off               */
	OUTC &= 0xF7;       /* ON */

	PORTBCFG &= ~0x0C;   /* port B2 is horizontal servo & B3 is vertical */
	OEB |= 0x0C;
	
	FASTXFR = BIT_6|BIT_2;
	CKCON = 0;

//	EUSB = 1;        /* enable USB interrupt     */
//	EA = 1;          /* enable global interrupts */
}


/****************************************************
 * set up the timers to control the servos
 ****************************************************/
static void 
init_timers(void) critical
{
	unsigned short usecs;

	timer1_action = STOP_BOTH_PULSES;
	timer1_usecs_remaining = 0;

	/* configure initial pulse widths for each timer */
	usecs = SERVO_INTERRUPT_TIME(pulse_frequency);
	TH0 = HI_BYTE(usecs);
	TL0 = LOW_BYTE(usecs);
	usecs = SERVO_INTERRUPT_TIME(center_usecs);
	TH1 = HI_BYTE(usecs);
	TL1 = LOW_BYTE(usecs);

	/* configure timer0 and timer1 */
	TMOD = 0x11;
	TCON |= 0x50;

	/* allow interrupts from timers */
	ET0 = 1;
	ET1 = 1;

	/* start servo pulses */
	HORIZONTAL_SERVO_ON();
	VERTICAL_SERVO_ON();

}


/****************************************************
 * interrupt runs every 20 milli-seconds, starts
 * a new pulse on each servo, and re-starts pulse 
 * duration timers
 ****************************************************/
static void 
timer0_isr(void) interrupt 1 using 2 critical
{

	/* stop the timers */
	TCON &= ~0x50;

#if DELAY_PER_PERIOD
   if (servo_delay_count++ >= DELAY_PER_PERIOD)
#endif /* DELAY_PER_PERIOD */
	{
#if DELAY_PER_PERIOD
		servo_delay_count = 0;
#endif /* DELAY_PER_PERIOD */
	} 

	/* set timer0 to pulse interval */
	usecs = SERVO_INTERRUPT_TIME(pulse_frequency);
	TH0 = HI_BYTE(usecs);
	TL0 = LOW_BYTE(usecs);

	/* determine which pulse ends first and set the timer to expire
	 * at that time, the timer will be started again for the remaining
	 * portion of the longer timer period
	 */
	if (current_vertical_pos < current_horizontal_pos)
	{
		POSITION_TO_USEC(current_vertical_pos, usecs);
		POSITION_TO_USEC(current_horizontal_pos, timer1_usecs_remaining);
		timer1_action = HORIZONTAL_TIME_REMAINING;
	}
	else if (current_horizontal_pos < current_vertical_pos)
	{
		POSITION_TO_USEC(current_horizontal_pos, usecs);
		POSITION_TO_USEC(current_vertical_pos, timer1_usecs_remaining);
		timer1_action = VERTICAL_TIME_REMAINING;
	}
	else /* (current_vertical_pos == current_horizontal_pos) */
	{
		/* NOTE: we invoke POSITION_TO_USEC twice below to keep the code paths
		 * the same length of time... otherwise the servos jitter when
		 * the vertical and horizontal degrees equal
		 */
		POSITION_TO_USEC(current_horizontal_pos, usecs);
		POSITION_TO_USEC(current_horizontal_pos, usecs);
		timer1_action = STOP_BOTH_PULSES;
	}

	/* the code below is not really needed if the vertical and horizontal
	 * degrees are the same... it is here to keep code paths the same,
	 * see NOTE above.
	 */
	timer1_usecs_remaining -= usecs;
	timer1_usecs_remaining = SERVO_INTERRUPT_TIME(timer1_usecs_remaining);
	th1_remaining = HI_BYTE(timer1_usecs_remaining);
	tl1_remaining = LOW_BYTE(timer1_usecs_remaining);

	/* timer1 time to stop shortest pulse */
	usecs = SERVO_INTERRUPT_TIME(usecs);
	TH1 = HI_BYTE(usecs);
	TL1 = LOW_BYTE(usecs);

	/* start pulse on both servo ports */
	HORIZONTAL_SERVO_ON();
	VERTICAL_SERVO_ON();

	/* start both timers */
	TCON |= 0x50;

#if HEART_BEAT_A7
	/* blink port A7, we should be running this ISR at 20msec
	 * intervals so below code should cause A7 to blink every second 
	 */
	{
#define ON_PERIOD 50    /* 50*20usec == 1sec */
		idata static int i = 0;
		if (i<ON_PERIOD) {
			if (i==0) {
				OUTA &= 0x7F; /* off */
			}
			i++;
		} else if (i<(2*ON_PERIOD)) {
			if (i==ON_PERIOD) {
				OUTA |= 0x80; /* on  */
			}
			i++;
			if (i==(2*ON_PERIOD)) {
				i=0;
			}
		} 
	}
#endif /* HEART_BEAT */

#if HEART_BEAT_C3
	/* blink port C3, we should be running this ISR at 20msec
	 * intervals so below code should cause C3 to blink every second 
	 */
	{
#define ON_PERIOD 50    /* 50*20usec == 1sec */
		idata static int i = 0;
		if (i<ON_PERIOD) {
			if (i==0) {
				OUTC |= 0x08; /* off (high) */
			}
			i++;
		} else if (i<(2*ON_PERIOD)) {
			if (i==ON_PERIOD) {
				OUTC &= 0xF7; /* on (low) */
			}
			i++;
			if (i==(2*ON_PERIOD)) {
				i=0;
			}
		} 
	}
#endif /* HEART_BEAT */

#if DATA_BEAT_A7
	if (OUTA & ~0x7F) /* A7 is on */ {
		idata static int i = 0;
		if (i++>=3) /* 60+ usec */ {
			OUTA &= 0x7F; /* turn port A7 off */
			i = 0;
		}
	}
#endif /* DATA_BEAT_A7 */

#if DATA_BEAT_C3
	if (!(OUTC & 0x08)) /* C3 is on (low) */ {
		idata static int i = 0;
		if (i++>=3) /* 60+ usec */ {
			OUTC |= 0x08; /* turn port C3 off (high) */
			i = 0;
		}
	}
#endif /* DATA_BEAT_A7 */

}

/****************************************************
 * horizontal servo timer
 ****************************************************/
static void 
timer1_isr(void) interrupt 3 using 2 critical
{
	/* stop timer1 */
	TCON &= ~0x40;

	/* NOTE: this is not efficient as it could be - the code is
	 * organized to keep the duration the same between actions.
	 * we still get a bit of jitter when the servo horizontal
	 * and vertical degrees cross...
	 */
	TH1 = th1_remaining;
	TL1 = tl1_remaining;

	if (timer1_action == HORIZONTAL_TIME_REMAINING) {
		TCON |= 0x40;
		VERTICAL_SERVO_OFF();
	} else if (timer1_action == VERTICAL_TIME_REMAINING) {
		TCON |= 0x40;
		HORIZONTAL_SERVO_OFF();
	} else /* STOP_BOTH_PULSES */ {
		HORIZONTAL_SERVO_OFF();
		VERTICAL_SERVO_OFF();
	}

	timer1_action = STOP_BOTH_PULSES;
}

/****************************************************
 * _sdcc_external_startup()
 ****************************************************/

byte 
_sdcc_external_startup()
{
	ISOCTL |= 0x01;  /* Disable ISO, see trm v1.9 page 3-3 (56)          */
						  /* this gives us the memory at 0x2000 to 0x27FF     */
	/*
	{_asm
		mov   sp,#0x2200;
	_endasm;
	}
	*/
	return (0);
}
void 
enable_ezusb(void)
{
    EUSB = 1;        /* enable USB interrupt     */
	EA = 1;          /* enable global interrupts */
}
/****************************************************
 * main ()
 * Basic initialization, re-enumeration and the reset
 ****************************************************/
int 
main(void)
{
	/* init variables */
	center_usecs    = SERVO_PULSE_TIME(CENTER_USECS);
	pulse_frequency = SERVO_PULSE_TIME(PULSE_FREQUENCY);
	current_horizontal_pos = 0;
	current_vertical_pos = 0;
	ep1in_pending = 0;
	ep2in_pending = 0;
    ep4in_pending = 0;
    ep6in_pending = 0;
#if DELAY_PER_PERIOD
   servo_delay_count = 0;
#endif /* DELAY_PER_PERIOD */
	
    reset_ezusb();
    spi_boot_fpga(1);
    spi_read_flash();
    enable_ezusb();	
    init_timers();

	/* blink_portA7(2, 1); */
	while (1) { 
        if (out3data) {
            out3data --;
            endpoint3_out();
            OUT3BC = 0;
        }
	}
}
