#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <time.h>
#include <ctype.h>

#include "i2c.h"

/* address packing, two or three bytes */
enum { ADDR_2, ADDR_3 };

/* device information struct */
struct device {
	int id;
	int size;
	int writeControlByte;
	int readControlByte;
	int addressingStyle;
	int preClock;
};

/* supported devices - edit this to add more */
struct device devices[] = {
	{ 8,	0x400,	0xA0,	0xA1,	ADDR_2,	0 },
	{ 16,	0x800,	0xA0,	0xA1,	ADDR_2,	0 },
	{ 32,	0x1000,	0xA0,	0xA1,	ADDR_3,	0 },
	{ 64,	0x2000,	0xA2,	0xA3,	ADDR_3,	0 },
	{ 128,	0x4000,	0xA0,	0xA1,	ADDR_3,	0 },
	{ 256,	0x8000,	0xA0,	0xA1,	ADDR_3,	0 },

	{ 21,	0x80,	0xA0,	0xA1,	ADDR_2,	1 },

	{ 0, 0, 0, 0, 0, 0 }
};

static struct device *findDevice(int deviceId) {
	int i;

	for(i = 0; devices[i].id; i++) {
		if(deviceId == devices[i].id) return &(devices[i]);
	}
	fprintf(stderr, "findDevice: unknown device 24C%d\n", deviceId);
	return 0;
}

static int readRandom(struct device *device, int address, char *buf, int len) {
	int i, ret;

	if(device->preClock) i2cSendByte(0);	/* hack for some devices that need clocks to sync up */

	i2cStart();

	/* set read point by doing a partial write */
	switch(device->addressingStyle) {
		case ADDR_2:
			if(i2cSendByte(device->writeControlByte | ((address & 0x700) >> 7))) {
				fprintf(stderr, "read[0x%.3X]: control byte 1 was not ACKed\n", address);
				i2cStop();
				return -1;
			}
			if(i2cSendByte(address & 0xFF)) {
				fprintf(stderr, "read[0x%.3X]: addressing byte 1 was not ACKed\n", address);
				i2cStop();
				return -1;
			}
			break;
		case ADDR_3:
			if(i2cSendByte(device->writeControlByte)) {
				fprintf(stderr, "read[0x%.3X]: control byte 1 was not ACKed\n", address);
				i2cStop();
				return -1;
			}
			if(i2cSendByte((address >> 8) & 0xFF)) {
				fprintf(stderr, "read[0x%.3X]: addressing high byte 1 was not ACKed\n", address);
				i2cStop();
				return -1;
			}
			if(i2cSendByte(address & 0xFF)) {
				fprintf(stderr, "read[0x%.3X]: addressing low byte 1 was not ACKed\n", address);
				i2cStop();
				return -1;
			}
			break;
		default:
			/* should never happen */
			fprintf(stderr, "read[0x%.3X]: unknown device addressing style: %d\n", address, device->addressingStyle);
			break;
	}

	/* now we issue a read */
	i2cStart();
	switch(device->addressingStyle) {
		case ADDR_2:
			if(i2cSendByte(device->readControlByte | ((address & 0x700) >> 7))) {
				fprintf(stderr, "read[0x%.3X]: control byte 2 was not ACKed\n", address);
				i2cStop();
				return -1;
			}
			break;
		case ADDR_3:
			if(i2cSendByte(device->readControlByte)) {
				fprintf(stderr, "read[0x%.3X]: control byte 2 was not ACKed\n", address);
				i2cStop();
				return -1;
			}
			break;
		default:
			/* not reached */
			break;
	}

    /* skip the first bytes */
    ret = i2cReadByte(((i == len - 1)?(SEND_NACK):(SEND_ACK)));

	/* and fill the buffer from the device */
 	for(i = 0; i < len; i++) {
		ret = i2cReadByte(((i == len - 1)?(SEND_NACK):(SEND_ACK)));
		if(ret < 0) {
			fprintf(stderr, "read[0x%.3X]: byte read failed\n", address + i);
			i2cStop();
			return -1;
		}
		buf[i] = ret & 0xFF;
	}

	i2cStop();
	return 0;
}

/*
 * writes the byte value to the specified address
 * returns true on error, zero other wise
 */
static int writeByte(struct device *device, int address, int value) {
	int busy, controlByte = 0;

	if(device->preClock) i2cSendByte(0);	/* hack for some devices that need clocks to sync up */

	i2cStart();

	/* set write point address */
	switch(device->addressingStyle) {
		case ADDR_2:
			controlByte = device->writeControlByte | ((address & 0x700) >> 7);
			if(i2cSendByte(controlByte)) {
				fprintf(stderr, "write[0x%.3X]: control byte was not ACKed\n", address);
				i2cStop();
				return -1;
			}
			if(i2cSendByte(address & 0xFF)) {
				fprintf(stderr, "write[0x%.3X]: addressing byte was not ACKed\n", address);
				i2cStop();
				return -1;
			}
			break;
		case ADDR_3:
			controlByte = device->writeControlByte;
			if(i2cSendByte(controlByte)) {
				fprintf(stderr, "write[0x%.3X]: control byte was not ACKed\n", address);
				i2cStop();
				return -1;
			}
			if(i2cSendByte((address >> 8) & 0xFF)) {
				fprintf(stderr, "write[0x%.3X]: addressing high byte was not ACKed\n", address);
				i2cStop();
				return -1;
			}
			if(i2cSendByte(address & 0xFF)) {
				fprintf(stderr, "write[0x%.3X]: addressing low byte was not ACKed\n", address);
				i2cStop();
				return -1;
			}
			break;
		default:
			fprintf(stderr, "write[0x%.3X]: unknown device addressing style %d\n", address, device->addressingStyle);
			break;
	}

	/* send data byte */
	if(i2cSendByte(value & 0xFF)) {
		fprintf(stderr, "write[0x%.3X]: data byte was not ACKed\n", address);
		i2cStop();
		return -1;
	}

	/* write begins after STOP signal */
	i2cStop();

	/* no we poll for acknowledgement on completion of write */
	for(busy = 1; busy < 1000; busy ++) {
		i2cStart();
		if(!i2cSendByte(controlByte)) {
			if(busy < 1) {
				fprintf(stderr, "write[0x%.3X]: write ACKed immediately, something may be wrong\n", address);
			}
			// fprintf(stderr, "write[0x%.3X]: got ACK, waited %d\n", address, busy);
			i2cStop();
			return 0;
		}
	}

	fprintf(stderr, "write[0x%.3X]: waited %d cycles for ACK, failed!\n", address, busy);
	i2cStop();
	return -1;
}

static int writeRandom(struct device *device, int address, char *buf, int len) {
	int i;

	for(i = 0; i < len; i++) {
		if(writeByte(device, address + i, buf[i])) return -1;
        printf("%04d/%04d\r", i, len);
	}
    writeByte(device, address, buf[0]);
    printf("\n");

	return 0;
}

static void hexdump(char *buf, int len, int offset) {
	int i, j;

	for(i = 0; i < len; i+= 16) {
		printf("0x%.4X: ", i + offset);
		for(j = 0; (j < 16) && (i+j < len); j++) {
			printf("%.2x ", buf[i+j] & 0xFF);
            if (j == 7)
                printf("  ");
        }
		for( ; j < 16; j++)
			printf(" ");
		printf("    ");
		for(j = 0; (j < 16) && (i+j < len); j++)
			if(isprint(buf[i+j]))
				printf("%c", buf[i+j]);
			else
				printf(".");
		printf("\n");
	}
}

static void dump(struct device *device, int start, int len) {
	char *buf = malloc(len);

	if(!readRandom(device, start, buf, len)) {
		hexdump(buf, len, start);
	}
	free(buf);
}

static int dumpToFile(struct device *device, char *filename) {
	int fp, ret;
	char *buf;

	buf = malloc(device->size);

	if(readRandom(device, 0, buf, device->size)) return -1;
	
	if((fp = open(filename, O_WRONLY | O_CREAT)) < 0) {
		perror(filename);
		free(buf);
		return -1;
	}
	ret = write(fp, buf, device->size);
	if(ret != device->size) {
		perror("write()");
		free(buf);
		return -1;
	}
	close(fp);
	fprintf(stderr, "dumpToFile: copied %d bytes to '%s'\n", ret, filename);
	free(buf);
	return 0;
}

static int programFromFile(struct device *device, char *filename) {
	int fp, ret;
	char *buf;

	buf = malloc(device->size);

	if((fp = open(filename, O_RDONLY)) < 0) {
		perror(filename);
		free(buf);
		return -1;
	}
	ret = read(fp, buf, device->size);
	if(ret < 1) {
		perror("read()");
		free(buf);
		return -1;
	}
	close(fp);

	if(writeRandom(device, 0, buf, ret)) return -1;
	fprintf(stderr, "programFromFile: programmed %d bytes from '%s'\n", ret, filename);
	free(buf);
	return 0;
}

static void fill(struct device *device, char b) {
	int i;

	for(i = 0; i < device->size; i++) {
		if(writeByte(device, i, b)) return;
	}
	fprintf(stderr, "fill: cleared %d bytes to 0x%.2X\n", device->size, b & 0xFF);
}

static void usage() {
	fprintf(stderr, "Commands:\n");
	fprintf(stderr, "\tq\t\tQuit\n");
	fprintf(stderr, "\t?\t\tThis usage message\n");
	fprintf(stderr, "\td\t\tDump EEPROM, as hex\n");
	fprintf(stderr, "\tD <start> <len>\tDump EEPROM, as hex\n");
	fprintf(stderr, "\tf <value>\tErase EEPROM, filling with value\n");
	fprintf(stderr, "\tr <filename>\tDump EEPROM into raw binary file\n");
	fprintf(stderr, "\tw <filename>\tProgram EEPROM from raw binary file\n");
	fprintf(stderr, "\tt <type>\tSet EEPROM device type (as 24C<type>)\n");
	fprintf(stderr, "\tp <delay>\tSet delay between I2C transitions (for slower devices)\n");
}

int main(int argc, char **argv) {
	int a, b, run = 1;
	char c, buf[0xFF];
	struct device *device = &(devices[3]), *d;

	if(i2cInit(0x378)) return -1;

	fprintf(stderr, "24C%.2d> ", device->id);
	while(run) {
		if(scanf("%c", &c) < 1) break;
		switch(c) {
			case 't':
				scanf("%i", &a);
				d = findDevice(a);
				if(!d) continue;
				device = d;
				break;
			case 'p':
				scanf("%i", &a);
				if(a < 0) a = 0;
				i2cSetDelay(a);
				fprintf(stderr, "delay set to %d loops\n", a);
				break;
			case 'd':
				dump(device, 0, device->size);
				break;
			case 'D':
				scanf("%i", &a);
				scanf("%i", &b);
				dump(device, a, b);
				break;
			case 'f':
			case 'F':
				scanf("%i", &b);
				fill(device, 0xFF & b);
				break;
			case 'r':
			case 'R':
				scanf("%s", buf);
				dumpToFile(device, buf);
				break;
			case 'w':
			case 'W':
				scanf("%s", buf);
				programFromFile(device, buf);
				break;
			case 'q':
			case 'Q':
				run = 0;
				break;
			case '\n':
				break;
			case 'h':
			case 'H':
			case '?':
				usage();
				break;
		}
		if(c != '\n' && c != 'q' && c != 'Q') {
			fprintf(stderr, "24C%.2d> ", device->id);
		}
	}

	return i2cCleanUp();
}
