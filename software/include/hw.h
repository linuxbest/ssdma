enum { BIT_0 = 1<<0, 
    BIT_1 = 1<<1, 
    BIT_2 = 1<<2, 
    BIT_3 = 1<<3, 
    BIT_4 = 1<<4, 
    BIT_5 = 1<<5, 
    BIT_6 = 1<<6, 
    BIT_7 = 1<<7 };

#define FPGA_INIT_B  BIT_7 /* PC7/FRn */
#define FPGA_WRn     BIT_6 /* PC6/WRn */
#define FPGA_DONE    BIT_5 /* PC5/T1 */
#define FPGA_PROG_B  BIT_4 /* PC4/T0 */
#define LED_0        BIT_3 /* PC3/INIT1W */
#define FPGA_PROG_M2 BIT_2 /* PC2/INIT0W */
#define FPGA_PROG_M1 BIT_1 /* PC1/TxD0 */
#define FPGA_PROG_M0 BIT_0 /* PC0/RxD0 */

#define FPGA_CCLK    BIT_4 /* PA4/FWRn */
#define FPGA_FRDN    BIT_5 /* PA5/FRDn */

#define FPGA_MSG     BIT_5

#define FPGA_FIFO_RD BIT_1 /* PC1/TxD0 */
#define SPI_SEL      BIT_0 /* PC0/RxD0 */
#define SPI_D        BIT_3 /* D3 */
#define SPI_Q        BIT_0 /* D0 */
