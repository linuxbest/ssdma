#include <getopt.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include <stdio.h>
#include <sys/mman.h>

#include <errno.h>

#include "spiflash.h"

#if __linux__
#include <endian.h>
#include <linux/types.h>
#if __BYTE_ORDER == __BIG_ENDIAN
#include <linux/byteorder/big_endian.h>
#endif
#if __BYTE_ORDER == __LITTLE_ENDIAN
#include <linux/byteorder/little_endian.h>
#endif
#define get16(x) __le16_to_cpu(x)
#define get32(x) __le32_to_cpu(x)
#define set16(x) __cpu_to_le16(x)
#define set32(x) __cpu_to_le32(x)
#endif
#include <stdint.h>
#include <linux/pci.h>

#include "bit_read.h"

#define get64(x) (((uint64_t)get32(((uint32_t*)&(x))[1])<<32) | get32(((uint32_t*)&(x))[0]))

#define READ_SPI 0xF
/*
 * BIT0 CLK
 * BIT1 CS
 * BIT2 CMD
 * BIT3 DAT
 * 
 * 0x0  OUT REG
 * 0x4  EN  REG
 * 0x8  IN  REG
 */
enum {
        CLK =24,
        SEL =25,
        CMD =26,
        DAT =27,

        CLK_EN =24,
        SEL_EN =25,
        CMD_EN =26,
        DAT_EN =27,
};
static int debug = 0;
static int 
test_bit(uint32_t val, int bit)
{
        return (val & (1<<bit)) != 0;
}

static volatile uint32_t *virt, *virt_out, *virt_en, *virt_in;

static void spi_status(void)
{
        uint32_t val_in = *virt_in;
        uint32_t val_en = *virt_en;
        uint32_t val_ou = *virt_out;
        static int cnt = 0;
        printf( "CLK: %x CMD: %x DAT: %x SEL: %x \t" 
                "CLK: %x CMD: %x DAT: %x SEL: %x \t"
                "CLK: %x CMD: %x DAT: %x SEL: %x , %08x\n",
                        test_bit(val_in, CLK), 
                        test_bit(val_in, CMD),
                        test_bit(val_in, DAT), 
                        test_bit(val_in, SEL),

                        test_bit(val_en, CLK_EN), 
                        test_bit(val_en, CMD_EN), 
                        test_bit(val_en, DAT_EN),
                        test_bit(val_en, SEL_EN),
                        
                        test_bit(val_ou, CLK), 
                        test_bit(val_ou, CMD), 
                        test_bit(val_ou, DAT),
                        test_bit(val_ou, SEL), cnt ++);
}

static void spi_enable(void)
{
        *virt_en |= 1<<SEL_EN;
        *virt_en |= 1<<CLK_EN;
        *virt_en |= 1<<CMD_EN;
        *virt_en &= ~(1<<DAT_EN);
        
        //*virt_en |= (1<<DAT_EN);
        //*virt &= ~(1<<DAT);

        *virt &= ~(1<<CLK);
        //*virt &= ~(1<<CMD);
        *virt |=  (1<<SEL);
}

static void spi_disable(void)
{
        *virt &= ~(1<<SEL);

        *virt_en &= ~(1<<SEL_EN);
        *virt_en &= ~(1<<CMD_EN);
        *virt_en &= ~(1<<DAT_EN);
        *virt_en &= ~(1<<CLK_EN);
       
        //if (debug) spi_status();
}

static void spi_sel(void)
{
        *virt &= ~(1<<SEL);
}
static void spi_unsel(void)
{
        *virt |= (1<<SEL);
}

static void spi_clearSCK(void)
{
        *virt &= ~(1<<CLK);
}

static void spi_setSCK(void)
{
        *virt |= (1<<CLK);
}

static void spi_bitMOSI(int b)
{
        if (b) 
                *virt |= (1<<CMD);
        else
                *virt &= ~(1<<CMD);
}

static void spi_setMOSI(void)
{
        spi_bitMOSI(1);
}

/* read the bit from DO */
static unsigned char spi_getMISO(void)
{
        uint32_t val = *virt_in;
        return test_bit(val, DAT);
}

static void spi_reset(void)
{
        spi_clearSCK();
        spi_setMOSI();

        spi_unsel();
        spi_unsel();
        spi_sel();
}

static void spi_sendDataBit(int b)
{
        spi_clearSCK();
        spi_bitMOSI(b);
        spi_setSCK();
        if (debug) spi_status();
        spi_clearSCK();
        if (debug) spi_status();
}

static void spi_outb(unsigned char t)
{
        int i;

        spi_clearSCK();
        for (i = 7; i >= 0; i --)
                spi_sendDataBit(t & (1<<i));
        spi_setMOSI();
        if (debug) printf("\n");
}

static unsigned char spi_RecDataBit(void)
{
        unsigned char b;

        spi_clearSCK();
        spi_setSCK();
        b = spi_getMISO();
        if (debug) spi_status();
        spi_clearSCK();
        if (debug) spi_status();

        return b;
}

static unsigned char spi_inb(void)
{
        int i;
        unsigned char t = 0;

        spi_clearSCK();
        for (i = 7; i >= 0; i--)
                if (spi_RecDataBit())
                        t |= (1<<i);
        spi_setMOSI();
        if (debug) printf("\n");

        return t;
}

static int 
spi_readID(void)
{
        uint32_t val;

        spi_sel();
        /* read chip id */ 
        spi_outb(0x9F);
        val = spi_inb();
        spi_unsel();
        
        printf("ID is %x\n", val);
        
        return val;
}

static int 
spi_ready(int wait)
{
        unsigned char status;
        int cnt = 0;

        do {
                spi_sel();
                spi_outb(0x05);
                status = spi_inb();
                spi_unsel();
                fprintf(stderr, "ready %x, %04d\r", status, cnt);
                usleep(1);
                cnt ++;
        } while ((status & SPIFLASH_STATUS_BUSY) && wait);

        return 0;
}

static int
spi_read(char *file, int len)
{
        unsigned char byte;
        int addr = 0, total = len;
        FILE *out;

        out = fopen(file, "w+");
        if (out == NULL) {
                perror("fopen");
                return -1;
        }

        spi_sel();

        spi_outb(0x03);
        spi_outb(addr>>16);
        spi_outb(addr>>8);
        spi_outb(addr);

        while (len) {
                byte = spi_inb();
                if (debug) printf("addr:%x: %02x\n", addr, byte);
                fputc(byte, out);
                len --;
                addr ++;
                fprintf(stderr, "address: %08x/%08x\r", addr, total);
        }
        fprintf(stderr, "done\n");
        fclose(out);

        spi_unsel();

        return 0;
}

#define SPI_MAX_SIZE 256

static int 
spi_write_page(unsigned long addr, unsigned long nbytes, unsigned char *data)
{
    unsigned long total = 0;
    unsigned int page;
    unsigned int i;
    unsigned int pagelen;
    
    for (page = 0; page < ((nbytes+SPIFLASH_PAGESIZE-1)>>8); page ++) {
            int size;

            /* enable write */
            spi_sel();
            spi_outb(SPIFLASH_CMD_WREN);
            spi_unsel();

            /* begin write */
            spi_sel();
            spi_outb(SPIFLASH_CMD_PAGEPROG);
            spi_outb(addr>>16);
            spi_outb(addr>>8);
            spi_outb(addr);

            if( ((page<<8)+SPIFLASH_PAGESIZE) <= nbytes)
                    pagelen = SPIFLASH_PAGESIZE;
            else
                    pagelen = nbytes-(page<<8);
            addr += pagelen;

            while (pagelen) {
                    spi_outb(*data);
                    data ++;
                    pagelen --;
                    total ++;
                    //printf("%d, %d\n", size, addr);
            }
            spi_unsel();

            /* wait until write is done */
            fprintf(stderr, "\t\t%07d/%07d\r", (int)total, (int)nbytes);
            fflush(stderr);
            spi_ready(1);
    }
}

static int
spi_write(char *file, int len)
{
        unsigned char *p;
        len = 0;
        p = bit_read(file, &len);
        if (len == 0) {
                perror("bit_read");
                return -1;
        }

        return spi_write_page(0, len, p);
}

static int
spi_erase(char *file)
{
        fprintf(stderr, "Erase .....\n");

        spi_sel();
        spi_outb(0x06); /* write enable */
        spi_unsel();
        
        spi_sel();
        spi_outb(0xC7); /* erase */
        spi_unsel();

        spi_ready(1);
        fprintf(stderr, "Erase ... done\n");
}

enum {
        SPI_READ  = 1<<0,
        SPI_WRITE = 1<<1,
        SPI_ERASE = 1<<2,
        SPI_IDENT = 1<<3,
        SPI_SNIFFER = 1<<4,
};

#define PCI_DEVFN(slot,func)    ((((slot) & 0x1f) << 3) | ((func) & 0x07))
#define PCI_SLOT(devfn)         (((devfn) >> 3) & 0x1f)
#define PCI_FUNC(devfn)         ((devfn) & 0x07)

static char *
find_pci_device(long id)
{
        FILE *fp = fopen("/proc/bus/pci/devices", "r");
        int dfn;
        long dev;
        char *buf = NULL;
        int res = 0;

        while (getline(&buf, &res, fp) != 0) {
                sscanf(buf, "%4x\t%x", &dfn, &dev);
                //printf("found %x, %x, %s\n", bus, dev, buf);
                if (dev == id)
                        goto found;
                free(buf);
                buf = NULL;
        }

        return NULL;
found:
        sprintf(buf, "/proc/bus/pci/%02d/%02d.%d", 
                        dfn >> 8,
                        PCI_SLOT(dfn & 0xff),
                        PCI_FUNC(dfn & 0xff));
        printf("found %x, %x, %s\n", dfn, dev, buf);
        return buf;
}

int main(int argc, char *argv[])
{
        char *dev = NULL;
        int fd;
        unsigned char config[64];
        int memPhys;
        uint32_t val, c = 0;
        int opt, flags = 0;
        unsigned long ops = 0;
        char *file = "/tmp/flash.rom";
        int len = 210 * 1024;
        int found = 0;

        while ((opt = getopt(argc, argv, "d:D:f:rweisl:")) != -1) {
                switch (opt) {
                        case 'd':
                                dev = strdup(optarg);
                                break;
                        case 'l':
                                len = atoi(optarg);
                                break;
                        case 'D':
                                debug = atoi(optarg);
                                break;
                        case 'f':
                                file = strdup(optarg);
                                break;
                        case 'r':
                                ops |= SPI_READ;
                                break;
                        case 'w':
                                ops |= SPI_WRITE;
                                break;
                        case 'e':
                                ops |= SPI_ERASE;
                                break;
                        case 'i':
                                ops |= SPI_IDENT;
                                break;
                        case 's':
                                ops |= SPI_SNIFFER;
                                break;
                }
        }
        if (dev == NULL)
                dev = find_pci_device(0x01000009);
        if (dev == NULL)
                dev = find_pci_device(0x01000003);

        fd = open(dev, O_RDWR);
        if (fd == -1) {
                perror("open:");
                return -1;
        }

        if (read(fd, config, sizeof(config)) == sizeof(config)) {
                if (config[1] == 0x01 && config[0] == 0x00 && 
                                config[3] == 0x00 && (config[2] == 0x09| config[2] == 0x3))
                        found = 1;
                printf("PCI device %02x%02x:%02x%02x  %s\n", 
                                config[1], config[0], config[3], config[2], 
                                found ? "supported" : "unknow device");
        }
        if (found == 0)
                return 0;
        if (ops == 0) {
                fprintf(stderr, "pci_spi: \n"
                                "-f [rom file] \n"
                                "-d [pci device] default is %s\n"
                                "-r read from spi flash\n"
                                "-w write to spi flash\n"
                                "-e erase the spi flash\n"
                                "-s sniffer the spi bus\n"
                                "-l [len]\n",
                                dev);
                return 0;
        }

        memPhys = get64(         config[0x10]) & ~0xF;
        printf("memPhys %x\n", memPhys);

        errno = ioctl(fd, PCIIOC_MMAP_IS_MEM);
        if (errno) {
                perror("ioctl");
                return -1;
        }
        int mem_fd = open("/dev/mem", O_RDWR);
        virt = mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_SHARED, mem_fd, memPhys);
        if (virt == MAP_FAILED) {
                perror("mmap");
                return -1;
        }

	virt     = virt + 0x19 + 0x100;
        virt_out = virt + 0x0;
        virt_en  = virt + 0x1;
        virt_in  = virt + 0x2;
#if 0
        printf("%08x, %08x, %08x\n", virt_out, virt_en, virt_in);
        printf("%08x, %08x, %08x\n",*virt_out,*virt_en,*virt_in);
        *virt_out = 0xAAAAAAAA; *virt_en  = 0xAAAAAAAA; *virt_in = 0xAAAAAAAA;
        printf("%08x, %08x, %08x\n",*virt_out,*virt_en,*virt_in);
        *virt_out = 0x55555555; *virt_en  = 0x55555555; *virt_in = 0x55555555;
        printf("%08x, %08x, %08x\n",*virt_out,*virt_en,*virt_in);
#endif
        if (ops & SPI_SNIFFER) {
                val = 0;
                spi_disable();
                while (1) {
                        if (val != *virt_in) {
                                spi_status();
                        }
                        val = *virt_in;
                }
        }

        /* spi_enable */
        spi_enable();
        /* spi_reset */
        spi_reset();
        if (ops & SPI_IDENT)
                spi_readID();
       
        /*spi_ready(0);*/
        if (ops & SPI_ERASE) 
                spi_erase(file);

        if (ops & SPI_WRITE)
                spi_write(file, len);

        if (ops & SPI_READ)
                spi_read(file, len);

        /* spi_disable */
        spi_disable();
}
