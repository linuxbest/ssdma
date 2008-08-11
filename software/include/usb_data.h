/* host -> usb */
#define LZF_HEVENT_INIT_RSP 0x0
#define LZF_HEVENT_EXIT_RSP 0x1

#define LZF_HEVENT_PORTC_RSP 0x2
#define LZF_HEVENT_WDATA_RSP 0x3
#define LZF_HEVENT_SEND_RSP  0x4

#define LZF_HEVENT_READ_FPGA  0x5
#define LZF_HEVENT_WRITE_FPGA 0x6
#define LZF_HEVENT_EXEC_FPGA  0x7

#define LZF_HEVENT_FIFO_READ  0x8
#define LZF_HEVENT_FIFO_WRITE 0x9

/* usb -> host */
#define LZF_DHEVET_STATUS_REQ 0x10

struct lzf_usb_header {
    unsigned char op;
    unsigned char ver;
    unsigned char status;

    unsigned char portc;
};

/* host -> usb */
struct portc_rsp {
    unsigned char portce;
    unsigned char fwr;
    unsigned char d;
};

struct data_rsp {
    unsigned char dlen;
    unsigned char mode;  /* 0 is serial, 1 parell */
    unsigned char d[8]; /* data */
};

enum { BIT_0 = 0, BIT_1, BIT_2, BIT_3, BIT_4, BIT_5, BIT_6, BIT_7 };

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

#define FPGA_MSG BIT_5
