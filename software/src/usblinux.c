/*
  USB Linux - Userland USB interface routines
  Copyright (c) 2001, Ed Schlunder <zilym@yahoo.com>

  Based upon code originally by Andrew Burgess and Thomas Sailer

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.
  
  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.
*/

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/param.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <regex.h>

#include <linux/usbdevice_fs.h>

#include "usblinux.h"

char usbdevfs[PATH_MAX + 1] = ""; // usbdevfs mount point

int usbCheckDevFS(char *path) {
  char tmp[PATH_MAX + 1];
  int fd;

  if(snprintf(tmp, sizeof(tmp), "%s/devices", path) >= sizeof(tmp)) {
    errno = ENAMETOOLONG;
    return -1;
  }

  // if we can open path/devices file, assume path is a good usbdevfs
  fd = open(tmp, O_RDONLY);
  if(fd == -1)
    return -2;

  close(fd);
  return 0;
}

char *usbFindDevFS(void) {
  char *stdPath[] = { "/proc/bus/usb", "/dev/usb", NULL };
  char *path, tmp[8192];
  int fd, i;
  regex_t preg;
  regmatch_t pm[2];
  
  // First see if the USB_DEVFS_PATH environment variable is set, as seen
  // in the libusb source code...
  path = getenv("USB_DEVFS_PATH");
  if(path != NULL)
    if(usbCheckDevFS(path) == 0) {
      strcpy(usbdevfs, path);
      return usbdevfs;
    }

  // Next try looking in standard locations for usbdevfs
  for(i = 0; stdPath[i] != NULL; i++)
    if(usbCheckDevFS(stdPath[i]) == 0) {
      strcpy(usbdevfs, stdPath[i]);
      return usbdevfs;
    }

  // If all else fails, try finding the usbdevfs by looking in /proc/mounts
  if((fd = open("/proc/mounts", O_RDONLY)) == -1)
    return NULL;

  i = read(fd, tmp, sizeof(tmp) - 1);
  close(fd);
  
  if(i == -1)
    return NULL;

  tmp[i] = 0;
  regcomp(&preg, "^.*[[:space:]]+([^[:space:]]+)[[:space:]]+usbdevfs",
	  REG_EXTENDED | REG_NEWLINE);
  i = regexec(&preg, tmp, 2, pm, 0);
  regfree(&preg);
  if(i != 0) // regex search couldn't find a mounted usbdevfs
    return NULL;

  if(pm[0].rm_so == -1 || pm[1].rm_so == -1)
    return NULL;

  // regex found something, make sure the location found really works.
  tmp[pm[1].rm_eo] = 0;
  if(usbCheckDevFS(tmp + pm[1].rm_so) != 0)
    return NULL;

  // found it, woohoo
  strncpy(usbdevfs, tmp + pm[1].rm_so, sizeof(usbdevfs) - 1);
  usbdevfs[sizeof(usbdevfs)] = 0;
  return usbdevfs;
}


struct usbdevice *usbOpenByNumber(unsigned int bus, unsigned int device) {
  struct usbdevice *dev;
  struct usb_device_descriptor desc;
  int fd;
  char tmp[PATH_MAX + 1];

  // first make sure we have the path to usbdevfs defined
  if(usbdevfs[0] == 0)
    if(usbFindDevFS() == NULL)
      return NULL;

  // open the usbdevfs file of this USB device
  if(snprintf(tmp, sizeof(tmp), 
	      "%s/%03u/%03u", usbdevfs, bus, device) >= sizeof(tmp)) {
    errno = ENAMETOOLONG;
    return NULL;
  }
  fd = open(tmp, O_RDWR);
  if(fd == -1)
    return NULL;

  // try to read the usb device descriptor
  if(read(fd, &desc, sizeof(desc)) != sizeof(desc)) {
    errno = EIO;
    close(fd);
    return NULL;
  }

  // allocate a usbdevice handle for this new device and return it
  dev = malloc(sizeof(struct usbdevice));
  if(dev == NULL) {
    close(fd);
    return NULL;
  }

  dev->fd = fd;
  dev->desc = desc;
  dev->interface = dev->altsetting = 0;
  return dev;
}

struct usbdevice *usbOpen(unsigned int vendor, unsigned int product) {
  int fd, i, bus = -1, device = -1;
  char tmp[16384], *begin, *end, *lineEnd, *cp;

  // first make sure we have the path to usbdevfs defined
  if(usbdevfs[0] == 0)
    if(usbFindDevFS() == NULL)
      return NULL;

  // open the usbdevfs device listing file to scan for this vendor/product ID
  if(snprintf(tmp, sizeof(tmp), 
	      "%s/devices", usbdevfs) >= sizeof(tmp)) {
    errno = ENAMETOOLONG;
    return NULL;
  }
  fd = open(tmp, O_RDONLY);
  if(fd == -1)
    return NULL;

  i = read(fd, tmp, sizeof(tmp));
  close(fd);
  if(i == -1)
    return NULL;

  begin = tmp;
  end = begin + i;
  end[0] = 0;
  while(begin < end) { 
    int tmpVendor = -1, tmpProduct = -1;

    lineEnd = strchr(begin, '\n');
    if(lineEnd == NULL) {
      errno = ENODEV;
      return NULL;
    }
    lineEnd[0] = 0;

    switch(begin[0]) {
    case 'T': // topology
      if((cp = strstr(begin, "Bus=")) != NULL)
	bus = atoi(cp + 4);
      if((cp = strstr(begin, "Dev#=")) != NULL)
	device = atoi(cp + 5);
      break;
    case 'P': // product identification
      if((cp = strstr(begin, "Vendor=")) != NULL)
	tmpVendor = strtoul(cp + 7, NULL, 16);
      if((cp = strstr(begin, "ProdID=")) != NULL)
	tmpProduct = strtoul(cp + 7, NULL, 16);

      // is this the device we were looking for?
      if(vendor == tmpVendor && product == tmpProduct && device > 0 && bus > 0)
	return usbOpenByNumber(bus, device);
      break;
    }
    
    begin = lineEnd + 1;
  }

  return NULL;
}

void usbClose(struct usbdevice *dev) {
  if(!dev)
     return;

  close(dev->fd);
  free(dev);
}

int usbClaimInterface(struct usbdevice *dev, unsigned int intf) {
  int ret;

  dev->interface = intf;
  ret = ioctl(dev->fd, USBDEVFS_CLAIMINTERFACE, &intf);
  if(ret < 0)
    printf("USBDEVFS_CLAIMINTERFACE (intf=0x%x) error %s\n", 
	   intf, strerror(errno));
 
  return ret;
}

int usbReleaseInterface(struct usbdevice *dev, unsigned int intf) {
  int ret;

  ret = ioctl(dev->fd, USBDEVFS_RELEASEINTERFACE, &intf);
  if(ret < 0)
    printf("USBDEVFS_RELEASEINTERFACE (intf=0x%x) error %s\n", 
	   intf, strerror(errno));
 
  return ret;
}

int usbSetAltInterface(struct usbdevice *dev, unsigned int altsetting) {
  struct usbdevfs_setinterface tmp;
  int ret;

  tmp.interface = dev->interface;
  tmp.altsetting = altsetting;
  ret = ioctl(dev->fd, USBDEVFS_SETINTERFACE, &tmp);
  if(ret < 0)
    printf("USBDEVFS_SETINTERFACE (intf=0x%x altset=%u) error %s\n", 
	   tmp.interface, tmp.altsetting, strerror(errno));
  return ret;
}

int usbBulkOut(struct usbdevice *dev, int ep, void *data, int len, int timeout) {
  struct usbdevfs_bulktransfer tmp;
  int ret;

  tmp.ep = ep | USB_DIR_OUT;
  tmp.len = len;
  tmp.timeout = timeout;
  tmp.data = data;
 
  ret = ioctl(dev->fd, USBDEVFS_BULK, &tmp);
  if(ret < 0)
    printf("USBDEVFS_BULKOUT (ep=0x%x len=%u) error %s\n", 
	   ep, len, strerror(errno));
  return ret;
}

int usbBulkIn(struct usbdevice *dev, int ep, void *data, int len, int timeout) {
  struct usbdevfs_bulktransfer tmp;
  int ret;

  tmp.ep = ep | USB_DIR_IN;
  tmp.len = len;
  tmp.timeout = timeout;
  tmp.data = data;
 
  ret = ioctl(dev->fd, USBDEVFS_BULK, &tmp);
  /*
  if(ret < 0)
    printf("USBDEVFS_BULKIN (ep=0x%x len=%u) error %s\n", 
	   ep, len, strerror(errno));
  */
  return ret;
}
