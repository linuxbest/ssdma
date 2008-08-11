#include <stdio.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

static FILE *fp;

static int num_to_str(uint64_t num, int bit, int sym)
{
	int i = 0;
	static char buffer[32768];
	unsigned char *o = buffer;

	o += sprintf(o, "b");
	if (bit > 1)
		for (i = bit-1; i >= 0; i--)
			o += sprintf(o, "%c", ((num >> i) & 1) ? '1' : '0');
	else 
		o += sprintf(o, "%c", (num) ? '1' : '0');

	fprintf(fp, "%s <%c\n", buffer, sym);

	return 0;
}

static char *file_head = 
"$date\n"
"  %s\n"
"$end\n"
"$version\n"
"  PCILOG\n"
"$end\n"
"$timescale\n"
" 1ns\n"
"$end\n"
"$scope module top $end\n";

static struct bit_name {
	int bit;
	char *name;
} pci_signals[] = {
	{32, "AD"},
	
	{4, "CBE"},
	{1, "IRDYn"},
	{1, "TRDYn"},
	{1, "FRAMEn"},
	{1, "DEVSELn"},
	
	{1, "IDSEL"},
	{1, "PAR"},
	{1, "GNTn"},
	{1, "LOCKn"},
	{1, "PERRn"},
	{1, "REQn"},
	{1, "SERRn"},
	{1, "STOPn"},

    {32,"AD64"},
    {4, "CBE64"},
    {1, "REQ64"},
    {1, "PAR64"},
    {1, "ACK64"},
    {1, "INTA"},
   
    {4, "ch_state"},
    {3, "dma_unit_state"},
    
    {1, "wbs_ack_o"},
    {1, "wbs_cyc_i"},
    {1, "wbs_stb_i"},
    {1, "wbs_we_i"},
    {1, "wbm_ack_i"},
    {1, "wbm_cyc_o"},
    {1, "wbm_stb_o"},
    {1, "wbm_we_o"},

    {16, "CNT"},

	{0, NULL},
};


int pciacq_init(char *file)
{
    if (file == NULL)
        fp = stdout;
    else
        fp = fopen(file, "w");

	fprintf(fp, file_head, "Tue Jun 19 09:11:03 2007");
    	
	int i = 'a';
	struct bit_name *bn = pci_signals;
	while (bn->bit) {
		fprintf(fp, "$var wire %d <%c %s $end\n", bn->bit,
				i ,bn->name);
		bn ++;
		i++;
	}
	fprintf(fp, "%s", "$upscope $end\n"
	"$enddefinitions $end\n"
	"\n"
	"#0\n"
	"$dumpvars\n");
}

int pciacq_insert(unsigned char *buf, int len)
{
    do {
        buf ++;
        len --;
    } while (buf[15] != 0xAA);

	int cnt = 0;
	while (len > 16) {
		int j = 'a';
        unsigned char *b = buf + 8;
		fprintf(fp, "#%d\n", cnt);

        if (buf[15] != 0xAA) {
            fprintf(stderr, "%02x, %02x, %02x, %02x, %02x, %02x, %02x, %02x  ", 
                    buf[0], buf[1], buf[2], buf[3], buf[4], buf[5], buf[6], 
                    buf[7]);
            fprintf(stderr, "%02x, %02x, %02x, %02x, %02x, %02x, %02x, %02x\n", 
                    b[0], b[1], b[2], b[3], b[4], b[5], b[6], b[7]);
            continue;
            /*return*/;
        }
#define get4bytes(x, y) ((x[y] << 24) + (x[y-1] << 16) + (x[y-2] << 8) + x[y-3])

		num_to_str(get4bytes(buf, 11), 32, j); j++;; /* AD */
		/* CBE */
		num_to_str((buf[7] & 0xF0)>>4, 4, j); j++;  
		/* IRDYn */
		num_to_str(buf[7] & 8, 1, j); j++;
		/* TRDYn */
		num_to_str(buf[7] & 4, 1, j); j++;
		/* FRAMEn */
		num_to_str(buf[7] & 2, 1, j); j++;
		/* DEVSELn */
		num_to_str(buf[7] & 1, 1, j); j++;

        /* IDSEL */
		num_to_str(buf[6] & 128, 1, j); j++;
        /* PAR */
		num_to_str(buf[6] & 64, 1, j); j++;
        /* GNTn */
		num_to_str(buf[6] & 32, 1, j); j++;
        /* LOCKn */
		num_to_str(buf[6] & 16, 1, j); j++;
        /* PERRn */
		num_to_str(buf[6] & 8, 1, j); j++;
        /* REQn */
		num_to_str(buf[6] & 4, 1, j); j++;
        /* SERRn */
		num_to_str(buf[6] & 2, 1, j); j++;
        /* STOPn */
		num_to_str(buf[6] & 1, 1, j); j++;

        /* AD64 */
        num_to_str(get4bytes(buf, 5), 32, j); j++;
        /* CBE64 */
        num_to_str((buf[1] & 0xF0) >> 4, 4, j); j++;
        /* REQ64 */
		num_to_str(buf[1] & 8, 1, j); j++;
        /* PAR64 */
		num_to_str(buf[1] & 4, 1, j); j++;
        /* ACK64 */
		num_to_str(buf[1] & 2, 1, j); j++;
        /* INTAn */
		num_to_str(buf[1] & 1, 1, j); j++;
	
        /* internal [15:8] = buf[0] 
         * internal [7:0]  = buf[12 
         */ 
        /* ch_state */
        num_to_str((buf[0]>>4) & 0xf, 4, j); j++;
        /* dma_unit_state */
        num_to_str((buf[0]>>1) & 0x7, 3, j); j++;

        /* wbs_ack_o */
	num_to_str(buf[12] & (1<<7), 1, j); j++;
        /* wbs_cyc_i */
	num_to_str(buf[12] & (1<<6), 1, j); j++;
        /* wbs_stb_i */
	num_to_str(buf[12] & (1<<5), 1, j); j++;
        /* wbs_we_i */
	num_to_str(buf[12] & (1<<4), 1, j); j++;
        /* wbm_ack_i */
	num_to_str(buf[12] & (1<<3), 1, j); j++;
        /* wbm_cyc_o */
	num_to_str(buf[12] & (1<<2), 1, j); j++;
        /* wbm_stb_o */
	num_to_str(buf[12] & (1<<1), 1, j); j++;
        /* wbm_we_o */
	num_to_str(buf[12] & (1<<0), 1, j); j++;

	    /* CNT */	
        num_to_str((buf[14]<<8)+ buf[13], 16, j); j++;

		cnt += 1;
		len -= 16;
		buf += 16;
	}

	return 0;
}

#ifdef MAIN
int main(void)
{
    int ret, size = 64 * 1024 * 1024;
    unsigned char *buffer;

    buffer = malloc(size);
    ret = read(0, buffer, size);

    pciacq_init(NULL);
    pciacq_insert(buffer, ret);
}
#endif
