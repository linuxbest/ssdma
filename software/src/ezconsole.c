// EZ Console
// Copyright (c) 2001, Ed Schlunder <zilym@yahoo.com>

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <signal.h>
#include <string.h>

#include "usblinux.h"
#include "usb_data.h"

#include "bit_read.h"
#include "lsb.h"

#define EPCONSOLE 1
#define USBTIMEOUT 1000

void printUsage(void);

static int usb_req(struct usbdevice *ezusb, unsigned char *obuf)
{
	unsigned char buf[64] = {0};
	struct lzf_usb_header *rsp = (struct lzf_usb_header *)buf;

	usbBulkOut(ezusb, EPCONSOLE, obuf, 64, USBTIMEOUT);
	usbBulkIn(ezusb, EPCONSOLE, buf, 64, USBTIMEOUT);

	if (rsp->status != 0 || obuf[0] == LZF_HEVENT_READ_FPGA ||
		obuf[0] == LZF_HEVENT_FIFO_READ ||
		obuf[0] == LZF_HEVENT_EXEC_FPGA) {
		printf("op %x, ver %d, st %x, PA5/PA7 %x%x "
				"[%02x %02x %02x %02x %02x %02x %02x %02x] "
				"[%02x %02x %02x %02x %02x %02x %02x %02x] \n", 
				rsp->op, rsp->ver, rsp->status, 
				(buf[4] >> 5) & 1, /* PA5 */
				rsp->portc >> 7,   /* PC7 */
				buf[4], buf[5], buf[6], buf[7],
				buf[8], buf[9], buf[10], buf[11],
				buf[12], buf[13], buf[14], buf[15],
				buf[16], buf[17], buf[18], buf[19]
				); 
	}
	if (rsp->op != 0x10) return -1;

    return rsp->portc;
}

static int usb_op(struct usbdevice *ezusb, int op)
{
    unsigned char buf[64];
    struct lzf_usb_header *rsp = (struct lzf_usb_header *)buf;
    
    rsp->op = op;
    return usb_req(ezusb, buf);
}

static int usb_portc(struct usbdevice *ezusb, int portc, int portce, int fwr,
        int data)
{
    unsigned char buf[64];
    struct lzf_usb_header *rsp = (struct lzf_usb_header *)buf;
    struct portc_rsp *portc_rsp = (struct portc_rsp *)(buf + sizeof(*rsp));
    
    rsp->op = LZF_HEVENT_PORTC_RSP;
    rsp->portc = portc;
    
    portc_rsp->portce = portce;
    portc_rsp->fwr = fwr;
    portc_rsp->d = data;

    return usb_req(ezusb, buf);
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

int main(int argc, char *argv[]) 
{
    struct usbdevice *ezusb;
    int bus = -1, device = -1, vendor = 0x547, product = 0x2131;
    unsigned char buf[64] = {0};
    int i, j = 100, tmp, ret = 0, ps = 0;
    struct lzf_usb_header *rsp = (struct lzf_usb_header *)buf;
    struct data_rsp *data_rsp = (struct data_rsp *)(buf + sizeof(*rsp));
    char *file = "ledblink.bit";
	int get_status = 0, bulk_test = 0, fast = 0;
	unsigned int op[7];

    printf("EZ Console v1.0.0\n");
    printf("Copyright (c) 2001, Ed Schlunder <zilym@yahoo.com>\n\n");

    // process command line options
    do {
        i = getopt(argc, argv, "hb:d:v:p:I:E:FBSW:");
        switch(i) {
            case 'b':
                bus = atoi(optarg);
                break;
            case 'd':
                device = atoi(optarg);
                break;
            case 'v':
                vendor = atoi(optarg);
                break;
            case 'p':
                product = atoi(optarg);
                break;
            case 'h':
                printUsage();
                break;
            case 'I':
                file = strdup(optarg);
                break;
			case 'F':
				fast = 1;
				break;
			case 'S': /* get the port data */
				get_status = 1;
				break;
			case 'W': /* Write data to fpga */
				get_status = 2;
				sscanf(optarg, "%x,%x,%x,%x,%x,%x,%x,%x,", 
						op, op+1, op+2, op+3,
						op+4, op+5, op+6, op+7);
				printf("%x,%x,%x,%x,%x,%x,%x,%x\n",
						op[0], op[1], op[2], op[3],
						op[4], op[5], op[6], op[7]);
				break;
			case 'E':
				get_status = 3 ;
				op[0] = atoi(optarg);
				printf("%x\n", op[0]);
				break;
			case 'B':
				bulk_test = 1;
				break;
        }
    } while(i != -1);

    // attempt to connect to the USB device
    if(bus != -1 && device != 1)
        ezusb = usbOpenByNumber(bus, device);
    else
        ezusb = usbOpen(vendor, product);
    if(ezusb == NULL) {
        printf("Error: No EZ USB device connected.\n");
        return 2;
    }

    if(usbClaimInterface(ezusb, 0) < 0)
        return 3;

    //if(usbSetAltInterface(ezusb, 1) < 0)
    //    return 4;

	if (get_status && fast) {
		char buffer[1024] = {0};
		//usbBulkOut(ezusb, 0x8, buffer, 1023, 1000000);
		//printf("Out done\n");
		ret = usbBulkIn(ezusb, 0x8, buffer, 1023, 1000000);
		printf("In done, %d\n", ret);
		int j;
		for (j = 0; j < ret; j ++)
			printf("%02x ", buffer[j]);
		printf("\n");
		exit(0);
	}

	if (get_status) {
		while (get_status == 1) {
			ret = usb_op(ezusb, LZF_HEVENT_READ_FPGA);
			if (ret != -1)
				exit(0);
			usleep(100000);
		}
		
		while (get_status == 2) {
			rsp->op = LZF_HEVENT_WRITE_FPGA;
			data_rsp->dlen = 8;
			data_rsp->d[0] = op[0];
			data_rsp->d[1] = op[1];
			data_rsp->d[2] = op[2];
			data_rsp->d[3] = op[3];
			data_rsp->d[4] = op[4];
			data_rsp->d[5] = op[5];
			data_rsp->d[6] = op[6];
			data_rsp->d[7] = op[7];
			ret = usb_req(ezusb, buf);
			printf("op %02x\n", op[0]);
			if (ret != -1)
				exit(0);
			usleep(100000);
		}

		while (get_status == 3) {
			rsp->op = LZF_HEVENT_EXEC_FPGA;
			data_rsp->d[0] = op[0];
			ret = usb_req(ezusb, buf);
			if (ret != -1)
				exit(0);
			printf("op %02x\n", op[0]);
			usleep(100000);
		}
	}

    usb_op(ezusb, LZF_HEVENT_INIT_RSP);

    /* led test */
    while (0) { /* led blink test */
        usb_portc(ezusb, 1<<LED_0, 1<<LED_0, 0, 0);
        usleep(10000);
        usb_portc(ezusb, 0, 1<<LED_0, 0, 0);
        usleep(20000);
        j --;
    }
	/*               portc porte */
    usb_portc(ezusb, 0xff, 0xff, 0, 0);
    usb_portc(ezusb, 0, 0xff, 0, 0);

	printf("portc: 0x%02x\n", 
			usb_portc(ezusb, 0<<FPGA_PROG_B, 1<<FPGA_PROG_B | ps, 0, 0));
	printf("portc: 0x%02x\n",
			usb_portc(ezusb, 1<<FPGA_PROG_B, 1<<FPGA_PROG_B | ps, 0, 0));

    tmp = usb_portc(ezusb, 0, ps, 0, 0);
    while ( (1 & (tmp >> FPGA_INIT_B)) != 0) {
        tmp = usb_portc(ezusb, 0, ps, 0, 0);
        usleep(10);
        printf("tmp is %x\n", tmp);
    }
    sleep(1);
    printf("Ready\n");

    unsigned char *bit_buf; 
    unsigned long int bit_len;
    bit_buf = bit_read(file, &bit_len);
    if (bit_buf == NULL) 
        goto out;

	int max = 32;//64 - sizeof(struct lzf_usb_header) - sizeof(struct data_rsp);
 	/*printf("max size is %d\n", max);*/

    /* loading bytes */
    i = 0;
    while (i < bit_len) {
        int c;

        rsp->op = LZF_HEVENT_WDATA_RSP;
        c = bit_len - i;
        if (c > max)
            c = max;
        data_rsp->dlen = c;
        data_rsp->mode = ps;
        memcpy(data_rsp->d, bit_buf + i, c);

        ret = usb_req(ezusb, buf);

        i += c;
        printf("progress: %06x/%06lx: %02x\r", i, bit_len, ret);
    }
    printf("%x\n", usb_portc(ezusb, 0, ps, 0, 0)); usleep(1000);

    /* check the done */
    //printf("%x\n", usb_portc(ezusb, 1<<5, 1<<5, 0, 0)); usleep(1000);

out:
    usb_op(ezusb, LZF_HEVENT_EXIT_RSP);
    
    usbReleaseInterface(ezusb, 0);
    usbClose(ezusb);
    return 0;
}

void printUsage(void) {
    printf("Usage: ezconsole [options]\n\n");
    printf(" -b BUS\t\tBUS is the bus number that your EZ USB device is connected to\n");
    printf(" -d DEVICE\tDEVICE is the device number that was assigned at connect\n");
    printf(" OR\n");
    printf(" -v VENDORID\n");
    printf(" -p PRODUCTID\n");
}
