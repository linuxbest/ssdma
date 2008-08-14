/*
 * Dragon fw - 
 * Copyright (c) 2008, Hu Gang <hugang@soulinfo.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 */
#include "hw.h"

#define EP1_INFO  BIT_7

typedef struct ep1_info {
    unsigned char control;

    unsigned char OEA;
    unsigned char OUTA;
    unsigned char PORTACFG;
    unsigned char PINSA;

    unsigned char OEC;
    unsigned char OUTC;
    unsigned char PORTCCFG;
    unsigned char PINSC;

    unsigned char FASTXFR;
    unsigned char CKCON;

    unsigned char sizeH;
    unsigned char sizeL;
    
    unsigned char FPGA_STATUS;
#define ERR_INIT_B  BIT_0
#define ERR_DONE    BIT_1
#define ERR_CRC     BIT_2
#define FPGA_BOOT   BIT_7
    unsigned char FIFO_RD;

    unsigned char MAGIC;
} ep1_info;

#define E_OEA  BIT_1
#define E_OUTA BIT_2
#define E_ACFG BIT_3

#define E_OEC  BIT_4
#define E_OUTC BIT_5
#define E_CCFG BIT_6

typedef struct ep1_command {
    unsigned char control;

    unsigned char OEA;
    unsigned char OUTA;
    unsigned char PORTACFG;
    unsigned char PINSA;

    unsigned char OEC;
    unsigned char OUTC;
    unsigned char PORTCCFG;
    unsigned char PINSC;
    unsigned char FASTXFR;
    unsigned char CKCON;

#define TOG_INIT    BIT_1
#define TOG_EXIT    BIT_2
#define E_CKCON     BIT_3
#define E_FASTXFR   BIT_4
    unsigned char tog_control;
} ep1_command;

#define TO_FIFO   BIT_1
#define FROM_FIFO BIT_2
#define FROM_I2C  BIT_3

#define FIFO_MAX_SIZE (65535)

typedef struct ep2_command {
    unsigned char control;

    unsigned char addr;/* I2C */
    unsigned char sizeH;
    unsigned char sizeL;
} ep2_command;

typedef struct ep4_command {
#define E_I2CS  BIT_1
#define E_I2DAT BIT_2
#define E_READ  BIT_3
#define E_I2DATS BIT_2
    unsigned char control;

    unsigned char I2CS;
    unsigned char I2DAT;
    unsigned char len;
    unsigned char buf[48];
} ep4_command;

typedef struct ep4_data {
    unsigned char I2CS;
    unsigned char I2DAT;
} ep4_data;

#define I2DONE        1<<0
#define I2ACK         1<<1
#define I2BERR        1<<2
#define I2ID0         1<<3
#define I2ID1         1<<4
#define I2LASTRD      1<<5
#define I2STOP        1<<6
#define I2START       1<<7

#define EP6_CMD_HLEN 3
#define EP6_DAT_HLEN 1
typedef struct ep6_command {
    unsigned char control;
#define SPI_READ  BIT_1
#define SPI_WRITE BIT_2
#define SPI_INIT  BIT_3
#define SPI_EXIT  BIT_4
#define SPI_CS_SEL   BIT_5
#define SPI_CS_REL   BIT_6
#define SPI_BOOT_FPGA BIT_7
    unsigned char dout_len;
    unsigned char din_len;

    unsigned char dout[62];
} ep6_command;

typedef struct ep6_data {
    unsigned char dlen;
    unsigned char buf[63]; /* max is 32 bytes */
} ep6_data;
