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
| October 31, 2000                                                             |
|                                                                              |
|                                                                              |
| This file is associated with the ezusb2131 Linux downloader project. The     |
| project can be found at http://ezusb2131.sourceforge.net.                    |
|                                                                              |
|  this file derived from pp.c header files                                    |
|                                                                              |
|  pp.c header files Copyright (C) 2002, Michael Hetherington                  |
|  chinook * pacific_net_sg                                                    |
|                                                                              |
|  pp.c header files based on sunkbd_hid.c header files                        |
|  sunkbd_hid.c header files Copyright (C) 2001, Arnim Laeuger                 |
|  arnim * users_sourceforge_net                                               |
|                                                                              |
|                                                                              |
\*----------------------------------------------------------------------------*/

/*******************************************************************************
 *
 * $Id: cam_control_fw.h,v 1.1 2003/02/21 06:50:35 tonycu Exp $
 *
 ******************************************************************************/

#ifndef CAM_CONTROL_FW_H
#define CAM_CONTROL_FW_H

/* servo defines, times are in micro-seconds */
#define PULSE_FREQUENCY       25000  /* milli-seconds (in usec)             */
#define CENTER_USECS          2560   /* pulse for center position (in usec) */

#define NUM_DEGREES           90     /* number of degrees servo can move */ 
				                         /* from center to left or right     */

#define NUM_STOPS             270    /* number of steps, must be multiple 
												  * of NUM_DEGREES
												  */ 

#define HORIZONTAL_TIME_REMAINING	1
#define VERTICAL_TIME_REMAINING		2
#define STOP_BOTH_PULSES   			3

#define SERVO_PULSE_TIME(usec)      ((usec*2)+1)
#define SERVO_INTERRUPT_TIME(usec)	(0xFFFF-usec)

#define HORIZONTAL_SERVO_ON()    (OUTB |=  0x04)
#define HORIZONTAL_SERVO_OFF()   (OUTB &= ~0x04)
#define VERTICAL_SERVO_ON()      (OUTB |=  0x08)
#define VERTICAL_SERVO_OFF()     (OUTB &= ~0x08)

/*
 * below table generated from make_usec_table.c
 */
static code unsigned short usec_table[NUM_STOPS] = {
    7,    14,    21,    28,    35,    42,    49,    56,    63,    70, 
   77,    84,    91,    98,   105,   112,   119,   126,   133,   140, 
  147,   154,   161,   168,   175,   182,   189,   196,   203,   210, 
  217,   224,   231,   238,   245,   252,   259,   266,   273,   280, 
  287,   294,   301,   308,   315,   322,   329,   336,   343,   350, 
  357,   364,   371,   378,   385,   392,   399,   406,   413,   420, 
  427,   434,   441,   448,   455,   462,   469,   476,   483,   490, 
  497,   504,   511,   518,   525,   532,   539,   546,   553,   560, 
  567,   574,   581,   588,   595,   602,   609,   616,   623,   630, 
  637,   644,   651,   658,   665,   672,   679,   686,   693,   700, 
  707,   714,   721,   728,   735,   742,   749,   756,   763,   770, 
  777,   784,   791,   798,   805,   812,   819,   826,   833,   840, 
  847,   854,   861,   868,   875,   882,   889,   896,   903,   910, 
  917,   924,   931,   938,   945,   952,   959,   966,   973,   980, 
  987,   994,  1001,  1008,  1015,  1022,  1029,  1036,  1043,  1050, 
 1057,  1064,  1071,  1078,  1085,  1092,  1099,  1106,  1113,  1120, 
 1127,  1134,  1141,  1148,  1155,  1162,  1169,  1176,  1183,  1190, 
 1197,  1204,  1211,  1218,  1225,  1232,  1239,  1246,  1253,  1260, 
 1267,  1274,  1281,  1288,  1295,  1302,  1309,  1316,  1323,  1330, 
 1337,  1344,  1351,  1358,  1365,  1372,  1379,  1386,  1393,  1400, 
 1407,  1414,  1421,  1428,  1435,  1442,  1449,  1456,  1463,  1470, 
 1477,  1484,  1491,  1498,  1505,  1512,  1519,  1526,  1533,  1540, 
 1547,  1554,  1561,  1568,  1575,  1582,  1589,  1596,  1603,  1610, 
 1617,  1624,  1631,  1638,  1645,  1652,  1659,  1666,  1673,  1680, 
 1687,  1694,  1701,  1708,  1715,  1722,  1729,  1736,  1743,  1750, 
 1757,  1764,  1771,  1778,  1785,  1792,  1799,  1806,  1813,  1820, 
 1827,  1834,  1841,  1848,  1855,  1862,  1869,  1876,  1883,  1890 };

#define POSITION_TO_USEC(pos, usec)                          \
			{                                                   \
				if (pos == 0) {                                  \
				   usec = CENTER_USECS;                          \
				} else if (pos > 0) {                            \
				   usec = CENTER_USECS + usec_table[(pos)-1];    \
				} else {                                         \
				   usec = CENTER_USECS - usec_table[(-1*pos)-1]; \
				}                                                \
			}

typedef struct
{
	char  new_command;    /* new command from host */
	short horizontal_pos;
	short vertical_pos;
} pwm;  /* pulse width modulation struct */


/* USB setup packet defines */
#define REQUEST_DIRECTION_MASK   0x80
#define HOST_TO_DEVICE           0x00
#define DEVICE_TO_HOST           0x80

#define REQUEST_TYPE_MASK        0x60
#define STANDARD_REQUEST_TYPE    0x00
#define CLASS_REQUEST_TYPE       0x20
#define VENDOR_REQUEST_TYPE      0x40
#define RESERVED_REQUEST_TYPE    0x60

#define RECIPIENT_MASK           0x1F
#define DEVICE_RECIPIENT         0x00
#define INTERFACE_RECIPIENT      0x01
#define ENDPOINT_RECIPIENT       0x02
#define OTHER_RECIPIENT          0x03

#define GET_STATUS_REQUEST       0x00
#define CLEAR_FEATURE_REQUEST    0x01
#define RESERVED_REQUEST_1       0x02
#define SET_FEATURE_REQUEST      0x03
#define RESERVED_REQUEST_2       0x04
#define SET_ADDRESS_REQUEST      0x05
#define GET_DESCRIPTOR_REQUEST   0x06
#define SET_DESCRIPTOR_REQUEST   0x07
#define GET_CONFIG_REQUEST       0x08
#define SET_CONFIG_REQUEST       0x09
#define GET_INTERFACE_REQUEST    0x0A
#define SET_INTERFACE_REQUEST    0x0B
#define SYNCH_FRAME_REQUEST      0x0C

#define GET_DEVICE_DESCRIPTOR    0x01
#define GET_CONFIG_DESCRIPTOR    0x02
#define GET_STRING_DESCRIPTOR    0x03

/* macros */
#define CLEAR_INT2()   (EXIF &= 0xEF)
#define EP0_STALL()    (EP0CS = 0x03)         /* set EPOSTALL & HSNAK */
#define CLEAR_HSNAK()  (EP0CS = 0x02)         /* clr handshake nak    */

#define HI_BYTE(b)       ((byte)((unsigned int)b >> 8))
#define LOW_BYTE(b)      ((byte)((unsigned int)b &  0xFF))

#define SET_BIT(the_bit)   {_asm setb the_bit; _endasm;}
#define CLEAR_BIT(the_bit) {_asm clr the_bit; _endasm;}

xdata at 0x7FA1 unsigned char ISOCTL;
xdata at 0x7FE2 unsigned char FASTXFR;

/***************************************
 * ezhid_reg.h
 * http://sourceforge.net/projects/ezhid
 * maintainer:
 * Arnim Laeuger
 * arnim@users.sourceforge.net
 ***************************************/

sbit  at 0xe8 EUSB;
sbit  at 0xac ES0;
sbit  at 0xae ES1;
sbit  at 0x98 RI_0;
sbit  at 0x99 TI_0;
sbit  at 0xc0 RI_1;
sbit  at 0xc1 TI_1;
sbit  at 0xca TR2;
sbit  at 0xcf TF2;
sbit  at 0xad ET2;

sfr   at 0x91 EXIF;
sfr   at 0xe8 EIE;
sfr   at 0x98 SCON0;
sfr   at 0xc0 SCON1;
sfr   at 0x99 SBUF0;
sfr   at 0xc1 SBUF1;
sfr   at 0x8e CKCON;
sfr   at 0xc8 T2CON;
sfr   at 0xca RCAP2L;
sfr   at 0xcb RCAP2H;
sfr   at 0xcc TL2;
sfr   at 0xcd TH2;



xdata at 0x7fb4 unsigned char EP0CS;
xdata at 0x7f00 unsigned char IN0BUF;
xdata at 0x7fb5 unsigned char IN0BC;
xdata at 0x7ec0 unsigned char OUT0BUF;
xdata at 0x7fc5 unsigned char OUT0BC;

xdata at 0x7e80 unsigned char IN1BUF;
xdata at 0x7fb6 unsigned char IN1CS;
xdata at 0x7fb7 unsigned char IN1BC;

xdata at 0x7e40 unsigned char OUT1BUF;
xdata at 0x7fc6 unsigned char OUT1CS;
xdata at 0x7fc7 unsigned char OUT1BC;

xdata at 0x7e00 unsigned char IN2BUF;
xdata at 0x7fb9 unsigned char IN2BC;
xdata at 0x7fb8 unsigned char IN2CS;
xdata at 0x7fc9 unsigned char OUT2BC;
xdata at 0x7fc8 unsigned char OUT2CS;
xdata at 0x7dc0 unsigned char OUT2BUF;

xdata at 0x7d80 unsigned char IN3BUF;
xdata at 0x7fbb unsigned char IN3BC;
xdata at 0x7fba unsigned char IN3CS;

xdata at 0x7fbd unsigned char IN4BC;
xdata at 0x7fbc unsigned char IN4CS;
xdata at 0x7d00 unsigned char IN4BUF[64];

xdata at 0x7FC0 unsigned char IN6CS;
xdata at 0x7FC1 unsigned char IN6BC;
xdata at 0x7FD0 unsigned char OUT6CS;
xdata at 0x7FD1 unsigned char OUT6BC;
xdata at 0x7C00 unsigned char IN6BUF;
xdata at 0x7BC0 unsigned char OUT6BUF;

xdata at 0x7D40 unsigned char OUT3BUF[64];
xdata at 0x7FCB unsigned char OUT3BC;

xdata at 0x7CC0 unsigned char OUT4BUF;
xdata at 0x7FCD unsigned char OUT4BC;

xdata at 0x7FCC unsigned char OUT4CS;

xdata at 0x7C40 unsigned char OUT5BUF;
xdata at 0x7FCE unsigned char OUT5CS;
xdata at 0x7FCF unsigned char OUT5BC;

xdata at 0x7F9C unsigned char OEA;
xdata at 0x7f96 unsigned char OUTA;
xdata at 0x7f9d unsigned char OEB;
xdata at 0x7f97 unsigned char OUTB;
xdata at 0x7f9e unsigned char OEC;
xdata at 0x7f98 unsigned char OUTC;
xdata at 0x7F99 unsigned char PINSA;
xdata at 0x7F9A unsigned char PINSB;
xdata at 0x7f9b unsigned char PINSC;
xdata at 0x7f93 unsigned char PORTACFG;
xdata at 0x7f94 unsigned char PORTBCFG;
xdata at 0x7f95 unsigned char PORTCCFG;

xdata at 0x7fa9 unsigned char IN07IRQ;
xdata at 0x7faa unsigned char OUT07IRQ;
xdata at 0x7fac unsigned char IN07IEN;
xdata at 0x7fad unsigned char OUT07IEN;
xdata at 0x7fab unsigned char USBIRQ;
xdata at 0x7fae unsigned char USBIEN;

xdata at 0x7faf unsigned char USBBAV;
xdata at 0x7fd6 unsigned char USBCS;
xdata at 0x7fd7 unsigned char TOGCTL;
xdata at 0x7fd4 unsigned char SUDPTRH;
xdata at 0x7fd5 unsigned char SUDPTRL;
xdata at 0x7fe8 unsigned char SETUPDAT;
xdata at 0x7fa5 unsigned char I2CS;
xdata at 0x7fa6 unsigned char I2DAT;
xdata at 0x7fde unsigned char IN07VAL;
xdata at 0x7fdf unsigned char OUT07VAL;
xdata at 0x7fe3 unsigned char AUTOPTRH;
xdata at 0x7fe4 unsigned char AUTOPTRL;
xdata at 0x7fe5 unsigned char AUTODATA;


/***************************************
 * usb.h based on sunkbd_hid.h
 * http://sourceforge.net/projects/ezhid
 * maintainer:
 * Arnim Laeuger
 * arnim@users.sourceforge.net
 ***************************************/

/* USB descriptor type */

/* Supported: */ 
#define USB_DT_DEVICE            0x01
#define USB_DT_CONFIG            0x02
#define USB_DT_STRING            0x03


/* Not Supported: */
#define USB_DT_INTERFACE         0x04
#define USB_DT_ENDPOINT          0x05


/* fundamental data type */
typedef unsigned char byte;
typedef unsigned short word;

/* device descriptor */
static code byte dev_desc[] = {
  0x12, // bLength            : Length of Descriptor
  0x01, // bDescriptorType    : Descriptor Type = Device
  0x10, // bcdUSB (L)         : USB Sepcification 2.0 (L)
  0x01, // bcdUSB (H)         : USB Specification 2.0 (H)
  0xFF, // bDeviceClass       : Device Class 
  0xFF, // bDeviceSubClass    : Device Subclass
  0xFF, // bDeviceProtocol    : Device Protocol
  0x40, // bMaxPacketSize0    : Maximum packet size for EP0
  VENDOR_ID & 0xFF,         // idVendor (L)       : Vendor ID (L)
  (VENDOR_ID >> 8) & 0xFF,  // idVendor (H)       : Vendor ID (H)
  PRODUCT_ID & 0xFF,        // idProduct(L)       : Product ID (L)
  (PRODUCT_ID >> 8) & 0xFF, // idProduct(H)       : Product ID (H)
  0x01, // bcdDevice(L)       : Device Release Number (BCD,L)
  0x00, // bcdDevice(H)       : Device Release Number (BCD,H)
  0x01, // iManufacturer      : Manufacturer Index String
  0x02, // iProduct           : Product Index String
  0x00, // iSerialNumber      : Serial Number Index String
  0x01 // bNumConfigurations : Number of Configurations in this Device
};

/* configuration descriptor */
static code byte conf_desc[] = {
  0x09, // bLength            : Legth of the Descriptor
  0x02, // bDecriptorType     : Descriptor Type = Configuration
  0x58, // wTotalLength (L)   : Total Length (L) including interface & endpoint
  0x00, // wTotalLength (H)   : Total Length (H) including interface & endpoint
  0x01, // bNumIterfaces      : Number of interfaces
  0x01, // bConfigurationVal  : Configuration value used by set config request
  0x00, // iConfiguration     : Index of String Describing this Configuartion
  0x80, // bmAttributes       : Attributes
  0x32, // MaxPower           : Maximum Power

  /* Interface Descriptor, Interface 0, Alternate Setting 0 */
  0x09, // bLength            : Length
  0x04, // bDescriptorType    : Interface descriptor
  0x00, // bInterfaceNumber   : Zero-based index of this interface
  0x00, // bAlternateSetting  : This alternate setting
  0x0A, // bNumEndpoints      : Number of endpoints used for this descriptor
  0xFF, // bInterfaceClass    : Vendor specific
  0x00, // bInterfaceSubClass : 
  0xFF, // bInterfaceProtocol : Vendor specific
  0x00, // iInterface         : Index to sring describing this interface

  /* Bulk IN Endpoint 1 Descriptor, Interface 0, Alternate Setting 0 */
  0x07, // bLength            : Length of Descriptor
  0x05, // bDescriptorType    : Endpoint
  0x81, // bEndpointAddress   : IN endpoint 1
  0x02, // bmAttributes       : Bulk endpoint
  0x40, // wMaxPacketSize (L) : Maximum data transfer size (L)
  0x00, // wMaxPacketSize (H) : Maximum data transfer size (H)
  0x00, // bInterval          : Polling interval

  /* Bulk OUT Endpoint 1 Descriptor, Interface 0, Alternate Setting 0 */
  0x07, // bLength            : Length of Descriptor
  0x05, // bDescriptorType    : Endpoint
  0x01, // bEndpointAddress   : OUT endpoint 1
  0x02, // bmAttributes       : Bulk endpoint
  0x40, // wMaxPacketSize (L) : Maximum data transfer size (L)
  0x00, // wMaxPacketSize (H) : Maximum data transfer size (H)
  0x00, // bInterval          : Polling interval

   /* Bulk IN Endpoint 1 Descriptor, Interface 0, Alternate Setting 0 */
  0x07, // bLength            : Length of Descriptor
  0x05, // bDescriptorType    : Endpoint
  0x82, // bEndpointAddress   : IN endpoint 1
  0x02, // bmAttributes       : Bulk endpoint
  0x40, // wMaxPacketSize (L) : Maximum data transfer size (L)
  0x00, // wMaxPacketSize (H) : Maximum data transfer size (H)
  0x00, // bInterval          : Polling interval

  /* Bulk OUT Endpoint 1 Descriptor, Interface 0, Alternate Setting 0 */
  0x07, // bLength            : Length of Descriptor
  0x05, // bDescriptorType    : Endpoint
  0x02, // bEndpointAddress   : OUT endpoint 1
  0x02, // bmAttributes       : Bulk endpoint
  0x40, // wMaxPacketSize (L) : Maximum data transfer size (L)
  0x00, // wMaxPacketSize (H) : Maximum data transfer size (H)
  0x00, // bInterval          : Polling interval
  
  /* Bulk OUT Endpoint 1 Descriptor, Interface 0, Alternate Setting 0 */
  0x07, // bLength            : Length of Descriptor
  0x05, // bDescriptorType    : Endpoint
  0x03, // bEndpointAddress   : OUT endpoint 1
  0x02, // bmAttributes       : Bulk endpoint
  0x40, // wMaxPacketSize (L) : Maximum data transfer size (L)
  0x00, // wMaxPacketSize (H) : Maximum data transfer size (H)
  0x00, // bInterval          : Polling interval
 
  /* Bulk IN Endpoint 1 Descriptor, Interface 0, Alternate Setting 0 */
  0x07, // bLength            : Length of Descriptor
  0x05, // bDescriptorType    : Endpoint
  0x84, // bEndpointAddress   : IN endpoint 1
  0x02, // bmAttributes       : Bulk endpoint
  0x40, // wMaxPacketSize (L) : Maximum data transfer size (L)
  0x00, // wMaxPacketSize (H) : Maximum data transfer size (H)
  0x00, // bInterval          : Polling interval

  /* Bulk OUT Endpoint 1 Descriptor, Interface 0, Alternate Setting 0 */
  0x07, // bLength            : Length of Descriptor
  0x05, // bDescriptorType    : Endpoint
  0x04, // bEndpointAddress   : OUT endpoint 1
  0x02, // bmAttributes       : Bulk endpoint
  0x40, // wMaxPacketSize (L) : Maximum data transfer size (L)
  0x00, // wMaxPacketSize (H) : Maximum data transfer size (H)
  0x00, // bInterval          : Polling interval
  
  /* Bulk OUT Endpoint 1 Descriptor, Interface 0, Alternate Setting 0 */
  0x07, // bLength            : Length of Descriptor
  0x05, // bDescriptorType    : Endpoint
  0x05, // bEndpointAddress   : OUT endpoint 1
  0x02, // bmAttributes       : Bulk endpoint
  0x40, // wMaxPacketSize (L) : Maximum data transfer size (L)
  0x00, // wMaxPacketSize (H) : Maximum data transfer size (H)
  0x00, // bInterval          : Polling interval

  /* Bulk IN Endpoint 1 Descriptor, Interface 0, Alternate Setting 0 */
  0x07, // bLength            : Length of Descriptor
  0x05, // bDescriptorType    : Endpoint
  0x86, // bEndpointAddress   : IN endpoint 1
  0x02, // bmAttributes       : Bulk endpoint
  0x40, // wMaxPacketSize (L) : Maximum data transfer size (L)
  0x00, // wMaxPacketSize (H) : Maximum data transfer size (H)
  0x00, // bInterval          : Polling interval

  /* Bulk OUT Endpoint 1 Descriptor, Interface 0, Alternate Setting 0 */
  0x07, // bLength            : Length of Descriptor
  0x05, // bDescriptorType    : Endpoint
  0x06, // bEndpointAddress   : OUT endpoint 1
  0x02, // bmAttributes       : Bulk endpoint
  0x40, // wMaxPacketSize (L) : Maximum data transfer size (L)
  0x00, // wMaxPacketSize (H) : Maximum data transfer size (H)
  0x00, // bInterval          : Polling interval
  
};

/* language ID string descriptor */
static code byte string_langid[] = {0x04, 0x03, 0x00, 0x00};

/* manufacturer ID string */
static code byte string_mfg[] = {
  0x22, 0x03,
  /* standard requests */
  'e',0,'z',0,'u',0,'s',0,'b',0,
  '2',0,'1',0,'3',0,'1',0,'.',0,
  's',0,'f',0,'.',0,'n',0,'e',0,
  't',0
};

/* product ID string */
static code byte string_prod[] = {
  0x18, 0x03,
  /* standard requests */
  'C',0,'a',0,'m',0,' ',0,'C',0,
  'o',0,'n',0,'t',0,'r',0,'o',0,
  'l',0
};


#define NUM_STRINGS  3
static data unsigned int string_index[NUM_STRINGS] = {
  (unsigned int) string_langid,
  (unsigned int) string_mfg,
  (unsigned int) string_prod
};


/* setup packet structure */
typedef struct {
  byte bmRequestType;
  byte bRequest;
  byte wValueL;
  byte wValueH;
  byte wIndexL;
  byte wIndexH;
  byte wLengthL;
  byte wLengthH;
} setup_data;

static xdata byte * data in0buf = (xdata byte *)&IN0BUF;
static xdata byte * data out0buf = (xdata byte *)&OUT0BUF;
static xdata byte * data in1buf = (xdata byte *)&IN1BUF;
static xdata byte * data out1buf = (xdata byte *)&OUT1BUF;

xdata at 0x7FDD unsigned char USBPAIR;

#endif /* CAM_CONTROL_FW_H */

