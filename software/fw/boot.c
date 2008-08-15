/*
 * Dragon compatible FW 
 */
#include <stdio.h>
#include <string.h>
#include <8051.h>

#include "ezusbfx.h"

#include "dragon.h"
//#include "../include/hw.h"

static void spi_start(void) /* 0x5D */
{
        _asm 
        MOV DPTR, #_AUTOPTRH;
        MOV A, #0x10;
        MOVX @DPTR, A;
        INC DPTR; /* ?? */
        CLR A;
        MOVX @DPTR, A;
        INC DPTR; /* ?? */
        _endasm;
}

static void spi_send_read(void)   /* 0x69 */
{
        _asm
        /* send 0x03 READ */
        CLR A;
        MOVX  @DPTR,A;
        MOVX  @DPTR,A;
        MOVX  @DPTR,A;
        MOVX  @DPTR,A;
        MOVX  @DPTR,A;
        MOVX  @DPTR,A;
        MOV   A,#0x80;
        MOVX  @DPTR,A
        MOVX  @DPTR,A
        CLR   A
        MOV   R0,#0x18;
loop:   /* send out address */
        MOVX  @DPTR,A;
        DJNZ  R0,loop;
        _endasm;
}

int main(void)
{
        USBCS = DISCOE;
        OUTC  = SPI_SEL;
        OEC   = ~FPGA_DONE;
        OUTC  = SPI_SEL | FPGA_PROG_B;

        FASTXFR = 0;
        spi_start();
        spi_send_read();

        /* PROG to high */
        PORTACFG = 0x10; /* enable fast write strobe */
        FASTXFR  = 0x40; /* FBLK */
        OUTC     = FPGA_PROG_B;
        spi_start();

        _asm
        MOV R0, #0x20;
loop0:
        MOVX A, @DPTR;
        DJNZ R0,loop0;
        _endasm;

        PORTACFG = 0x0;
        OUTC     = FPGA_PROG_B | FPGA_INIT_B;
        OEC      = (~FPGA_INIT_B) & (~FPGA_DONE);
        _asm
loop1:                    /* wait for done to high */
        MOV  DPTR,#_PINSC;
        MOVX A,@DPTR;
        JNB  ACC.5,loop1;
        _endasm;

        OEC      = (~FPGA_INIT_B) & (~FPGA_DONE) & (~SPI_SEL);
}
