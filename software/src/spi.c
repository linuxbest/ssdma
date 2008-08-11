/*
 * AT25 SPI flash read/write/erase
 *
 * driver/spi/at25.c
 * spiflash.c
 * PonyProg2000 spi-bus.c
 *
 * Hu Gang 
 */
#include <usb.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "getopt.h"
#include "bit_read.h"
#include "lsb.h"

#include "fw.h"

#include "i2c.h"

/* the device's vendor and product id */
#define MY_VID 0x0547
#define MY_PID 0x2131

static void hexdump(unsigned char *buf, int len, int offset) {
    int i, j;

    for(i = 0; i < len; i+= 16) {
        fprintf(stderr, "0x%.4X: ", i + offset);
        for(j = 0; (j < 16) && (i+j < len); j++) {
            fprintf(stderr, "%.2x ", buf[i+j] & 0xFF);
            if (j == 7)
                fprintf(stderr, "  ");
        }
        for( ; j < 16; j++)
            fprintf(stderr, " ");
        fprintf(stderr, "    ");
        for(j = 0; (j < 16) && (i+j < len); j++)
            if(isprint(buf[i+j]))
                fprintf(stderr, "%c", buf[i+j]);
            else
                fprintf(stderr, ".");
        fprintf(stderr, "\n");
    }
}


static usb_dev_handle *open_dev(int vid, int pid)
{
    struct usb_bus *bus;
    struct usb_device *dev, *ez = NULL;
    int id = 0;

    for(bus = usb_get_busses(); bus; bus = bus->next) {
        for(dev = bus->devices; dev; dev = dev->next) {
            fprintf(stderr, "%-2x    %04x:%04x\n",
                    id, dev->descriptor.idVendor,
                    dev->descriptor.idProduct);
            if(dev->descriptor.idVendor == vid
                    && dev->descriptor.idProduct == pid) {
                ez = dev;
            }
            id ++;
        }
    }
    if (ez) {
        fprintf(stderr, "------------------------------\nFound %04x:%04x\n", vid, pid);
        return usb_open(ez);
    }
    return NULL;
}
    
static usb_dev_handle *dev = NULL; /* the device handle */

int spiInit(int init)
{
    if (init) {
        usb_init(); /* initialize the library */
        usb_find_busses(); /* find all busses */
        usb_find_devices(); /* find all connected devices */

        if(!(dev = open_dev(MY_VID, MY_PID))) {
            fprintf(stderr, "error: device not found!\n");
            return 0;
        }

        if(usb_claim_interface(dev, 0) < 0) {
            fprintf(stderr, "error: claiming interface 0 failed\n");
            usb_close(dev);
            return 0;
        }
    }

    struct ep1_command ep = {0};
    ep.tog_control = TOG_INIT;
    usb_bulk_write(dev, 1, (char *)&ep, sizeof(ep), 1000);

    struct ep6_command spi = {0};
    spi.control = SPI_INIT;
    usb_bulk_write(dev, 6, (char *)&spi, EP6_CMD_HLEN, 1000);

    return 0;
}

int spiCleanUp()
{
    struct ep1_command ep = {0};
    ep.tog_control = TOG_EXIT;
    usb_bulk_write(dev, 1, (char *)&ep, sizeof(ep), 1000);
    
    //struct ep6_command spi = {0};
    //spi.control = SPI_EXIT;
    //usb_bulk_write(dev, 6, (char *)&spi, EP6_CMD_HLEN, 1000);

    return 0;
}

#include "spiflash.h"

static void spiBootFpga(void)
{
    struct ep6_command ep = {0};
   
    ep.control = SPI_BOOT_FPGA;
    ep.dout_len = 1;
    ep.din_len = 1;
    usb_bulk_write(dev, 6, (char *)&ep, EP6_CMD_HLEN, 1000);
}

unsigned short spiflashGetID(void)
{
    struct ep6_command ep = {0};
    struct ep6_data reply;
   
    ep.control = SPI_WRITE|SPI_READ|SPI_CS_SEL|SPI_CS_REL;
    ep.dout_len = 1;/* CMD */
    
    ep.dout[0] = SPIFLASH_CMD_RDID;

    ep.din_len = 1;
    usb_bulk_write(dev, 6, (char *)&ep, EP6_CMD_HLEN + 1, 1000);
    usb_bulk_read(dev, 6, (char *)&reply, 2, 1000);

    return reply.buf[0];
}

#define SPI_MAX_SIZE 48

void spiflashRead(unsigned long addr, unsigned long nbytes, unsigned char *data)
{
    struct ep6_command ep;
    struct ep6_data reply;
    int total = nbytes;

    while (nbytes) {
        int size = 0;
        ep.control = SPI_WRITE|SPI_READ|SPI_CS_SEL|SPI_CS_REL;
        ep.dout_len = 1 + 3;/* CMD + ADDR */

        ep.dout[0] = SPIFLASH_CMD_READ;
        ep.dout[1] = addr>>16;
        ep.dout[2] = addr>>8;
        ep.dout[3] = addr>>0;

        size = nbytes > SPI_MAX_SIZE ? SPI_MAX_SIZE : nbytes;
        ep.din_len = size;
        usb_bulk_write(dev, 6, (char *)&ep, EP6_CMD_HLEN + ep.dout_len, 1000);
        usb_bulk_read(dev, 6, (char *)&reply, 1 + size, 1000);

        memcpy(data, (void*)reply.buf, size);
        data += size;
        addr += size;
        nbytes -= size;
        fprintf(stderr, "%07d/%07d\r", (int)(total-nbytes), total);
        fflush(stderr);
    }

    return;
}

static void spi_status(int wait)
{
    struct ep6_command ep;
    struct ep6_data reply;
    int status = 0, cnt = 0;

    do {
        /* wait until write is done */
        ep.control = SPI_WRITE|SPI_READ|SPI_CS_SEL|SPI_CS_REL;
        ep.dout_len = 1;
        ep.dout[0] = SPIFLASH_CMD_RDSR;
        ep.din_len = 1;
        usb_bulk_write(dev, 6, (char *)&ep, EP6_CMD_HLEN + 1, 1000);
        usb_bulk_read(dev, 6, (char *)&reply, 2, 1000);
        status = reply.buf[0];
        /*fprintf(stderr, "\t\t\t%04d\r", cnt++);*/
    } while ((status & SPIFLASH_STATUS_BUSY) & wait);
}

void spiflashWrite(unsigned long addr, unsigned long nbytes, unsigned char *data)
{
    unsigned long total = 0;
    unsigned int page;
    unsigned int i;
    unsigned int pagelen;
    struct ep6_command ep;
    struct ep6_data reply;
    
    for (page = 0; 
            page < ((nbytes+SPIFLASH_PAGESIZE-1)>>8); page ++) {
        int size;

        /* enable write */
        ep.control = SPI_WRITE|SPI_CS_SEL|SPI_CS_REL;
        ep.dout_len = 1;
        ep.dout[0] = SPIFLASH_CMD_WREN;
        ep.din_len = 0;
        usb_bulk_write(dev, 6, (char *)&ep, EP6_CMD_HLEN + 1, 1000);

        /* clock out dummy byte to waste time */
        /*ep.control = SPI_READ;
        ep.dout_len = 0;
        ep.din_len = 1;
        usb_bulk_write(dev, 6, (char *)&ep, EP6_CMD_HLEN, 1000);
        usb_bulk_read(dev, 6, (char *)&reply, EP6_DAT_HLEN + 1, 1000);*/

        /* begin write */
        ep.control = SPI_WRITE|SPI_CS_SEL;
        ep.dout_len = 4;
        ep.dout[0] = SPIFLASH_CMD_PAGEPROG;
        ep.dout[1] = addr>>16;
        ep.dout[2] = addr>>8;
        ep.dout[3] = addr>>0;
        usb_bulk_write(dev, 6, (char *)&ep, EP6_CMD_HLEN + 4, 1000);

        if( ((page<<8)+SPIFLASH_PAGESIZE) <= nbytes)
            pagelen = SPIFLASH_PAGESIZE;
        else
            pagelen = nbytes-(page<<8);
        addr += pagelen;

        while (pagelen) {
            size = pagelen > SPI_MAX_SIZE ? SPI_MAX_SIZE : pagelen;
            ep.control = SPI_WRITE;
            ep.dout_len = size;
            memcpy(ep.dout, data, size);
            data += size;
            
            usb_bulk_write(dev, 6, (char *)&ep, EP6_CMD_HLEN + size, 1000);

            pagelen -= size;
            total += size;
            //printf("%d, %d\n", size, addr);
        }
        ep.control = SPI_CS_REL;
        ep.dout_len = 0;
        ep.din_len = 0;
        usb_bulk_write(dev, 6, (char *)&ep, EP6_CMD_HLEN, 1000);

        /* clock out dummy byte to waste time */
        /*ep.control = SPI_READ;
        ep.dout_len = 0;
        ep.din_len = 1;
        usb_bulk_write(dev, 6, (char *)&ep, EP6_CMD_HLEN, 1000);
        usb_bulk_read(dev, 6, (char *)&reply, EP6_DAT_HLEN + 1, 1000);*/

        /* wait until write is done */
        fprintf(stderr, "%07d/%07d\r", (int)total, (int)nbytes);
        fflush(stderr);
        spi_status(1);
        
        /* clock out dummy byte to waste time */
        /*ep.control = SPI_READ;
        ep.dout_len = 0;
        ep.din_len = 1;
        usb_bulk_write(dev, 6, (char *)&ep, EP6_CMD_HLEN, 1000);
        usb_bulk_read(dev, 6, (char *)&reply, EP6_DAT_HLEN + 1, 1000);*/
    }
}

void spiflashChipErase(void)
{
    struct ep6_command ep;
   
    fprintf(stderr, "Erase Flash ...");
    /* enable write */
    ep.control = SPI_WRITE|SPI_CS_SEL|SPI_CS_REL;
    ep.dout_len = 1;
    ep.dout[0] = SPIFLASH_CMD_WREN;
    ep.din_len = 0;
    usb_bulk_write(dev, 6, (char *)&ep, EP6_CMD_HLEN + 1, 1000);
  
    /* clock out dummy byte to waste time */
    ;
    ep.control = SPI_WRITE|SPI_CS_SEL|SPI_CS_REL;
    ep.dout_len = 1;
    ep.dout[0] = SPIFLASH_CMD_CHIPERASE;
    usb_bulk_write(dev, 6, (char *)&ep, EP6_CMD_HLEN + 1, 1000);

    spi_status(1);
    fprintf(stderr, "Done\n");
}

static void bufcpy(unsigned char *dst, unsigned char *src, unsigned int size)
{
    while (size) {
        *dst = lsb[*src];
        dst ++;
        src ++;
        size --;
    }
}

static unsigned char spi_buffer[4 * 1024 * 1024] = {0};

int main(int argc, char *argv[])
{
    int len = 210 * 1024;
    unsigned char v = 0;
    int i, cmp = 0, debug = 0;
    unsigned char *p, *file = "pcitop.bit";

    spiInit(1);

    while (v != 0x20) {
        v = spiflashGetID();
        fprintf(stderr, "ID %x\n", v);
        spiInit(0);
        sleep(1);
    }
    spi_status(1);

    do {
        i = getopt(argc, argv, "DCERWf:B");
        switch (i) {
            case 'D':
                debug = 1;
                break;

            case 'C':
                cmp = 1;
                break;

            case 'B':
                spiBootFpga();
                exit(0);

            case 'f': 
                file = strdup(optarg);
                break;

            case 'E':
                spiflashChipErase();
                break;

            case 'R':
                spiflashRead(0, len, spi_buffer);
                write(1, spi_buffer, len);
                break;

            case 'W':
                p = bit_read(file, &len);
                spiflashWrite(0, len, p);
                write(1, p, len);
                break;
        }
    } while (i != -1);

    if (cmp) {
        p = bit_read(file, &len);
        spiflashRead(0, len, spi_buffer);
        if (memcmp(spi_buffer, p, len) != 0) {
            fprintf(stderr, "compare flash failed\n");
        }
    }

    spiCleanUp();
}
