/*
 * Dragon compatible FW 
 */
#include <stdio.h>
#include <string.h>
#include <8051.h>

#include "ezusbfx.h"

static void spi_start(void) /* 0x5D */
{
        _asm 
        MOV DPTR, #_AUTOPTRH;
        MOV A, #0x10;
        MOVX @DPTR, A;
        INC DPTR;
        MOV A, #0x00;
        MOVX @DPTR, A;
        INC DPTR;
        _endasm;
}

static void spi_do(void)   /* 0x69 */
{
        _asm
        CLR A;
        MOVX  @DPTR,A;
        MOVX  @DPTR,A;
        MOVX  @DPTR,A;
        MOVX  @DPTR,A;
        MOV   A,#0xff;
        MOVX  @DPTR,A
        CLR   A
        MOVX  @DPTR,A
        MOV   A,#0x80;
        MOVX  @DPTR,A
        MOVX  @DPTR,A
        CLR   A
        MOV   R0,#0x18;
loop:
        MOVX  @DPTR,A;
        DJNZ  R0,loop;
        _endasm;
}

int main(void)
{
        USBCS = 0x04;
        OUTC  = 0x01;
        OEC   = 0xCF;
        OUTC  = 0x41;

        FASTXFR = 0;
        spi_start();
        spi_do();

        PORTACFG = 0x10;
        FASTXFR = 0x40;
        OUTC = 0x40;
        spi_start();

        _asm
        MOV R0, #0x20;
loop0:
        MOVX A, @DPTR;
        DJNZ R0,loop0;
        _endasm;

        PORTACFG = 0x0;
        OUTC = 0xC0;
        OEC  = 0x4F;
        _asm
loop1:
        MOV  DPTR,#_PINSC;
        MOVX A,@DPTR;
        JNB  ACC.5,loop1;
        _endasm;

        OEC  = 0x4E;
}
