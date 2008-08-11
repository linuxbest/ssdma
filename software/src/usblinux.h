/*
  USB Linux - Userland USB interface routines
  Copyright (c) 2001, Ed Schlunder <zilym@yahoo.com>

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.
  
  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.
*/

#ifndef USBLINUX_H
#define USBLINUX_H

#include <sys/types.h>
#include <errno.h>

#define USB_DIR_OUT 0
#define USB_DIR_IN  0x80

/* Device descriptor (from include/usb.h in kernel source tree)*/
struct usb_device_descriptor {
  u_int8_t  bLength;
  u_int8_t  bDescriptorType;
  u_int16_t bcdUSB;
  u_int8_t  bDeviceClass;
  u_int8_t  bDeviceSubClass;
  u_int8_t  bDeviceProtocol;
  u_int8_t  bMaxPacketSize0;
  u_int16_t idVendor;
  u_int16_t idProduct;
  u_int16_t bcdDevice;
  u_int8_t  iManufacturer;
  u_int8_t  iProduct;
  u_int8_t  iSerialNumber;
  u_int8_t  bNumConfigurations;
} __attribute__ ((packed));

struct usbdevice {
  int fd;
  unsigned int interface;
  unsigned int altsetting;
  struct usb_device_descriptor desc;
};


/** Attempts to open the usbdevfs/devices file to verify that the path to
  * the usbdevfs is valid.
  *
  * @param path Path to the usbdevfs mount point that needs testing.
  * @return -1 is path is too long, -2 if devices file couldn't be opened.
  * Returns 0 if path appears to be a valid usbdevfs mount point.
  */
int usbCheckDevFS(char *path);

/** Search the system to find a path where the usbdevfs virtual file system
  * is mounted. 
  * 
  * @return On failure, NULL is returned. Otherwise, the path is copied
  * to the char usbdevfs[] global and a pointer to this is returned.
  */
char *usbFindDevFS(void);

/** Opens a usbdevice handle for the specified bus and device number.
  * 
  * @param bus Bus number that the device resides on.
  * @param device Device number for the device.
  * @return On error, NULL is returned and errno set to error code.
  */
struct usbdevice *usbOpenByNumber(unsigned int bus, unsigned int device);

/** Tries to find a USB device connected that matches the provided
  * vendor and product id codes, then opens a handle for it.
  *
  * @param vendor Vendor ID of the USB device to look for.
  * @param product Product ID of the USB device to find.
  * @return On error, NULL is returned and errno set.
  */
struct usbdevice *usbOpen(unsigned int vendor, unsigned int product);

/** Closes a usbdevice handle and frees the memory used by it.
  *
  * @param dev Pointer to usbdevice handle to close.
  */
void usbClose(struct usbdevice *dev);

/** Claim an interface of a usb device. A USB "interface" is a configuration
  * outlining the possible endpoints that can be used with the device.
  * You must claim an interface before you can use any of the endpoints of
  * the device (other than the control endpoint, which always exists).
  * 
  * @param dev Pointer to usbdevice handle of the device to claim an interface 
  * on.
  * @param intf Interface number to claim.
  * @return 0 on success. 
  */
int usbClaimInterface(struct usbdevice *dev, unsigned int intf);
int usbReleaseInterface(struct usbdevice *dev, unsigned int intf);
int usbSetAltInterface(struct usbdevice *dev, unsigned int altsetting);

int usbBulkIn(struct usbdevice *dev, int ep, void *data, int len, int timeout);
int usbBulkOut(struct usbdevice *dev, int ep, void *data, int len, int timeout);

#endif
