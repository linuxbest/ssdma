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

static void HexDump (unsigned char *p_Buffer, unsigned long p_Size)
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

static int test_0(unsigned int phys_mem, unsigned int lzf_mem)
{
        int off = 0x10000;
        job_desc_t *j = (job_desc_t *)(system_mem + off);
        uint32_t val;

        /**************************************************
         * first we must sure the datapath is ok 
         **************************************************/
        /* test null first */
        j->next_desc = 0;
        j->ctl_addr  = 0;
        j->dc_fc     = DC_NULL;
        j->u0        = 0;
        j->src_desc  = 0;
        j->u1        = 0;
        j->dst_desc  = 0;
        j->u2        = 0;
        lzf_write(lzf_mem, OFS_NDAR, phys_mem + off); 
        lzf_write(lzf_mem, OFS_CCR,  CCR_ENABLE);

        lzf_wait(phys_mem, lzf_mem);
        assert(lzf_read(lzf_mem, 0x14*4) == 0);
        //assert(lzf_read(lzf_mem, 0x15*4) == 0);
        assert(lzf_read(lzf_mem, 0x16*4) == 0);

        /* check register */
        lzf_write(lzf_mem, OFS_CCR,  0);
        j->next_desc = 0x300;
        j->ctl_addr  = 0x200;
        j->src_desc  = 0;
        j->dst_desc  = 0;
        lzf_write(lzf_mem, OFS_NDAR, phys_mem + off); 
        lzf_write(lzf_mem, OFS_CCR,  CCR_ENABLE);
        
        lzf_wait(phys_mem, lzf_mem);
        /* wait 200 clock, it must be done */
        //assert ((val & CSR_BUSY) == 0);
        assert (lzf_read(lzf_mem, 0x14*4) == 0x200);
        assert (lzf_read(lzf_mem, 0x16*4) == 0x300);
        fprintf(stderr, "%04d: passed\n", __LINE__);

        /***********************************************
         * datapath seem ok.
         *
         * testing 1 chain.
         ***********************************************/
        j->next_desc = 0x100;
        j->ctl_addr  = 0;
        j->dc_fc     = DC_FILL | ('a' << 16); /* memset '0a0a0a0a' */
        j->u0        = 0;
        j->src_desc  = 0;
        j->u1        = 0;
        j->dst_desc  = phys_mem + 0x500;

        buf_desc_t *b = (buf_desc_t *)(system_mem + 0x500);
        b->desc     = 0x80 | LZF_SG_LAST;
        b->desc_adr = phys_mem + 0x2000;
        b->desc_next= 0;

        lzf_write(lzf_mem, OFS_CCR,  0);
        lzf_write(lzf_mem, OFS_NDAR, phys_mem + off); 
        lzf_write(lzf_mem, OFS_CCR,  CCR_ENABLE);

        lzf_wait(phys_mem, lzf_mem);
        HexDump(system_mem + 0x2000, 0x100);
        unsigned char *s;
        int i;
        s = system_mem + 0x2000;
        for (i = 0; i < 0x80; i++)
                assert(s[i] == 'a');
        fprintf(stderr, "%04d: passed\n", __LINE__);

        /* 
         * fill with sg address and append mode 
         */
        off = 0x10040;
        j->dc_fc    |= DC_CONT;
        j->next_desc =  phys_mem + off;
        j = (job_desc_t *)(system_mem + off);
        
        off = 0x10080;
        j->next_desc = phys_mem + off;
        j->ctl_addr  = 0;
        j->dc_fc     = DC_FILL | ('b' << 16) | DC_CONT; /* memset '0a0a0a0a' */
        j->u0        = 0;
        j->src_desc  = 0;
        j->u1        = 0;
        j->dst_desc  = phys_mem + 0x600;

        b = (buf_desc_t *)(system_mem + 0x600);
        b->desc     = 0x80 | LZF_SG_LAST;
        b->desc_adr = phys_mem + 0x4000;
        b->desc_next= 0;
        
        j = (job_desc_t *)(system_mem + off);
        j->next_desc = phys_mem + off;
        j->ctl_addr  = 0;
        j->dc_fc     = DC_FILL | ('c' << 16); /* memset '0a0a0a0a' */
        j->u0        = 0;
        j->src_desc  = 0;
        j->u1        = 0;
        j->dst_desc  = phys_mem + 0x700;
        
        b = (buf_desc_t *)(system_mem + 0x700);
        b->desc     = 0x80 /*| LZF_SG_LAST*/;
        b->desc_adr = phys_mem + 0x5000;
        b->desc_next= phys_mem + 0x0800;
        
        b = (buf_desc_t *)(system_mem + 0x800);
        b->desc     = 0x80 | LZF_SG_LAST;
        b->desc_adr = phys_mem + 0x6000;
        b->desc_next= phys_mem + 0x0800;

        lzf_write(lzf_mem, OFS_CCR,  CCR_APPEND|CCR_ENABLE);
        lzf_wait(phys_mem, lzf_mem);
        HexDump(system_mem + 0x4000, 0x90);
        HexDump(system_mem + 0x5000, 0x90);
        HexDump(system_mem + 0x6000, 0x90);
        s = system_mem + 0x4000;
        for (i = 0; i < 0x80; i++)
                assert(s[i] == 'b');
        s = system_mem + 0x5000;
        for (i = 0; i < 0x80; i++)
                assert(s[i] == 'c');
        s = system_mem + 0x6000;
        for (i = 0; i < 0x80; i++)
                assert(s[i] == 'c');
        fprintf(stderr, "%04d: passed\n", __LINE__);

        /* 
         * memory testing 
         */
        s = system_mem + 0x100000; /* 1M */
        int len = 2048;
        for (i = 0; i < len; i++) 
                s[i] = i;
        s = system_mem + 0x200000; /* 2M */
        for (i = 0; i < len; i++) 
                s[i] = 0xff - i;

        off = 0x10100;
        j->dc_fc    |= DC_CONT;
        j->next_desc =  phys_mem + off;
        j = (job_desc_t *)(system_mem + off);

        j->next_desc = 0;
        j->ctl_addr  = 0;
        j->dc_fc     = DC_MEMCPY;
        j->u0        = 0;
        j->u1        = 0;
        j->src_desc  = phys_mem + 0x600;
        j->dst_desc  = phys_mem + 0x700;

        b = (buf_desc_t *)(system_mem + 0x600);
        b->desc     = 0x40;
        b->desc_adr = phys_mem + 0x100000;
        b->desc_next= phys_mem + 0x620;

        b = (buf_desc_t *)(system_mem + 0x620);
        b->desc     = 0x40;
        b->desc_adr = phys_mem + 0x100040;
        b->desc_next= phys_mem + 0x640;

        b = (buf_desc_t *)(system_mem + 0x640);
        b->desc     = 0x40;
        b->desc_adr = phys_mem + 0x100080;
        b->desc_next= phys_mem + 0x660;

        b = (buf_desc_t *)(system_mem + 0x660);
        b->desc     = 0x740 | LZF_SG_LAST;
        b->desc_adr = phys_mem + 0x1000c0;
        b->desc_next= phys_mem + 0x660;

        /* dst */
        b = (buf_desc_t *)(system_mem + 0x700);
        b->desc     = 0x40;
        b->desc_adr = phys_mem + 0x200000;
        b->desc_next= phys_mem + 0x720;
        
        b = (buf_desc_t *)(system_mem + 0x720);
        b->desc     = 0x40;
        b->desc_adr = phys_mem + 0x200040;
        b->desc_next= phys_mem + 0x740;
        
        b = (buf_desc_t *)(system_mem + 0x740);
        b->desc     = 0x40;
        b->desc_adr = phys_mem + 0x200080;
        b->desc_next= phys_mem + 0x760;

        b = (buf_desc_t *)(system_mem + 0x760);
        b->desc     = 0x740 | LZF_SG_LAST;
        b->desc_adr = phys_mem + 0x2000c0;
        b->desc_next= phys_mem + 0x760;
        
        lzf_write(lzf_mem, OFS_CCR,  CCR_APPEND|CCR_ENABLE);
        lzf_wait(phys_mem, lzf_mem);
        /*HexDump(system_mem + 0x100000, len);
        HexDump(system_mem + 0x200000, len);*/

        /* speed testing */
        off = 0x100;
        j->dc_fc    |= DC_CONT;
        j->next_desc =  phys_mem + off;
        j = (job_desc_t *)(system_mem + off);
        memset(system_mem + 0x200, 0, 32);

        j->next_desc = phys_mem + 0x220;
        j->ctl_addr  = phys_mem + 0x200;
        j->dc_fc     = DC_MEMCPY | DC_CTRL | DC_CONT;
        j->u0        = 0;
        j->u1        = 0;
        j->src_desc  = phys_mem + 0x600;
        j->dst_desc  = phys_mem + 0x700;
        
        off = 0x220;
        j = (job_desc_t *)(system_mem + off);
        memset(system_mem + 0x200, 0, 32);

        j->next_desc = 0;
        j->ctl_addr  = phys_mem + 0x240;
        j->dc_fc     = DC_MEMCPY | DC_CTRL;
        j->u0        = 0;
        j->u1        = 0;
        j->src_desc  = phys_mem + 0x600;
        j->dst_desc  = phys_mem + 0x800;

        b = (buf_desc_t *)(system_mem + 0x600);
        b->desc     = 0x1000 | LZF_SG_LAST;
        b->desc_adr = phys_mem + 0x100000;
        b->desc_next= phys_mem + 0x620;
        uint32_t *p = (uint32_t *)(system_mem + 0x100000);
        for (i = 0; i < 0x400; i ++, p ++)
                *p = i;
        b = (buf_desc_t *)(system_mem + 0x700);
        b->desc     = 0x1000 | LZF_SG_LAST;
        b->desc_adr = phys_mem + 0x200000;
        b->desc_next= phys_mem + 0x640;
        
        b = (buf_desc_t *)(system_mem + 0x800);
        b->desc     = 0x1000 | LZF_SG_LAST;
        b->desc_adr = phys_mem + 0x300000;
        b->desc_next= phys_mem + 0x640;

        lzf_write(lzf_mem, OFS_CCR,  CCR_APPEND|CCR_ENABLE);
        lzf_wait(phys_mem, lzf_mem);
       
        p = (uint32_t *)(system_mem + 0x200);
        HexDump((char *)p, 32);
        printf("cycle %04x\n", *(p+2));
        
        p = (uint32_t *)(system_mem + 0x240);
        HexDump((char *)p, 32);
        printf("cycle %04x\n", *p);

        /*
         * compress tesing
         */
        off = 0x100;
        j->dc_fc    |= DC_CONT;
        j->next_desc =  phys_mem + off;
        j = (job_desc_t *)(system_mem + off);
        memset(system_mem + off, 0, 32);

        j->next_desc = 0;
        j->ctl_addr  = phys_mem + 0x240;
        j->dc_fc     = DC_COMPRESS | DC_CTRL;
        j->u0        = 0;
        j->u1        = 0;
        j->src_desc  = phys_mem + 0x600;
        j->dst_desc  = phys_mem + 0x800;

        b = (buf_desc_t *)(system_mem + 0x600);
        b->desc     = 0x200 | LZF_SG_LAST;
        b->desc_adr = phys_mem + 0x100000;
        b->desc_next= phys_mem + 0x620;
        uint8_t *a = (uint8_t *)(system_mem + 0x100000);
        for (i = 0; i < 0x1000; i ++, a ++)
                *a = i;
        
        b = (buf_desc_t *)(system_mem + 0x800);
        b->desc     = 0x1000 | LZF_SG_LAST;
        b->desc_adr = phys_mem + 0x300000;
        b->desc_next= phys_mem + 0x640;
#if 1
        off = 0x120;
        j->dc_fc    |= DC_CONT;
        j->next_desc =  phys_mem + off;
        j = (job_desc_t *)(system_mem + off);
        memset(system_mem + off, 0, 32);

        j->next_desc = 0;
        j->ctl_addr  = phys_mem + 0x260;
        j->dc_fc     = DC_COMPRESS | DC_CTRL;
        j->u0        = 0;
        j->u1        = 0;
        j->src_desc  = phys_mem + 0x600;
        j->dst_desc  = phys_mem + 0x900;
#endif
        b = (buf_desc_t *)(system_mem + 0x900);
        b->desc     = 0x1000 | LZF_SG_LAST;
        b->desc_adr = phys_mem + 0x400000;
        b->desc_next= phys_mem + 0x640;

        lzf_write(lzf_mem, OFS_CCR,  CCR_APPEND|CCR_ENABLE);
        lzf_wait(phys_mem, lzf_mem);

        p = (uint32_t *)(system_mem + 0x240);
        HexDump(system_mem + 0x300000, *(p));
        p = (uint32_t *)(system_mem + 0x260);
        HexDump(system_mem + 0x400000, *(p));

        p = (uint32_t *)(system_mem + 0x240);
        HexDump((char *)p, 32);
        printf("compress cycle %04x\n", *(p+4));
        
        p = (uint32_t *)(system_mem + 0x260);
        HexDump((char *)p, 32);
        printf("compress cycle %04x\n", *(p+4));
 
        /*
         * uncompress testing
         */
        return 0;
}

typedef struct {
        void *desc_p; /* pointer to job_desc memory */
        job_desc_t *desc;
        unsigned long desc_phys;

        void *res_p;
        res_desc_t *res;
        unsigned long res_phys;

        buf_desc_t *src, *dst;
        void *src_p, *dst_p;
        unsigned long src_phys, dst_phys;
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

static int do_uncompress(unsigned int phys_mem, unsigned int lzf_mem, 
                int cnt, FILE *fp)
{
	int i, j = 0, err = 0;
	uint32_t val = 0;
	unsigned char in_buffer[1024 * 1024];
	unsigned char uncompress_buffer[1024 * 1024];
	unsigned char compress_buffer[1024 * 1024];
	uint32_t *buf = (uint32_t *)compress_buffer;
	uint32_t len = 0;

        if (fp == NULL) {
                for (i = 0; i < cnt; i++)
                        in_buffer[i] = i % 0x100;
        } else {
                fread(in_buffer, cnt, 1, fp);
        }
        len = lzsCompress(in_buffer, cnt, compress_buffer, 1024 * 1024);
        printf("UNCOMPRESS, %d\n", len);

        memcpy(system_mem, compress_buffer, len);
        printf("%x\n", len);
#if 0
	/* fill the chain desc memory */
	chain_desc *desc = system_mem + 0x95000;
	memset((void*)desc, 0, sizeof(*desc));
	desc->nad = 0;
	desc->sad = phys_mem;
	desc->dad = phys_mem + 0x50000;
	desc->sbc = len;
	desc->dbc = cnt;
	desc->dc  = DC_UNCOMPRESS | DC_CTRL;
        desc->cad  = phys_mem + 0x90000;

	
	lzf_write(lzf_mem, ADMA_OFS_NDAR, phys_mem+0x95000);
	lzf_write(lzf_mem, ADMA_OFS_CCR, 2); /* enable it */
	
        i = cnt*2;
        while ((val = lzf_read(lzf_mem, ADMA_OFS_CSR) & (1<<10)) && i) {
                pcisim_wait(100, 0xffff);
		i --;
	}
	if (i == 0) {
		printf("ERROR\n");
	//	return -1;
	}
	buf = in_buffer;
	int err = 0;
        uint32_t *c = system_mem + 0x50000;	
	for (i = 0; i < cnt/4; i ++, c++) {
                if (buf[i] != *c) {
                        err ++;
                }
                printf("%02X   %08X, %08X  %s\n", 
                                i, *c, buf[i], buf[i] != *c ? "XXX" : "");
        }
#endif
	if (err == 0)
		printf("\tPASSED\n");
	else
		printf("\tFAILED\n");
	
	return 0;
}

static int do_compress(unsigned int phys_mem, unsigned int lzf_mem, 
                int cnt, FILE *fp)
{
	int i, j = 0, err = 0;
	uint32_t *val = 0;
	unsigned char in_buffer[1024*1024];
	unsigned char out_buffer[1024*1024];
	unsigned char check_buffer[1024*1024];
	uint32_t *buf = (uint32_t *)in_buffer;

        if (fp == NULL) {
                for (i = 0; i < cnt; i++)
                        in_buffer[i] = i % 0x100;
        } else {
                i = fread(in_buffer, cnt, 1, fp);
        }
	/*printf("COMPRESS, cnt %d, %p, %d\n", cnt, fp, i);
        HexDump(in_buffer, cnt);*/

        memcpy(system_mem + 0x10000, in_buffer, cnt);
#if 0	
	/* fill the chain desc memory */
	chain_desc *desc = system_mem;
	memset((void*)desc, 0, sizeof(*desc));
	desc->nad  = 0;
	desc->sad  = phys_mem + 0x10000;
	desc->dad  = phys_mem + 0x50000;
	desc->sbc  = cnt;
	desc->dbc  = 1024 * 1024;
	desc->dc   = DC_COMPRESS | DC_CTRL;
        desc->cad  = phys_mem + 0x01000;

        //printf("submit it\n");
	lzf_write(lzf_mem, ADMA_OFS_CCR, 0); /* enable it */
	lzf_write(lzf_mem, ADMA_OFS_NDAR, phys_mem);
	lzf_write(lzf_mem, ADMA_OFS_CCR, 2); /* enable it */
        //printf("submit done\n");
	
	i = cnt;
	while ((val = lzf_read(lzf_mem, ADMA_OFS_CSR) & (1<<10)) && i) {
		pcisim_wait(100, 0xffff);
		//i --;
                //printf("%d\n", i);
	}
	if (i == 0) {
		printf("ERROR\n");
		//return -1;
	}
        memset(check_buffer, 0, cnt*2);
        int olen = lzsCompress(in_buffer, cnt, check_buffer, cnt*2);
        if (olen % 4)
                olen += 4;
	buf = check_buffer;
	int err = 0;
        uint32_t *c = system_mem + 0x50000;
	for (i = 0; i < olen/4; i ++, c++) {
                printf("%04X FPGA/C  %08X, %08X %s\n", i, *c, buf[i], 
                                buf[i] != *c ? "XXXX" : "");
                if (buf[i] != *c) {
			err ++;
		}
	}
        c = system_mem + 0x1000;
	for (i = 0; i < 8; i ++, c++) {
                printf("%02X CTL  %08X\n", i, *c);
	}
#endif
	if (err == 0)
		printf("\tPASSED\n");
	else
		printf("\tFAILED\n");
	return 0;
}

static int do_memcpy(unsigned int phys_mem, unsigned int lzf_mem, int cnt)
{
        job_entry_t *j;
        unsigned long src_buf_phys, 
                      dst_buf_phys, 
                      src_dat_phys, 
                      dst_dat_phys;
        unsigned char *src, *dst;
        int i;

        j = new_job_entry(phys_mem);
        src = tlsf_malloc_align(NULL, &src_dat_phys, 32, cnt, phys_mem);
        dst = tlsf_malloc_align(NULL, &dst_dat_phys, 32, cnt, phys_mem);
        map_bufs(src_dat_phys, cnt, &src_buf_phys, phys_mem);
        map_bufs(dst_dat_phys, cnt, &dst_buf_phys, phys_mem);

        for (i = 0; i < cnt; i++)
                src[i] = i;

        j->desc->dc_fc     = DC_MEMCPY /*| DC_CTRL*/;
        j->desc->src_desc  = src_buf_phys;
        j->desc->dst_desc  = dst_buf_phys;
        /*printf("buf %x, %x\n", src_buf_phys, dst_buf_phys);*/

        lzf_write(lzf_mem, OFS_CCR,  0);
        lzf_write(lzf_mem, OFS_NDAR, j->desc_phys);
        lzf_write(lzf_mem, OFS_CCR,  CCR_ENABLE);

        lzf_wait(phys_mem, lzf_mem);

        HexDump(dst, cnt);

	return 0;
}

/*
 * A simple chain test 
 */
static int 
do_null(unsigned int phys_mem, unsigned int lzf_mem)
{
        job_entry_t *j, *n;

        j = new_job_entry(phys_mem);
        n = new_job_entry(phys_mem);

        j->desc->dc_fc     = DC_NULL | DC_CONT;
        j->desc->next_desc = n->desc_phys;

        n->desc->dc_fc     = DC_NULL;
        n->desc->ctl_addr  = 0xFFFFFFFF;
        n->desc->next_desc = 0x1FFFFFFF;

        lzf_write(lzf_mem, OFS_NDAR , j->desc_phys);
        lzf_write(lzf_mem, OFS_CCR , 2); /* enable it */

        lzf_wait(phys_mem, lzf_mem);
        lzf_write(lzf_mem, OFS_CCR, 0);

        assert(lzf_read(lzf_mem, 0x16*4) == 0x1ffffff8);

        return 0;
}

static int do_fill(unsigned int phys_mem, unsigned int lzf_mem, int cnt)
{
        job_entry_t *j;
        unsigned long buf_phys, dat_phys;
        buf_desc_t *buf;
        unsigned char *dat;

        j = new_job_entry(phys_mem);
        buf = tlsf_malloc_align(NULL, &buf_phys, 32, sizeof(*buf), phys_mem);
        dat = tlsf_malloc_align(NULL, &dat_phys, 32, 0x100, phys_mem);

        j->desc->dc_fc     = DC_FILL | ('a' << 16);
        j->desc->dst_desc  = buf_phys;

        buf->desc     = 0x80 | LZF_SG_LAST;
        buf->desc_adr = dat_phys;

        lzf_write(lzf_mem, OFS_CCR,  0);
        lzf_write(lzf_mem, OFS_NDAR, j->desc_phys);
        lzf_write(lzf_mem, OFS_CCR,  CCR_ENABLE);

        lzf_wait(phys_mem, lzf_mem);

        int i;
        for (i = 0; i < 0x80; i++)
                assert(dat[i] == 'a');

	return 0;
}

static int do_fill_loop(unsigned int phys_mem, unsigned int lzf_mem, int cnt)
{
        /* TODO */
}

enum DO_OPT {
	DO_NULL = 1<<0,
	DO_FILL = 1<<1,
	DO_MEMCPY = 1<<2,
	DO_COMPRESS =  1<<3,
	DO_UNCOMPRESS = 1<<4,
        DO_FILL_LOOP  = 1<<5,
};

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
	int cnt = 64;
	unsigned int opt = 0, p = 0;
        FILE *fp = NULL;

	while ((p = getopt(argc, argv, "NMCUAFhn:fr:")) != EOF) {
		switch (p) {
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
			opt |= DO_NULL;
			break;
		case 'F':
			opt |= DO_FILL;
			break;
                case 'f':
			opt |= DO_FILL_LOOP;
                        break;
		case 'M':
			opt |= DO_MEMCPY;
			break;
		case 'C':
			opt |= DO_COMPRESS;
			break;
		case 'U':
			opt |= DO_UNCOMPRESS;
			break;
		case 'A':
			opt = 0xFFFFFFFF;
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
        /*dump_reg(lzf_mem);*/
        /*test_0(phys_mem, lzf_mem);*/
#if 0	
	if (sum != DMA_MAGIC_NUM) {
		printf("Magic %x\n", sum);
                sum = lzf_read(lzf_mem, ADMA_OFS_MAGIC);
                return -1;
	}
	printf("MAGIC: %08X, %x\n", sum, ADMA_OFS_MAGIC * 4);
#endif
	if (opt & DO_NULL && do_null(phys_mem, lzf_mem) != 0)
		return -1;
	
	if (opt & DO_FILL && do_fill(phys_mem, lzf_mem, cnt) != 0)
		return -1;
	if (opt & DO_FILL_LOOP && do_fill_loop(phys_mem, lzf_mem, cnt) != 0)
		return -1;
	
	if (opt & DO_MEMCPY && do_memcpy(phys_mem, lzf_mem, cnt) != 0)
		return -1;
	
        if (opt & DO_COMPRESS && do_compress(phys_mem, lzf_mem, cnt, fp) != 0)
		return -1;
	
	if (opt & DO_UNCOMPRESS && do_uncompress(phys_mem, lzf_mem, cnt, 
                                fp) != 0)
		return -1;

 done:
	return 0;
}
