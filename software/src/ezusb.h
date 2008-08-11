#ifndef EZUSB_H
#define EZUSB_H

int ezusb_load_image(char *filename);
int ezusb_write_image(usb_dev_handle * dev);

int fpga_load_image(usb_dev_handle *dev, char *, int );
int pciacq_init(char *file);
int pciacq_insert(char *buf, int len);

#endif /* EZUSB_H */

