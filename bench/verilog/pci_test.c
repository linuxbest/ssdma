#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
#include <byteswap.h>
#include <assert.h>
#include "pcisim.h"
#include "lzf_chip.h"

#include "liblzs.c"
#define IfPrint(c) (c >= 32 && c < 127 ? c : '.')

#include "tlsf.h"

static void HexDump(unsigned char *p_Buffer, unsigned long p_Size)
{
        unsigned long l_Index, l_Idx;
        unsigned char l_Row [17];

        for (l_Index = l_Row [16] = 0; 
                        l_Index < p_Size || l_Index % 16; ++l_Index) {
                if (l_Index % 16 == 0)
                        printf("%05x   ", l_Index);
                printf("%02x ", l_Row [l_Index % 16] = (l_Index < p_Size ? 
                                                p_Buffer [l_Index] : 0));
                l_Row [l_Index % 16] = IfPrint (l_Row [l_Index % 16]);
                if ((l_Index + 1) % 16 == 0)
                        printf("   %s\n", l_Row);
        }

        printf("\n");
}
#define POOL_SIZE  1024 * 1024 * 64
static unsigned char system_mem[POOL_SIZE];
static int verbose = 0;

static uint32_t qemu_peek(uint32_t addr)
{
        uint32_t *val = (uint32_t *)system_mem;
        addr /= 4;
        val += addr;
        //printf("qemu_peek: %08lx %08lx\n", addr, *val);
        return *val;
}

static qemu_poke(uint32_t addr, uint32_t val)
{
        uint32_t *p = (uint32_t *)system_mem;
        addr /= 4;
        p += addr;
        //fprintf("qemu_poke: %08lx %08lx\n", addr, val);
        *p = val;
}

static int
pci_reset(unsigned phys_mem)
{
	pcisim_reset(10, 10);
	pcisim_config_write((1<<17) + 0x10, phys_mem);
	pcisim_wait(4, 0);
}

static void
lzf_write(unsigned long base, unsigned int off, unsigned long val)
{
	pcisim_writel(base + off, val);
}

static unsigned long 
lzf_read(unsigned int base, unsigned int off)
{
	return pcisim_readl(base + off);
}

#define readl(x)  pcisim_readl(x)
#define writel(v, r) pcisim_writel(r, v)

typedef struct {
	int mmr_base;
} pcidev_t;
static pcidev_t lzf_dev;
static pcidev_t *dev = &lzf_dev;

static void dump_reg(unsigned int lzf_mem) 
{
        int i = 0, j = 0;
        for (i = 0; i < 4; i ++) {
                uint32_t u0, u1, u2, u3;
                u0 = lzf_read(lzf_mem, j*4); j++;
                u1 = lzf_read(lzf_mem, j*4); j++;
                u2 = lzf_read(lzf_mem, j*4); j++;
                u3 = lzf_read(lzf_mem, j*4); j++;
                printf("%d: %08X %08X %08X %08X\n", i, u0, u1, u2, u3);
        }
}

static int lzf_wait(unsigned int phys_mem, unsigned int lzf_mem)
{
        uint32_t val;

        do {
                pcisim_wait(100, 0xffff);
                val = lzf_read(lzf_mem, OFS_CSR);
        } while (val & CSR_BUSY);

        return 0;
}

typedef struct job_entry {
        void *desc_p; /* pointer to job_desc memory */
        job_desc_t *desc;
        unsigned long desc_phys;

        void *res_p;
        res_desc_t *res;
        unsigned long res_phys;

        buf_desc_t *src, *dst;
        void *src_p, *dst_p;
        unsigned long src_phys, dst_phys;

        struct job_entry *next;

        unsigned char *s, *d;
} job_entry_t;

static void *
tlsf_malloc_align(void **o, unsigned long *off, int len, int size, 
                unsigned long phys_mem)
{
        void *p;
        unsigned long l;
        p = l = tlsf_malloc(size + len);
        if (l & (len-1))
                l += (len-(l%len));
        if (off)
                *off = l - (unsigned long)system_mem + phys_mem;
        if (o)
                *o = p;
        memset(p, 0, size+len);
        return (void *)l;
}

static job_entry_t *
new_job_entry(unsigned long phys_mem)
{
        job_entry_t *j;

        j = malloc(sizeof(*j));
        j->desc = tlsf_malloc_align(&j->desc_p, &j->desc_phys, 32, 
                        sizeof(job_desc_t), phys_mem);
        j->res  = tlsf_malloc_align(&j->res_p,  &j->res_phys,  32, 
                        sizeof(res_desc_t), phys_mem);
        j->desc->ctl_addr  = j->res_phys;

        return j;
}

#define SG_MAX_SIZE 0x40

static int 
map_bufs(unsigned long phys, int size, unsigned long *res, 
                unsigned long phys_mem)
{
        buf_desc_t *b = NULL, *prev = NULL, *h = NULL;
        unsigned long addr = phys, hw_addr;
        int bytes_to_go = size;

        if (bytes_to_go <= SG_MAX_SIZE) {
                b = tlsf_malloc_align(NULL, &hw_addr, 32, 32, phys_mem);
                b->desc_next = 0;
                b->desc      = bytes_to_go;
                b->desc     |= LZF_SG_LAST;
                b->desc_adr  = addr;
                *res = hw_addr;
                return 0;
        } 

        while (bytes_to_go > 0) {
                int this_mapping_len = bytes_to_go;
                int offset = 0;
                while (this_mapping_len > 0) {
                        int this_len = this_mapping_len > SG_MAX_SIZE ?
                                SG_MAX_SIZE : this_mapping_len;
                        b = tlsf_malloc_align(NULL, &hw_addr, 32, 32, phys_mem);
                        b->desc_next = 0;
                        b->desc      = this_len;
                        b->desc_adr  = addr + offset;

                        if (prev == NULL) {
                                h = b;
                                *res = hw_addr;
                        } else {
                                prev->desc_next = hw_addr;
                        }
                        prev = b;

                        this_mapping_len -= this_len;
                        bytes_to_go -= this_len;
                        offset += this_len;
                }
        }
        prev->desc |= LZF_SG_LAST;
        return 0;
}

static int 
do_test(unsigned int phys_mem, unsigned int lzf_mem, int cnt, FILE *fp, 
                int loop, int ops)
{
        job_entry_t *j = NULL, *prev = NULL, *h = NULL;
        unsigned long src_buf_phys, dst_buf_phys, 
                      src_dat_phys, dst_dat_phys;
        unsigned char *src, *dst;
        int i;

        do {
                j = new_job_entry(phys_mem);
                src = tlsf_malloc_align(NULL, &src_dat_phys, 32, cnt, phys_mem);
                dst = tlsf_malloc_align(NULL, &dst_dat_phys, 32, cnt, phys_mem);
                map_bufs(src_dat_phys, cnt, &src_buf_phys, phys_mem);
                map_bufs(dst_dat_phys, cnt, &dst_buf_phys, phys_mem);
                j->s = src;
                j->d = dst;
                for (i = 0; i < cnt; i++)
                        src[i] = i;

                j->desc->dc_fc     = ops | DC_CTRL;
                j->desc->src_desc  = src_buf_phys;
                j->desc->dst_desc  = dst_buf_phys;
                j->next = NULL;

                if (h == NULL) {
                        h = j;
                } else {
                        prev->desc->next_desc = j->desc_phys;
                        prev->desc->dc_fc    |= DC_CONT;
                        prev->next = j;
                }
                prev = j;
                loop --;
        } while (loop > 0);

        lzf_write(lzf_mem, OFS_CCR,  0);
        lzf_write(lzf_mem, OFS_NDAR, h->desc_phys);
        lzf_write(lzf_mem, OFS_CCR,  CCR_ENABLE);

        lzf_wait(phys_mem, lzf_mem);

        j = h;
        while (j) {
                if (verbose) {
                        //HexDump(j->res, 32);
                        //HexDump(j->dst, j->res->ocnt);
                }
                printf("ocnt %d, err %d, cycle %d\n", 
                                j->res->ocnt, j->res->err, j->res->cycle);
                j = j->next;
        }
        /*for (i = i; i < cnt; i ++)
                sssert(dst[i] == i);*/
	return 0;
}

static int 
dev_scan(int dev)
{
	int i = 0, idx = -1, max = 31;
	
	if (dev != -1) {
		max = dev + 1;
		i = dev;
	}
	
	for (; i < max; i++) {
		int j;
		if (pcisim_config_read(1<<i) == 0xffffffff)
			continue;
		printf("%02d: ", i);
		for (j = 0; j < 10; j ++) {
			printf("%08X ", pcisim_config_read((1<<i) + j * 4));
		}
		printf("\n");
		
                if (pcisim_config_read(1<<i) == (0x3 << 16 | 0x100))
                        idx = i;
	}
	
	return idx;
}

int
main(int argc, char *argv[])
{
	int i = 0, idx = -1;
	unsigned int lzf_mem =  0xfa000000;
	unsigned int phys_mem = 0xa0000000;
	unsigned sum;
	int cnt = 64, loop = 0;
	unsigned int opt = 0, p = 0;
        FILE *fp = NULL;

	while ((p = getopt(argc, argv, "NMCUAFhn:fr:vl:")) != EOF) {
		switch (p) {
                case 'l':
                        loop = atoi(optarg);
                        break;
                case 'v':
                        verbose = 1;
                        break;
                case 'r':
                        fp = fopen(optarg, "r");
                        if (fp == NULL) {
                                perror("fopen");
                                return 0;
                        }
                        break;
		case 'h':
			printf("%s: \t-n cnt\n"
                               "\t-N DO NULL\n"
			       "\t-F DO FILL\n"
			       "\t-M DO MEMCPY\n"
			       "\t-C DO COMPRESS\n"
			       "\t-U DO Uncompress\n"
			       "\t-A ALL tested\n", argv[0]);
			return -1;
		case 'N':
			opt = DC_NULL;
			break;
		case 'F':
			opt = DC_FILL;
			break;
		case 'M':
			opt = DC_MEMCPY;
			break;
		case 'C':
			opt = DC_COMPRESS;
			break;
		case 'U':
			opt = DC_UNCOMPRESS;
			break;
                case 'n':
                        cnt = atoi(optarg);
                        break;
		}
	}

        init_memory_pool(POOL_SIZE, system_mem);

	pcisim_init(".", qemu_peek, qemu_poke);
	
	pci_reset(phys_mem);
	
	//show all the pci device 
	idx = dev_scan(-1);
	if (idx != -1)
		printf("Found %04X:%04X at %d\n", 0x100, 0x3, idx);
	else 
		goto done;
        /* master memory_enable */
	int val;
        val = pcisim_config_read((1<<idx) + 4*1);
	pcisim_config_write((1<<idx) + 4*1, val | 1<<1| 1<<2);

        /* cache line */ 
	pcisim_config_write((1<<idx) + 4*3, 0x4004);
        
        /* enable PRE_EN MRL_EN */
        //val = pcisim_config_read((1<<idx) + 4*0x61);
        // W_IMG_CTRL0
        val  = 1 << 0;  /* MRL */
        val |= 1 << 1;  /* PREFETCH */
	pcisim_config_write((1<<idx) + 0x184, val);
        // P_IMG_CTRL0
	//pcisim_config_write((1<<idx) + 0x110, 3);

	pcisim_config_write((1<<idx) + 4*5, lzf_mem);

	dev_scan(idx);
	
	lzf_dev.mmr_base = lzf_mem;

        do_test(phys_mem, lzf_mem, cnt, fp, loop, opt);

 done:
	return 0;
}
