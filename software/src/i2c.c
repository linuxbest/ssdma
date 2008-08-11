#include <usb.h>
#include <stdio.h>
#include "fw.h"

#include "i2c.h"

/* the device's vendor and product id */
#define MY_VID 0x0547
#define MY_PID 0x2131

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

int i2cInit(void)
{

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

    struct ep1_command ep = {0};
    ep.tog_control = TOG_INIT;
    usb_bulk_write(dev, 1, (char *)&ep, sizeof(ep), 1000);

    return 0;
}

void i2cSetDelay(int delay)
{
}

int i2cCleanUp()
{
    struct ep1_command ep = {0};
    ep.tog_control = TOG_EXIT;
    usb_bulk_write(dev, 1, (char *)&ep, sizeof(ep), 1000);

    return 0;
}

void i2cStart()
{
    ep4_command ep;
    ep.control = E_I2CS;
    ep.I2CS = I2START;
    usb_bulk_write(dev, 4, (char *)&ep, sizeof(ep), 1000);
}

void i2cStop()
{
    ep4_command ep;
    ep.control = E_I2CS;
    ep.I2CS = I2STOP;
    usb_bulk_write(dev, 4, (char *)&ep, sizeof(ep), 1000);
}
static int d = 0;
/*
 * Sends byte over the i2c bus
 * Will return 0 on sucessful (acked) transfer)
 * Non-zero otherwise
 */
int i2cSendByte(int byte)
{
    ep4_command ep;

    if (d)printf("W: %02X\n", byte);
    ep.control = E_I2DAT;
    ep.I2DAT = byte;
    usb_bulk_write(dev, 4, (char *)&ep, sizeof(ep), 1000);
   
    return 0;
}

int i2cReadByte(int ackControl)
{
    ep4_command ep;
    ep4_data data;
    int ret;

    if (d)printf("R: %02X, ", ackControl);
    ep.control = E_READ;
    usb_bulk_write(dev, 4, (char *)&ep, sizeof(ep), 1000);
    
    ret = usb_bulk_read(dev, 4, (char *)&data, sizeof(data), 1000);
    if (d)printf(" %d: %02X, %02X\n", ret, data.I2CS, data.I2DAT);
    if (ackControl == EXPECT_ACK)
        return 0;
    return data.I2DAT;
}
