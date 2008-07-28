/************************************************************************
 *     File Name  : top.v
 *        Version :
 *           Date : 
 *    Description : 
 *   Dependencies :
 *
 *        Company : Beijing Soul Tech.
 *
 *   Copyright (C) 2008 Beijing Soul tech.
 *
 *
 ***********************************************************************/
module top(/*AUTOARG*/
   // Outputs
   LED, FIFO_RD, PCI_SERRn,
   // Inouts
   USB_FWRn, USB_D, SPI_SEL, PCI_AD, PCI_AD64, PCI_CBE,
   PCI_CBE64, PCI_FRAMEn, PCI_IRDYn, PCI_TRDYn, PCI_DEVSELn,
   PCI_STOPn, PCI_LOCKn, PCI_REQn, PCI_RSTn, PCI_INTAn,
   PCI_INTBn, PCI_PERRn, PCI_PAR, PCI_REQ64n, PCI_ACK64n,
   PCI_PAR64,
   // Inputs
   USB_PC7, USB_PC6, USB_FRDn, CLK24, PCI_CLK, PCI_IDSEL,
   PCI_GNTn
   );

   /* PCI */
   inout [31:0] PCI_AD;
   inout [31:0] PCI_AD64;
   inout [3:0] 	PCI_CBE;
   inout [3:0] 	PCI_CBE64;
   input        PCI_CLK;
   input        PCI_IDSEL;
   inout        PCI_FRAMEn;
   inout        PCI_IRDYn;
   inout        PCI_TRDYn;
   inout        PCI_DEVSELn;
   inout        PCI_STOPn;
   inout        PCI_LOCKn;
   input        PCI_GNTn;
   inout        PCI_REQn;
   inout        PCI_RSTn;
   inout        PCI_INTAn;
   inout        PCI_INTBn;
   inout        PCI_PERRn;
   output       PCI_SERRn;
   inout        PCI_PAR;
   inout        PCI_REQ64n;
   inout        PCI_ACK64n;
   inout        PCI_PAR64;

   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		CLK24;			// To usb of spi_usb.v
   input		USB_FRDn;		// To usb of spi_usb.v
   input		USB_PC6;		// To usb of spi_usb.v
   input		USB_PC7;		// To usb of spi_usb.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output		FIFO_RD;		// From usb of spi_usb.v
   output		LED;			// From usb of spi_usb.v
   // End of automatics
   /*AUTOINOUT*/
   // Beginning of automatic inouts (from unused autoinst inouts)
   inout		SPI_SEL;		// To/From usb of spi_usb.v
   inout [7:0]		USB_D;			// To/From usb of spi_usb.v
   inout		USB_FWRn;		// To/From usb of spi_usb.v
   // End of automatics

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			spi_clk_i;		// From usb of spi_usb.v
   wire			spi_clk_o;		// From adma of ss_adma.v
   wire			spi_di_en;		// From adma of ss_adma.v
   wire			spi_di_i;		// From usb of spi_usb.v
   wire			spi_di_o;		// From adma of ss_adma.v
   wire			spi_do_en;		// From adma of ss_adma.v
   wire			spi_do_i;		// From usb of spi_usb.v
   wire			spi_do_o;		// From adma of ss_adma.v
   wire			spi_en;			// From adma of ss_adma.v
   wire			spi_sel_i;		// From usb of spi_usb.v
   wire			spi_sel_o;		// From adma of ss_adma.v
   wire			wb_clk_i;		// From bridge of bridge.v
   wire			wb_int_o;		// From adma of ss_adma.v
   wire			wb_rst_i;		// From bridge of bridge.v
   wire			wbm_ack_i;		// From bridge of bridge.v
   wire [31:0]		wbm_adr_o;		// From adma of ss_adma.v
   wire			wbm_cab_o;		// From adma of ss_adma.v
   wire			wbm_cyc_o;		// From adma of ss_adma.v
   wire [31:0]		wbm_dat64_i;		// From bridge of bridge.v
   wire [31:0]		wbm_dat64_o;		// From adma of ss_adma.v
   wire [31:0]		wbm_dat_i;		// From bridge of bridge.v
   wire [31:0]		wbm_dat_o;		// From adma of ss_adma.v
   wire			wbm_err_i;		// From bridge of bridge.v
   wire			wbm_pref_o;		// From adma of ss_adma.v
   wire			wbm_rty_i;		// From bridge of bridge.v
   wire [3:0]		wbm_sel_o;		// From adma of ss_adma.v
   wire			wbm_stb_o;		// From adma of ss_adma.v
   wire			wbm_we_o;		// From adma of ss_adma.v
   wire			wbs_ack_o;		// From adma of ss_adma.v
   wire [31:0]		wbs_adr_i;		// From bridge of bridge.v
   wire			wbs_cab_i;		// From bridge of bridge.v
   wire			wbs_cyc_i;		// From bridge of bridge.v
   wire [31:0]		wbs_dat_i;		// From bridge of bridge.v
   wire [31:0]		wbs_dat_o;		// From adma of ss_adma.v
   wire			wbs_err_o;		// From adma of ss_adma.v
   wire			wbs_rty_o;		// From adma of ss_adma.v
   wire [3:0]		wbs_sel_i;		// From bridge of bridge.v
   wire			wbs_stb_i;		// From bridge of bridge.v
   wire			wbs_we_i;		// From bridge of bridge.v
   // End of automatics
   
   spi_usb usb(/*AUTOINST*/
	       // Outputs
	       .LED			(LED),
	       .FIFO_RD			(FIFO_RD),
	       .spi_clk_i		(spi_clk_i),
	       .spi_sel_i		(spi_sel_i),
	       .spi_do_i		(spi_do_i),
	       .spi_di_i		(spi_di_i),
	       // Inouts
	       .USB_D			(USB_D[7:0]),
	       .USB_FWRn		(USB_FWRn),
	       .SPI_SEL			(SPI_SEL),
	       // Inputs
	       .CLK24			(CLK24),
	       .USB_FRDn		(USB_FRDn),
	       .USB_PC6			(USB_PC6),
	       .USB_PC7			(USB_PC7),
	       .spi_en			(spi_en),
	       .spi_clk_o		(spi_clk_o),
	       .spi_sel_o		(spi_sel_o),
	       .spi_do_en		(spi_do_en),
	       .spi_do_o		(spi_do_o),
	       .spi_di_en		(spi_di_en),
	       .spi_di_o		(spi_di_o));

   ss_adma adma(/*AUTOINST*/
		// Outputs
		.spi_clk_o		(spi_clk_o),
		.spi_di_en		(spi_di_en),
		.spi_di_o		(spi_di_o),
		.spi_do_en		(spi_do_en),
		.spi_do_o		(spi_do_o),
		.spi_en			(spi_en),
		.spi_sel_o		(spi_sel_o),
		.wbm_adr_o		(wbm_adr_o[31:0]),
		.wbm_cab_o		(wbm_cab_o),
		.wbm_cyc_o		(wbm_cyc_o),
		.wbm_dat64_o		(wbm_dat64_o[31:0]),
		.wbm_dat_o		(wbm_dat_o[31:0]),
		.wbm_pref_o		(wbm_pref_o),
		.wbm_sel_o		(wbm_sel_o[3:0]),
		.wbm_stb_o		(wbm_stb_o),
		.wbm_we_o		(wbm_we_o),
		.wbs_ack_o		(wbs_ack_o),
		.wbs_dat_o		(wbs_dat_o[31:0]),
		.wbs_err_o		(wbs_err_o),
		.wbs_rty_o		(wbs_rty_o),
		.wb_int_o		(wb_int_o),
		// Inputs
		.spi_clk_i		(spi_clk_i),
		.spi_di_i		(spi_di_i),
		.spi_do_i		(spi_do_i),
		.spi_sel_i		(spi_sel_i),
		.wb_clk_i		(wb_clk_i),
		.wb_rst_i		(wb_rst_i),
		.wbm_ack_i		(wbm_ack_i),
		.wbm_dat64_i		(wbm_dat64_i[31:0]),
		.wbm_dat_i		(wbm_dat_i[31:0]),
		.wbm_err_i		(wbm_err_i),
		.wbm_rty_i		(wbm_rty_i),
		.wbs_adr_i		(wbs_adr_i[31:0]),
		.wbs_cab_i		(wbs_cab_i),
		.wbs_cyc_i		(wbs_cyc_i),
		.wbs_dat_i		(wbs_dat_i[31:0]),
		.wbs_sel_i		(wbs_sel_i[3:0]),
		.wbs_stb_i		(wbs_stb_i),
		.wbs_we_i		(wbs_we_i));

   bridge bridge(/*AUTOINST*/
		 // Outputs
		 .PCI_SERRn		(PCI_SERRn),
		 .wbs_dat_i		(wbs_dat_i[31:0]),
		 .wbs_adr_i		(wbs_adr_i[31:0]),
		 .wbs_sel_i		(wbs_sel_i[3:0]),
		 .wbs_we_i		(wbs_we_i),
		 .wbs_stb_i		(wbs_stb_i),
		 .wbs_cyc_i		(wbs_cyc_i),
		 .wbs_cab_i		(wbs_cab_i),
		 .wb_rst_i		(wb_rst_i),
		 .wb_clk_i		(wb_clk_i),
		 .wbm_rty_i		(wbm_rty_i),
		 .wbm_err_i		(wbm_err_i),
		 .wbm_ack_i		(wbm_ack_i),
		 .wbm_dat_i		(wbm_dat_i[31:0]),
		 .wbm_dat64_i		(wbm_dat64_i[31:0]),
		 // Inouts
		 .PCI_AD		(PCI_AD[31:0]),
		 .PCI_AD64		(PCI_AD64[31:0]),
		 .PCI_CBE		(PCI_CBE[3:0]),
		 .PCI_CBE64		(PCI_CBE64[3:0]),
		 .PCI_FRAMEn		(PCI_FRAMEn),
		 .PCI_IRDYn		(PCI_IRDYn),
		 .PCI_TRDYn		(PCI_TRDYn),
		 .PCI_DEVSELn		(PCI_DEVSELn),
		 .PCI_STOPn		(PCI_STOPn),
		 .PCI_LOCKn		(PCI_LOCKn),
		 .PCI_REQn		(PCI_REQn),
		 .PCI_RSTn		(PCI_RSTn),
		 .PCI_INTAn		(PCI_INTAn),
		 .PCI_INTBn		(PCI_INTBn),
		 .PCI_PERRn		(PCI_PERRn),
		 .PCI_PAR		(PCI_PAR),
		 .PCI_REQ64n		(PCI_REQ64n),
		 .PCI_ACK64n		(PCI_ACK64n),
		 .PCI_PAR64		(PCI_PAR64),
		 // Inputs
		 .PCI_CLK		(PCI_CLK),
		 .PCI_IDSEL		(PCI_IDSEL),
		 .PCI_GNTn		(PCI_GNTn),
		 .wbs_rty_o		(wbs_rty_o),
		 .wbs_err_o		(wbs_err_o),
		 .wbs_ack_o		(wbs_ack_o),
		 .wbs_dat_o		(wbs_dat_o[31:0]),
		 .wb_int_o		(wb_int_o),
		 .wbm_we_o		(wbm_we_o),
		 .wbm_stb_o		(wbm_stb_o),
		 .wbm_cyc_o		(wbm_cyc_o),
		 .wbm_cab_o		(wbm_cab_o),
		 .wbm_pref_o		(wbm_pref_o),
		 .wbm_sel_o		(wbm_sel_o[3:0]),
		 .wbm_dat_o		(wbm_dat_o[31:0]),
		 .wbm_dat64_o		(wbm_dat64_o[31:0]),
		 .wbm_adr_o		(wbm_adr_o[31:0]));
   
endmodule // top
