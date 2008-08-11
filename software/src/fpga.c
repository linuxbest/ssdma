#include <usb.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <assert.h>

#include "bit_read.h"
#include "fw.h"

static int
fpga_write_ep1(usb_dev_handle *dev, struct ep1_command *ep1)
{
	int ret = usb_bulk_write(dev, 1, (char *)ep1, sizeof(*ep1), 1000);
	if (ret != sizeof(*ep1)) {
		perror("fpga_write_ep1: usb_bulk_write");
		exit(-1);
	}
	return 0;
}

static int
fpga_read_ep1(usb_dev_handle *dev, struct ep1_info *ep1, char *msg)
{
	int ret = usb_bulk_read(dev, 1, (char *)ep1, sizeof(*ep1), 1000);
	if (ret != sizeof(*ep1)) {
		perror("fpga_read_ep1: usb_bulk_write");
		exit(-1);
	}
	printf("%s  A OE %02x OUT %02x CFG %02x IN %02x  "
		   "  C OE %02x OUT %02x CFG %02x IN %02x , %02x,%02x\n",
			msg, ep1->OEA, ep1->OUTA, ep1->PORTACFG, ep1->PINSA,
			ep1->OEC, ep1->OUTC, ep1->PORTCCFG, ep1->PINSC,
			ep1->sizeH, ep1->sizeL);

	return 0;
}

static int bufcopy(unsigned char *dst, unsigned char *src, 
		unsigned int size, int serial)
{
    int len = serial ? size * 8 : size;

    if (serial == 0) {
        memcpy(dst, src, size);
        return len;
    }

    while (size) {
        int i;
        unsigned char t = *src;

        for (i = 7; i >= 0; i --, dst ++)
            *dst = (t & (1<<i)) ? 1 : 0;

        src ++;
        size --;
    }

    return len;
}

/*
 * Set the PROGRAM signal low.
 * Check that the DONE and INIT are both LOW
 * Set the PROGRAM signal high
 * Wait for INIT to go HIGH
 * Wait 5 more microseconds
 * Start sending data
 */
int fpga_load_image(usb_dev_handle *dev, char *filename, int serial)
{
	unsigned char *buf;
	unsigned int len;
	int ret = -1;
	struct ep1_command ep1 = {0};
	struct ep1_info info;

    /* Write the bit to FIFO */
	buf = bit_read(filename, &len);
	if (buf == NULL) {
		goto out;
	}

	unsigned char *o = malloc(len*10);
	len = bufcopy(o, buf, len, serial);
    
    struct ep6_command ep = {0};
    ep.control = SPI_BOOT_FPGA;
    ep.dout_len = serial;
    ep.din_len = 0;
    usb_bulk_write(dev, 6, (char *)&ep, EP6_CMD_HLEN, 1000);
	
    ep1.control = EP1_INFO;
	fpga_write_ep1(dev, &ep1);
	fpga_read_ep1(dev, &info, "S1:");
    if (info.FPGA_STATUS != 0) {
        printf("Fpga Status is %x\n", info.FPGA_STATUS);
        goto out;
    }

    if (serial == 2)
        memset(o, 0, len);
	ret = usb_bulk_write(dev, 3, (char*)o, len, 10000);
	assert(ret == len);

	/* Finished */
	ep1.control = EP1_INFO | E_OEC;
	ep1.OEC &= ~(FPGA_PROG_M0 | FPGA_PROG_B);
	fpga_write_ep1(dev, &ep1);
	fpga_read_ep1(dev, &info, "S2:");
	
    printf("Loading bit %s using %s mode ... ", filename, 
            !serial ? "P Slave" : "S Slave");
    printf("%s\n", (info.PINSC & FPGA_DONE)  ? "DONE" : "FAILED");

out:
	return ret;
}
