#include <usb.h>
#include <stdio.h>
#include <signal.h>

#include "getopt.h"

#include "fw.h"
#include "ezusb.h"

/* the device's vendor and product id */
#define MY_VID 0x0547
#define MY_PID 0x2131

static int run = 1;

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

/* OPs */
#define BOOT_USB   BIT_1
#define BOOT_FPGA  BIT_2
#define READ_FIFO  BIT_3
#define WRITE_FIFO BIT_4
#define DO_STATUS  BIT_5
#define DO_EXEC    BIT_6
#define DO_HELP    BIT_7

#define DO_TEST    1<<8
#define DO_PCI     1<<9

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

static void handle_int(int sig)
{
    run = 0;
    fprintf(stderr, "handle_int\n");
}

static char buffer[64 * 1024];
static unsigned char idx_bit[] = {
	0,
	BIT_7,
	BIT_6,
	BIT_6 | BIT_7,
};

int main(int argc, char *argv[])
{
	usb_dev_handle *dev = NULL; /* the device handle */
	char *bfn, *ffn, *rfn, *wfn;
	int ret;
	unsigned long op = DO_HELP;
	int i, idx = 0, cmd, mode = 1;
	unsigned int size = 0;

	usb_init(); /* initialize the library */
	usb_find_busses(); /* find all busses */
	usb_find_devices(); /* find all connected devices */

	do {
		i = getopt(argc, argv, "m:b:f:r:w:s:htSi:E:P");
		switch (i) {
			case 'b': /* update the USB FW to USB */
				op |= BOOT_USB;
				bfn = optarg;
				break;
			case 'f': /* update the FPGA FW */
				ffn = optarg;
				op |= BOOT_FPGA;
				break;
			case 'r': /* Read Data from FIFO */
				op |= READ_FIFO;
				rfn = optarg;
				break;
			case 'w': /* Write Data to FIFO */
				op |= WRITE_FIFO;
				wfn = optarg;
				break;
			case 's': /* buffer size */
				size = atoi(optarg);
				break;
			case 'i': /* idx */
				idx = atoi(optarg);
				break;
			case 'h': /* help */
				op = DO_HELP;
				break;
			case 't':
				op = DO_TEST;
				break;
			case 'S':
				op = DO_STATUS;
				break;
			case 'E':
				op = DO_EXEC;
				cmd = atoi(optarg);
				break;
			case 'P':
			    op = DO_PCI;
				break;
            case 'm':
                mode = atoi(optarg);
                break;
		}
	} while (i != -1);

	if (op == DO_HELP && idx > 2) {
		fprintf(stderr, "fw -b usb.fw -f fpga.bit -r r.dat -w w.dat -s size\n");
		return 0;
	}

	if(!(dev = open_dev(MY_VID, MY_PID))) {
		fprintf(stderr, "error: device not found!\n");
		return 0;
	}

	if(usb_claim_interface(dev, 0) < 0) {
		fprintf(stderr, "error: claiming interface 0 failed\n");
		usb_close(dev);
		return 0;
	}

	struct ep1_command ep, ep_save = {0};
	ep.control = 0;
    ep.tog_control = TOG_INIT;
	usb_bulk_write(dev, 1, (char *)&ep, sizeof(ep), 1000);
	
	ep.control = EP1_INFO;
    ep.tog_control = 0;
	usb_bulk_write(dev, 1, (char *)&ep, sizeof(ep), 1000);
	usb_bulk_read(dev, 1, (char *)&ep_save, sizeof(ep1_info), 1000);

	ep_save.tog_control = 0;
	ep_save.control = E_OUTC;
	
	if (!(op & DO_EXEC)) {
		ep_save.OUTC |= BIT_6 | BIT_7;
		usb_bulk_write(dev, 1, (char *)&ep_save, sizeof(ep), 1000);

		ep_save.OUTC &= ~(BIT_6 | BIT_7);
		usb_bulk_write(dev, 1, (char *)&ep_save, sizeof(ep), 1000);
	}

	if (op & DO_STATUS) {
		struct ep1_info *ep1 = (struct ep1_info *)&ep_save;
		fprintf(stderr, "A OE %02x OUT %02x CFG %02x IN %02x  "
				"  C OE %02x OUT %02x CFG %02x IN %02x ,F %02x ,CK %02x, %02x,%02x, FPGA %02X, FIFO %d, %02X\n",
				ep1->OEA, ep1->OUTA, ep1->PORTACFG, ep1->PINSA,
				ep1->OEC, ep1->OUTC, ep1->PORTCCFG, ep1->PINSC,
				ep1->FASTXFR, ep1->CKCON, ep1->sizeH, ep1->sizeL, 
                ep1->FPGA_STATUS, ep1->FIFO_RD, ep1->MAGIC);
	}

	if (op & BOOT_USB) {
		ret = ezusb_load_image(bfn);
		if (ret != 0)
			return -1;
		ezusb_write_image(dev);
        goto out;
	}

	if (op & BOOT_FPGA) {
		ret = fpga_load_image(dev, ffn, mode);
        goto out;
	}

	if (size > FIFO_MAX_SIZE)
		size = FIFO_MAX_SIZE;

	if (op & DO_EXEC) {
		ep_save.OUTC |= idx_bit[2]; /* SEL LOG */
		usb_bulk_write(dev, 1, (char *)&ep_save, sizeof(ep), 1000);

		memset(buffer, cmd, 8);
		usb_bulk_write(dev, 3, (char *)buffer, 1, 1000);
	}

	if (op & WRITE_FIFO) {
		ep_save.OUTC |= idx_bit[idx];
		usb_bulk_write(dev, 1, (char *)&ep_save, sizeof(ep), 1000);

		/* TODO read the data to buffer */
		FILE *fp = fopen(wfn, "r");
		if (fp == NULL) {
			perror("fopen");
			return -1;
		}
		fread(buffer, size, 1, fp);
		fclose(fp);
		/*int i, j = 0;
		for (i = size; i > 0; i--, j++) 
			buffer[j] = (i & 0xFF);*/

		if (usb_bulk_write(dev, 3, buffer, size, 1000) != size) {
			perror("usb_bulk_write");
			return -1;
		}
	}

	if (op & READ_FIFO) {
		struct ep2_command ep2;

		ep_save.OUTC |= idx_bit[idx];
		usb_bulk_write(dev, 1, (char *)&ep_save, sizeof(ep), 1000);

		ep2.control = FROM_FIFO;
		if (usb_bulk_write(dev, 2, (char *)&ep2, sizeof(ep2), 1000) != 
				sizeof(ep2)) {
			perror("read fifo: usb_bulk_write");
			return -1;
		}
		ret = usb_bulk_read(dev, 2, buffer, size, 1000);
		fprintf(stderr, "ret %d, size %d, [%02x, %02x, %02x, %02x]\n",
				ret, size, buffer[0], buffer[1], buffer[2], buffer[3]);
		if (ret < 0) {
			perror("read fifo: usb_bulk_read");
			return -1;
		}

        FILE *fp = fopen(rfn, "w");
        fwrite(buffer, size, 1, fp);
        fclose(fp);
    }

    if (op & DO_PCI) {
        struct ep1_command ep_status = {0};
        struct ep1_info *ep1 = (struct ep1_info *)&ep_status;
        unsigned int cnt = 0, max = 0; 
        signal(SIGINT, handle_int);
        
        FILE *fp = fopen("pcilog.dat", "w");
        //pciacq_init("pcilog.vcd");
        while (run) {
            struct ep2_command ep2;
            ep2.control = FROM_FIFO;
            if (usb_bulk_write(dev, 2, (char *)&ep2, sizeof(ep2), 1000) !=
                    sizeof(ep2)) {
                perror("read fifo: usb_bulk_write");
                return -1;
            }
            size = 64 * 1024;
            ret = usb_bulk_read(dev, 2, buffer, size, 1000);
            /*fprintf(stderr, "ret %d, size %d, [%02x, %02x, %02x, %02x]\n",
                    ret, size, buffer[0], buffer[1], buffer[2], buffer[3]);*/
            if (ret < 0) {
                perror("read fifo: usb_bulk_read");
                continue;
                /*return -1;*/
            }
            if (ret > 2) {
                unsigned char *end = buffer;
                unsigned char *p = buffer;
                int cur = 0;

                end += ret;

                for (; p < end;) {
                    unsigned int l = 0;
                    
                    if (*p != 0xAA)
                        continue;
                    
                    l = p[1];
                    //hexdump(p, l, 0);
                    p ++; /* 0xAA */
                    p ++; /* len */
                    if (l) {
                        fwrite(p, l, 1, fp);
                        fflush(fp);
                        cnt += l;
                        p += l;
                        cur += l;
                    }
                }
            }

            if (max < ret)
                max = ret;
            printf("%05d %05d\r", cnt, max);
            fflush(stdout);
        }
    }

	if (op & DO_TEST) {
		while (1) {
			struct ep1_command ep;
			ep.control = EP1_INFO;
			ret = usb_bulk_write(dev, 1, (char *)&ep, sizeof(ep), 1000);
			if (ret < 0) {
				perror("usb_bulk_write");
			}
			fprintf(stderr, "w: %d\n", ret);

			ret = usb_bulk_read(dev, 1, buffer, 64, 1000);
			fprintf(stderr, "r: %d\n", ret);

			//sleep(1);
		}
	}
out:
    ep.control = 0;
    ep.tog_control = TOG_EXIT;
    ret = usb_bulk_write(dev, 1, (char *)&ep, sizeof(ep), 1000);

	usb_release_interface(dev, 0);
	usb_close(dev);

	return 0;
}
