#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <signal.h>
#include <ctype.h>
#include <usb.h>
#if 1
 #include <linux/usbdevice_fs.h>
 #define LIBUSB_AUGMENT
 #include "libusb_augment.h"
#endif

struct usb_dev_handle *devh;

void release_usb_device(int dummy) {
    int ret;
    ret = usb_release_interface(devh, 0);
    if (!ret)
	printf("failed to release interface: %d\n", ret);
    usb_close(devh);
    if (!ret)
	printf("failed to close interface: %d\n", ret);
    exit(1);
}

void list_devices() {
    struct usb_bus *bus;
    for (bus = usb_get_busses(); bus; bus = bus->next) {
	struct usb_device *dev;
	
	for (dev = bus->devices; dev; dev = dev->next)
	    printf("0x%04x 0x%04x\n",
		   dev->descriptor.idVendor,
		   dev->descriptor.idProduct);
    }
}    

struct usb_device *find_device(int vendor, int product) {
    struct usb_bus *bus;
    
    for (bus = usb_get_busses(); bus; bus = bus->next) {
	struct usb_device *dev;
	
	for (dev = bus->devices; dev; dev = dev->next) {
	    if (dev->descriptor.idVendor == vendor
		&& dev->descriptor.idProduct == product)
		return dev;
	}
    }
    return NULL;
}

void print_bytes(char *bytes, int len) {
    int i;
    if (len > 0) {
	for (i=0; i<len; i++) {
	    printf("%02x ", (int)((unsigned char)bytes[i]));
	}
	/*printf("\"");
	for (i=0; i<len; i++) {
		printf("%c", isprint(bytes[i]) ? bytes[i] : '.');
	}
	printf("\"");*/
	}
}


int main(int argc, char **argv) {
    int ret, vendor, product, i;
    struct usb_device *dev;
    char buf[65535], *endptr;
#if 1
    usb_urb *isourb;
    struct timeval isotv;
    unsigned char isobuf[32768];
#endif

    usb_init();
    usb_set_debug(0);
    usb_find_busses();
    usb_find_devices();

    if (argc!=3) {
	printf("usage: %s vendorID productID\n", argv[0]);
	printf("ID numbers of currently attached devices:\n");
	list_devices();
	exit(1);
    }
    vendor = strtol(argv[1], &endptr, 16);
    if (*endptr != '\0') {
	printf("invalid vendor id\n");
	exit(1);
    }
    product = strtol(argv[2], &endptr, 16);
    if (*endptr != '\0') {
	printf("invalid product id\n");
	exit(1);
    }
    dev = find_device(vendor, product);
    assert(dev);

    devh = usb_open(dev);
    assert(devh);
    
    signal(SIGTERM, release_usb_device);

    ret = usb_get_driver_np(devh, 0, buf, sizeof(buf));
    printf("usb_get_driver_np returned %d\n", ret);
    if (ret == 0) {
	printf("interface 0 already claimed by driver \"%s\", attempting to detach it\n", buf);
	ret = usb_detach_kernel_driver_np(devh, 0);
	printf("usb_detach_kernel_driver_np returned %d\n", ret);
    }
    ret = usb_claim_interface(devh, 0);
    if (ret != 0) {
	printf("claim failed with error %d\n", ret);
		exit(1);
    }
    
    //ret = usb_set_altinterface(devh, 2);
    //assert(ret >= 0);

	for (i = 0; i < 256; i++)
		isobuf[i] = i;

	/* iso data */
	ret = usb_isochronous_setup(&isourb, 0x8 | USB_ENDPOINT_IN, 256,
			isobuf, 256);
	printf("iso setup returned %d\n", ret);

	while (1) {
		ret = usb_isochronous_submit(devh, isourb, &isotv);
		printf("iso submit returned %d\n", ret);

		ret = usb_isochronous_reap(devh, isourb, &isotv, 1000);
		printf("iso reap returned %d\n", ret);

		print_bytes(isourb->buffer, ret);
		printf("\n");

		sleep(1);
	}

	ret = usb_release_interface(devh, 0);
	assert(ret == 0);
	ret = usb_close(devh);
	assert(ret == 0);
	return 0;
}
