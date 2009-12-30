ifeq ($T,win32)
CC=i586-mingw32msvc-gcc
CFLAGS=-Wall -I../usblib -I.. -I../include -g
ADD=libusb_dyn.o
VPATH=../usblib
else
CC=gcc
CFLAGS=-Wall -I.. -I../include -g
LIBUSB=-lusb
endif

all: fw 24xx spi pcilog

pci_spi: pci_spi.o bit_read.o
	${CC} $^ -o $@
v4_pci_spi: v4_pci_spi.o bit_read.o
	${CC} $^ -o $@
spi: spi.o bit_read.o
	${CC} $^ -o $@ ${LIBUSB}

24xx: 24xx.o i2c.o
	${CC} $^ -o $@ ${LIBUSB}

fw : fw.o bit_read.o ezusb.o fpga.o getopt.o pcilog.o ${ADD}
	${CC} $^ -o $@ ${LIBUSB}

ezconsole : ezconsole.o bit_read.o usblinux.o ${ADD}
	${CC} $^ -o $@ ${LIBUSB}

pci_read: pci_read.o usblinux.o ${ADD}
	${CC} $^ -o $@ ${LIBUSB}

iso: iso.o libusb_augment.o $(ADD)
	${CC} $^ -o $@ ${LIBUSB}

pcilog: pcilog.c
	${CC} $^ -o $@ -DMAIN

clean:
	rm -f *.o fw *~ 24xx pcilog pci_spi spi 
