#include <usb.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

struct eeprom_block {
  struct eeprom_block *next;
  unsigned int off;
  unsigned short len;
  void *data;
};
static int ofd = -1;

struct eeprom_block *blocks = NULL;

#define CPUCS_ADDR	0x7F92

#define RW_INTERNAL	0xA0

static int ezusb_write(usb_dev_handle * dev, unsigned short addr,
        const unsigned char *data, size_t len)
{
    char *p;
    unsigned char buf[4];
    fprintf(stderr, "addr:%04x, %04x, %02x, %02x, %c\n", 
            addr, len, data[0], data[1], addr < 0x1B40 ? '.' : '?');
    buf[0] = len >> 8;
    buf[1] = len & 0xff;

    buf[2] = addr >> 8;
    buf[3] = addr & 0xff;

    write(ofd, buf, 4);
    write(ofd, data, len);

    return 0;
}

/* Write to the CPUCS register to stop or reset the CPU */
static int ezusb_cpucs(usb_dev_handle * dev, int run)
{
  unsigned char data = !run;

  return ezusb_write(dev, CPUCS_ADDR, &data, 1);
}

static int ezusb_poke(usb_dev_handle * dev, unsigned short addr,
	const unsigned char *data, size_t len)
{
  int ret, retry = 0;

  /* Control messages aren't NAKd, they are just dropped, so retry */
  while ((ret = ezusb_write(dev, addr, data, len)) < 0 && retry < 5) {
    if (ret != -1)
      break;

    retry++;
  }

  return ret;
}

int hex(char c)
{
  if (c >= 'a' && c <= 'f')
    return c - 'a' + 10;
  else if (c >= 'A' && c <= 'F')
    return c - 'A' + 10;
  else
    return c - '0';
}

/* Parses and loads an Intel HEX image file */
int ezusb_load_image(char *filename)
{
  struct eeprom_block *block, *pblock = NULL;
  int linenum;
  FILE *f;

  f = fopen(filename, "r");
  if (!f) {
    fprintf(stderr, "couldn't open %s: %s\n", filename, strerror(errno));
    return 1;
  }

  /*
   * The IHX file is seperated into groups of up to 16 bytes. To make
   * loading a bit more efficient, we'll merge contiguous groups into
   * one larger group.
   */
  for (linenum = 1; !feof(f); linenum++) {
    char buf[512], *p;
    char type;
    size_t len;
    int i, off;

    if (!fgets(buf, sizeof(buf), f)) {
      fprintf(stderr, "unexpected EOF\n");
      break;
    }

    /* Skip comment lines */
    if (buf[0] == '#')
      continue;

    if (buf[0] != ':') {
      fprintf(stderr, "invalid prefix on line %d: %s", linenum, buf);
      return 1;
    }

    /* Strip off trailing whitespace */
    p = strchr(buf, 0) - 1;
    while (isspace(*p) && p >= buf)
      *p-- = 0;

    /* Length field (1 byte) */
    len = (hex(buf[1]) << 4) + hex(buf[2]);

    /* Offset field (2 bytes) */
    off = (hex(buf[3]) << 12) + (hex(buf[4]) << 8) + (hex(buf[5]) << 4) + hex(buf[6]);

    /* Type field (1 byte) */
    type = (hex(buf[7]) << 4) + hex(buf[8]);

    if (type == 1)
      /* Stop on EOF */
      break;

    if (type != 0) {
      fprintf(stderr, "unsupported type on line %d: %d\n", linenum, type);
      return 1;
    }

    if ((len * 2) > strlen(buf) - 11) {
      fprintf(stderr, "not enough data on line %d: expected %d, found %d\n", linenum, len * 2, strlen(buf) - 11);
      return 1;
    }

    if (pblock && (off == pblock->off + pblock->len) && pblock->len < 512) {
      /* Append to the old block */
      pblock->data = realloc(pblock->data, pblock->len + len);
      if (!pblock->data) {
        fprintf(stderr, "unable to allocate %d bytes for block data\n", pblock->len + len);
        return 1;
      }

      p = pblock->data + pblock->len;
      pblock->len += len;
    } else {
      /* New block */
      block = malloc(sizeof(*block));
      if (!block) {
        fprintf(stderr, "unable to allocate %d bytes for block\n", sizeof(*block));
        return 1;
      }

      block->data = malloc(len);
      if (!block->data) {
        fprintf(stderr, "unable to allocate %d bytes for block data\n", len);
        return 1;
      }

      p = block->data;
      block->off = off;
      block->len = len;

      block->next = blocks;
      pblock = blocks = block;
    }

    for (i = 0; i < len; i++)
      *p++ = (hex(buf[i * 2 + 9]) << 4) + hex(buf[i * 2 + 10]);
  }

  fclose(f);

  return 0;
}

/* Load previously loaded ihx file into device RAM and restart device */
int ezusb_write_image(usb_dev_handle * dev)
{
  struct eeprom_block *block;
  int ret, tl = 0;

  for (block = blocks; block; block = block->next) {
    ret = ezusb_poke(dev, block->off, block->data, block->len);
    if (ret < 0)
      return -1;
    tl += block->len + 4;
  }
  return tl;
}


int main()
{
    int tl = 0;

    unsigned char hbuf[] = {
        0xB2,

        0x47, 0x05,
        0x31, 0x21,
        0x00, 0x01,
    };
    ofd = open("/tmp/1.bit", O_WRONLY | O_CREAT | O_TRUNC, 
            S_IROTH | S_IRUSR | S_IRGRP | S_IWUSR | S_IRWXO);
    int r = write(ofd, hbuf, sizeof(hbuf));
    printf("%d\n", r);
    tl += r;

    ezusb_load_image("../fw/fpga_control_fw.ihx");
    //ezusb_load_image("../fw/w.ihx");
   
    r = ezusb_write_image(NULL);
    printf("%d\n", r);
    tl += r;
   
    unsigned char buf[5];
    int len = 0x8001;
    int addr= 0x7F92;

    buf[0] = len >> 8;
    buf[1] = len & 0xff;

    buf[2] = addr >> 8;
    buf[3] = addr & 0xff;

    buf[4] = 0x00;

    r = write(ofd, buf, 5);
    tl += r;
    printf("%d\n", r);

    fprintf(stderr, "tlen is %d\n", tl);
}
