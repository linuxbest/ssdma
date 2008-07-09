/************************************************************************
 *     File Name  : ss_adma.v
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

module ss_adma(/*AUTOARG*/
   // Outputs
   wbs_rty_o, wbs_err_o, wbs_dat_o, wbs_ack_o, wbm_we_o,
   wbm_stb_o, wbm_sel_o, wbm_dat_o, wbm_dat64_o, wbm_cyc_o,
   wbm_cab_o, wbm_adr_o, wb_int_o, spi_sel_o, spi_en,
   spi_do_o, spi_do_en, spi_di_o, spi_di_en, spi_clk_o,
   // Inputs
   wbs_we_i, wbs_stb_i, wbs_sel_i, wbs_dat_i, wbs_cyc_i,
   wbs_cab_i, wbs_adr_i, wbm_rty_i, wbm_err_i, wbm_dat_i,
   wbm_dat64_i, wbm_ack_i, wb_rst_i, wb_clk_i, spi_sel_i,
   spi_do_i, spi_di_i, spi_clk_i
   );
   /*parameter*/
   
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output		spi_clk_o;		// From wbm of wbm.v
   output		spi_di_en;		// From wbm of wbm.v
   output		spi_di_o;		// From wbm of wbm.v
   output		spi_do_en;		// From wbm of wbm.v
   output		spi_do_o;		// From wbm of wbm.v
   output		spi_en;			// From wbm of wbm.v
   output		spi_sel_o;		// From wbm of wbm.v
   output		wb_int_o;		// From d_4 of dummy.v
   output [31:0]	wbm_adr_o;		// From m0 of mixer.v
   output		wbm_cab_o;		// From m0 of mixer.v
   output		wbm_cyc_o;		// From m0 of mixer.v
   output [31:0]	wbm_dat64_o;		// From m0 of mixer.v
   output [31:0]	wbm_dat_o;		// From m0 of mixer.v
   output [3:0]		wbm_sel_o;		// From m0 of mixer.v
   output		wbm_stb_o;		// From m0 of mixer.v
   output		wbm_we_o;		// From m0 of mixer.v
   output		wbs_ack_o;		// From wbm of wbm.v
   output [31:0]	wbs_dat_o;		// From wbm of wbm.v
   output		wbs_err_o;		// From wbm of wbm.v
   output		wbs_rty_o;		// From wbm of wbm.v
   // End of automatics
   
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		spi_clk_i;		// To wbm of wbm.v
   input		spi_di_i;		// To wbm of wbm.v
   input		spi_do_i;		// To wbm of wbm.v
   input		spi_sel_i;		// To wbm of wbm.v
   input		wb_clk_i;		// To r_0 of ss_sg.v, ...
   input		wb_rst_i;		// To r_0 of ss_sg.v, ...
   input		wbm_ack_i;		// To m0 of mixer.v
   input [31:0]		wbm_dat64_i;		// To m0 of mixer.v
   input [31:0]		wbm_dat_i;		// To m0 of mixer.v
   input		wbm_err_i;		// To m0 of mixer.v
   input		wbm_rty_i;		// To m0 of mixer.v
   input [31:0]		wbs_adr_i;		// To wbm of wbm.v
   input		wbs_cab_i;		// To wbm of wbm.v
   input		wbs_cyc_i;		// To wbm of wbm.v
   input [31:0]		wbs_dat_i;		// To wbm of wbm.v
   input [3:0]		wbs_sel_i;		// To wbm of wbm.v
   input		wbs_stb_i;		// To wbm of wbm.v
   input		wbs_we_i;		// To wbm of wbm.v
   // End of automatics

   /*AUTOINOUT*/
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [4:0]		gnt;			// From arbiter of arbiter.v
   wire [31:3]		sg_addr0;		// From r_0 of ss_sg.v
   wire [31:3]		sg_addr1;		// From r_1 of ss_sg.v
   wire [31:3]		sg_addr2;		// From r_2 of ss_sg.v
   wire [31:3]		sg_addr3;		// From r_3 of ss_sg.v
   wire [15:0]		sg_desc0;		// From r_0 of ss_sg.v
   wire [15:0]		sg_desc1;		// From r_1 of ss_sg.v
   wire [15:0]		sg_desc2;		// From r_2 of ss_sg.v
   wire [15:0]		sg_desc3;		// From r_3 of ss_sg.v
   wire [31:3]		sg_next0;		// From r_0 of ss_sg.v
   wire [31:3]		sg_next1;		// From r_1 of ss_sg.v
   wire [31:3]		sg_next2;		// From r_2 of ss_sg.v
   wire [31:3]		sg_next3;		// From r_3 of ss_sg.v
   wire [7:0]		sg_state0;		// From r_0 of ss_sg.v
   wire [7:0]		sg_state1;		// From r_1 of ss_sg.v
   wire [7:0]		sg_state2;		// From r_2 of ss_sg.v
   wire [7:0]		sg_state3;		// From r_3 of ss_sg.v
   wire [1:0]		ss_adr0;		// From d_4 of dummy.v
   wire [1:0]		ss_adr1;		// From d_4 of dummy.v
   wire [1:0]		ss_adr2;		// From d_4 of dummy.v
   wire [1:0]		ss_adr3;		// From d_4 of dummy.v
   wire [31:0]		ss_dat0;		// From d_4 of dummy.v
   wire [31:0]		ss_dat1;		// From d_4 of dummy.v
   wire [31:0]		ss_dat2;		// From d_4 of dummy.v
   wire [31:0]		ss_dat3;		// From d_4 of dummy.v
   wire			ss_done0;		// From d_4 of dummy.v
   wire			ss_done1;		// From d_4 of dummy.v
   wire			ss_done2;		// From d_4 of dummy.v
   wire			ss_done3;		// From d_4 of dummy.v
   wire			ss_ready0;		// From d_4 of dummy.v
   wire			ss_ready1;		// From d_4 of dummy.v
   wire			ss_ready2;		// From d_4 of dummy.v
   wire			ss_ready3;		// From d_4 of dummy.v
   wire			ss_we0;			// From d_4 of dummy.v
   wire			ss_we1;			// From d_4 of dummy.v
   wire			ss_we2;			// From d_4 of dummy.v
   wire			ss_we3;			// From d_4 of dummy.v
   wire			ss_xfer0;		// From r_0 of ss_sg.v
   wire			ss_xfer1;		// From r_1 of ss_sg.v
   wire			ss_xfer2;		// From r_2 of ss_sg.v
   wire			ss_xfer3;		// From r_3 of ss_sg.v
   wire			wbs_ack0;		// From m0 of mixer.v
   wire			wbs_ack1;		// From m0 of mixer.v
   wire			wbs_ack2;		// From m0 of mixer.v
   wire			wbs_ack3;		// From m0 of mixer.v
   wire			wbs_ack4;		// From m0 of mixer.v
   wire [31:0]		wbs_adr0;		// From r_0 of ss_sg.v
   wire [31:0]		wbs_adr1;		// From r_1 of ss_sg.v
   wire [31:0]		wbs_adr2;		// From r_2 of ss_sg.v
   wire [31:0]		wbs_adr3;		// From r_3 of ss_sg.v
   wire [31:0]		wbs_adr4;		// From d_4 of dummy.v
   wire			wbs_cab0;		// From r_0 of ss_sg.v
   wire			wbs_cab1;		// From r_1 of ss_sg.v
   wire			wbs_cab2;		// From r_2 of ss_sg.v
   wire			wbs_cab3;		// From r_3 of ss_sg.v
   wire			wbs_cab4;		// From d_4 of dummy.v
   wire			wbs_cyc0;		// From r_0 of ss_sg.v
   wire			wbs_cyc1;		// From r_1 of ss_sg.v
   wire			wbs_cyc2;		// From r_2 of ss_sg.v
   wire			wbs_cyc3;		// From r_3 of ss_sg.v
   wire			wbs_cyc4;		// From d_4 of dummy.v
   wire [31:0]		wbs_dat64_i0;		// From d_4 of dummy.v
   wire [31:0]		wbs_dat64_i1;		// From d_4 of dummy.v
   wire [31:0]		wbs_dat64_i2;		// From d_4 of dummy.v
   wire [31:0]		wbs_dat64_i3;		// From d_4 of dummy.v
   wire [31:0]		wbs_dat64_i4;		// From d_4 of dummy.v
   wire [31:0]		wbs_dat64_o0;		// From m0 of mixer.v
   wire [31:0]		wbs_dat64_o1;		// From m0 of mixer.v
   wire [31:0]		wbs_dat64_o2;		// From m0 of mixer.v
   wire [31:0]		wbs_dat64_o3;		// From m0 of mixer.v
   wire [31:0]		wbs_dat64_o4;		// From m0 of mixer.v
   wire [31:0]		wbs_dat_i0;		// From d_4 of dummy.v
   wire [31:0]		wbs_dat_i1;		// From d_4 of dummy.v
   wire [31:0]		wbs_dat_i2;		// From d_4 of dummy.v
   wire [31:0]		wbs_dat_i3;		// From d_4 of dummy.v
   wire [31:0]		wbs_dat_i4;		// From d_4 of dummy.v
   wire [31:0]		wbs_dat_o0;		// From m0 of mixer.v
   wire [31:0]		wbs_dat_o1;		// From m0 of mixer.v
   wire [31:0]		wbs_dat_o2;		// From m0 of mixer.v
   wire [31:0]		wbs_dat_o3;		// From m0 of mixer.v
   wire [31:0]		wbs_dat_o4;		// From m0 of mixer.v
   wire			wbs_err0;		// From m0 of mixer.v
   wire			wbs_err1;		// From m0 of mixer.v
   wire			wbs_err2;		// From m0 of mixer.v
   wire			wbs_err3;		// From m0 of mixer.v
   wire			wbs_err4;		// From m0 of mixer.v
   wire			wbs_rty0;		// From m0 of mixer.v
   wire			wbs_rty1;		// From m0 of mixer.v
   wire			wbs_rty2;		// From m0 of mixer.v
   wire			wbs_rty3;		// From m0 of mixer.v
   wire			wbs_rty4;		// From m0 of mixer.v
   wire [3:0]		wbs_sel0;		// From r_0 of ss_sg.v
   wire [3:0]		wbs_sel1;		// From r_1 of ss_sg.v
   wire [3:0]		wbs_sel2;		// From r_2 of ss_sg.v
   wire [3:0]		wbs_sel3;		// From r_3 of ss_sg.v
   wire [3:0]		wbs_sel4;		// From d_4 of dummy.v
   wire			wbs_stb0;		// From r_0 of ss_sg.v
   wire			wbs_stb1;		// From r_1 of ss_sg.v
   wire			wbs_stb2;		// From r_2 of ss_sg.v
   wire			wbs_stb3;		// From r_3 of ss_sg.v
   wire			wbs_stb4;		// From d_4 of dummy.v
   wire			wbs_we0;		// From r_0 of ss_sg.v
   wire			wbs_we1;		// From r_1 of ss_sg.v
   wire			wbs_we2;		// From r_2 of ss_sg.v
   wire			wbs_we3;		// From r_3 of ss_sg.v
   wire			wbs_we4;		// From d_4 of dummy.v
   // End of automatics
   
   /* ss_sg AUTO_TEMPLATE "_\([0-9]+\)" (
    .wb_clk_i(wb_clk_i),
    .wb_rst_i(wb_rst_i),
    .\(.*\)(\1@[]),
    );
    */
   ss_sg r_0(/*AUTOINST*/
	     // Outputs
	     .wbs_cyc			(wbs_cyc0),		 // Templated
	     .wbs_stb			(wbs_stb0),		 // Templated
	     .wbs_we			(wbs_we0),		 // Templated
	     .wbs_cab			(wbs_cab0),		 // Templated
	     .wbs_sel			(wbs_sel0[3:0]),	 // Templated
	     .wbs_adr			(wbs_adr0[31:0]),	 // Templated
	     .sg_state			(sg_state0[7:0]),	 // Templated
	     .sg_desc			(sg_desc0[15:0]),	 // Templated
	     .sg_addr			(sg_addr0[31:3]),	 // Templated
	     .sg_next			(sg_next0[31:3]),	 // Templated
	     .ss_xfer			(ss_xfer0),		 // Templated
	     // Inputs
	     .wb_clk_i			(wb_clk_i),		 // Templated
	     .wb_rst_i			(wb_rst_i),		 // Templated
	     .wbs_dat_o			(wbs_dat_o0[31:0]),	 // Templated
	     .wbs_dat64_o		(wbs_dat64_o0[31:0]),	 // Templated
	     .wbs_ack			(wbs_ack0),		 // Templated
	     .wbs_err			(wbs_err0),		 // Templated
	     .wbs_rty			(wbs_rty0),		 // Templated
	     .ss_dat			(ss_dat0[31:0]),	 // Templated
	     .ss_we			(ss_we0),		 // Templated
	     .ss_adr			(ss_adr0[1:0]),		 // Templated
	     .ss_done			(ss_done0),		 // Templated
	     .ss_ready			(ss_ready0));		 // Templated

   ss_sg r_1 (/*AUTOINST*/
	      // Outputs
	      .wbs_cyc			(wbs_cyc1),		 // Templated
	      .wbs_stb			(wbs_stb1),		 // Templated
	      .wbs_we			(wbs_we1),		 // Templated
	      .wbs_cab			(wbs_cab1),		 // Templated
	      .wbs_sel			(wbs_sel1[3:0]),	 // Templated
	      .wbs_adr			(wbs_adr1[31:0]),	 // Templated
	      .sg_state			(sg_state1[7:0]),	 // Templated
	      .sg_desc			(sg_desc1[15:0]),	 // Templated
	      .sg_addr			(sg_addr1[31:3]),	 // Templated
	      .sg_next			(sg_next1[31:3]),	 // Templated
	      .ss_xfer			(ss_xfer1),		 // Templated
	      // Inputs
	      .wb_clk_i			(wb_clk_i),		 // Templated
	      .wb_rst_i			(wb_rst_i),		 // Templated
	      .wbs_dat_o		(wbs_dat_o1[31:0]),	 // Templated
	      .wbs_dat64_o		(wbs_dat64_o1[31:0]),	 // Templated
	      .wbs_ack			(wbs_ack1),		 // Templated
	      .wbs_err			(wbs_err1),		 // Templated
	      .wbs_rty			(wbs_rty1),		 // Templated
	      .ss_dat			(ss_dat1[31:0]),	 // Templated
	      .ss_we			(ss_we1),		 // Templated
	      .ss_adr			(ss_adr1[1:0]),		 // Templated
	      .ss_done			(ss_done1),		 // Templated
	      .ss_ready			(ss_ready1));		 // Templated

   ss_sg r_2 (/*AUTOINST*/
	      // Outputs
	      .wbs_cyc			(wbs_cyc2),		 // Templated
	      .wbs_stb			(wbs_stb2),		 // Templated
	      .wbs_we			(wbs_we2),		 // Templated
	      .wbs_cab			(wbs_cab2),		 // Templated
	      .wbs_sel			(wbs_sel2[3:0]),	 // Templated
	      .wbs_adr			(wbs_adr2[31:0]),	 // Templated
	      .sg_state			(sg_state2[7:0]),	 // Templated
	      .sg_desc			(sg_desc2[15:0]),	 // Templated
	      .sg_addr			(sg_addr2[31:3]),	 // Templated
	      .sg_next			(sg_next2[31:3]),	 // Templated
	      .ss_xfer			(ss_xfer2),		 // Templated
	      // Inputs
	      .wb_clk_i			(wb_clk_i),		 // Templated
	      .wb_rst_i			(wb_rst_i),		 // Templated
	      .wbs_dat_o		(wbs_dat_o2[31:0]),	 // Templated
	      .wbs_dat64_o		(wbs_dat64_o2[31:0]),	 // Templated
	      .wbs_ack			(wbs_ack2),		 // Templated
	      .wbs_err			(wbs_err2),		 // Templated
	      .wbs_rty			(wbs_rty2),		 // Templated
	      .ss_dat			(ss_dat2[31:0]),	 // Templated
	      .ss_we			(ss_we2),		 // Templated
	      .ss_adr			(ss_adr2[1:0]),		 // Templated
	      .ss_done			(ss_done2),		 // Templated
	      .ss_ready			(ss_ready2));		 // Templated

   ss_sg r_3 (/*AUTOINST*/
	      // Outputs
	      .wbs_cyc			(wbs_cyc3),		 // Templated
	      .wbs_stb			(wbs_stb3),		 // Templated
	      .wbs_we			(wbs_we3),		 // Templated
	      .wbs_cab			(wbs_cab3),		 // Templated
	      .wbs_sel			(wbs_sel3[3:0]),	 // Templated
	      .wbs_adr			(wbs_adr3[31:0]),	 // Templated
	      .sg_state			(sg_state3[7:0]),	 // Templated
	      .sg_desc			(sg_desc3[15:0]),	 // Templated
	      .sg_addr			(sg_addr3[31:3]),	 // Templated
	      .sg_next			(sg_next3[31:3]),	 // Templated
	      .ss_xfer			(ss_xfer3),		 // Templated
	      // Inputs
	      .wb_clk_i			(wb_clk_i),		 // Templated
	      .wb_rst_i			(wb_rst_i),		 // Templated
	      .wbs_dat_o		(wbs_dat_o3[31:0]),	 // Templated
	      .wbs_dat64_o		(wbs_dat64_o3[31:0]),	 // Templated
	      .wbs_ack			(wbs_ack3),		 // Templated
	      .wbs_err			(wbs_err3),		 // Templated
	      .wbs_rty			(wbs_rty3),		 // Templated
	      .ss_dat			(ss_dat3[31:0]),	 // Templated
	      .ss_we			(ss_we3),		 // Templated
	      .ss_adr			(ss_adr3[1:0]),		 // Templated
	      .ss_done			(ss_done3),		 // Templated
	      .ss_ready			(ss_ready3));		 // Templated
   
   defparam 	 r_0.RW = 0;
   defparam 	 r_1.RW = 1;
   defparam 	 r_2.RW = 0;
   defparam 	 r_3.RW = 1;
   
   mixer m0 (/*AUTOINST*/
	     // Outputs
	     .wbs_dat_o0		(wbs_dat_o0[31:0]),
	     .wbs_dat64_o0		(wbs_dat64_o0[31:0]),
	     .wbs_ack0			(wbs_ack0),
	     .wbs_err0			(wbs_err0),
	     .wbs_rty0			(wbs_rty0),
	     .wbs_dat_o1		(wbs_dat_o1[31:0]),
	     .wbs_dat64_o1		(wbs_dat64_o1[31:0]),
	     .wbs_ack1			(wbs_ack1),
	     .wbs_err1			(wbs_err1),
	     .wbs_rty1			(wbs_rty1),
	     .wbs_dat_o2		(wbs_dat_o2[31:0]),
	     .wbs_dat64_o2		(wbs_dat64_o2[31:0]),
	     .wbs_ack2			(wbs_ack2),
	     .wbs_err2			(wbs_err2),
	     .wbs_rty2			(wbs_rty2),
	     .wbs_dat_o3		(wbs_dat_o3[31:0]),
	     .wbs_dat64_o3		(wbs_dat64_o3[31:0]),
	     .wbs_ack3			(wbs_ack3),
	     .wbs_err3			(wbs_err3),
	     .wbs_rty3			(wbs_rty3),
	     .wbs_dat_o4		(wbs_dat_o4[31:0]),
	     .wbs_dat64_o4		(wbs_dat64_o4[31:0]),
	     .wbs_ack4			(wbs_ack4),
	     .wbs_err4			(wbs_err4),
	     .wbs_rty4			(wbs_rty4),
	     .wbm_cyc_o			(wbm_cyc_o),
	     .wbm_stb_o			(wbm_stb_o),
	     .wbm_we_o			(wbm_we_o),
	     .wbm_cab_o			(wbm_cab_o),
	     .wbm_sel_o			(wbm_sel_o[3:0]),
	     .wbm_adr_o			(wbm_adr_o[31:0]),
	     .wbm_dat_o			(wbm_dat_o[31:0]),
	     .wbm_dat64_o		(wbm_dat64_o[31:0]),
	     // Inputs
	     .wb_clk_i			(wb_clk_i),
	     .wb_rst_i			(wb_rst_i),
	     .wbs_cyc0			(wbs_cyc0),
	     .wbs_stb0			(wbs_stb0),
	     .wbs_we0			(wbs_we0),
	     .wbs_cab0			(wbs_cab0),
	     .wbs_sel0			(wbs_sel0[3:0]),
	     .wbs_adr0			(wbs_adr0[31:0]),
	     .wbs_dat_i0		(wbs_dat_i0[31:0]),
	     .wbs_dat64_i0		(wbs_dat64_i0[31:0]),
	     .wbs_cyc1			(wbs_cyc1),
	     .wbs_stb1			(wbs_stb1),
	     .wbs_we1			(wbs_we1),
	     .wbs_cab1			(wbs_cab1),
	     .wbs_sel1			(wbs_sel1[3:0]),
	     .wbs_adr1			(wbs_adr1[31:0]),
	     .wbs_dat_i1		(wbs_dat_i1[31:0]),
	     .wbs_dat64_i1		(wbs_dat64_i1[31:0]),
	     .wbs_cyc2			(wbs_cyc2),
	     .wbs_stb2			(wbs_stb2),
	     .wbs_we2			(wbs_we2),
	     .wbs_cab2			(wbs_cab2),
	     .wbs_sel2			(wbs_sel2[3:0]),
	     .wbs_adr2			(wbs_adr2[31:0]),
	     .wbs_dat_i2		(wbs_dat_i2[31:0]),
	     .wbs_dat64_i2		(wbs_dat64_i2[31:0]),
	     .wbs_cyc3			(wbs_cyc3),
	     .wbs_stb3			(wbs_stb3),
	     .wbs_we3			(wbs_we3),
	     .wbs_cab3			(wbs_cab3),
	     .wbs_sel3			(wbs_sel3[3:0]),
	     .wbs_adr3			(wbs_adr3[31:0]),
	     .wbs_dat_i3		(wbs_dat_i3[31:0]),
	     .wbs_dat64_i3		(wbs_dat64_i3[31:0]),
	     .wbs_cyc4			(wbs_cyc4),
	     .wbs_stb4			(wbs_stb4),
	     .wbs_we4			(wbs_we4),
	     .wbs_cab4			(wbs_cab4),
	     .wbs_sel4			(wbs_sel4[3:0]),
	     .wbs_adr4			(wbs_adr4[31:0]),
	     .wbs_dat_i4		(wbs_dat_i4[31:0]),
	     .wbs_dat64_i4		(wbs_dat64_i4[31:0]),
	     .gnt			(gnt[4:0]),
	     .wbm_ack_i			(wbm_ack_i),
	     .wbm_err_i			(wbm_err_i),
	     .wbm_rty_i			(wbm_rty_i),
	     .wbm_dat_i			(wbm_dat_i[31:0]),
	     .wbm_dat64_i		(wbm_dat64_i[31:0]));

   dummy d_4(/*AUTOINST*/
	     // Outputs
	     .wbs_cyc4			(wbs_cyc4),
	     .wbs_stb4			(wbs_stb4),
	     .wbs_we4			(wbs_we4),
	     .wbs_cab4			(wbs_cab4),
	     .wbs_sel4			(wbs_sel4[3:0]),
	     .wbs_adr4			(wbs_adr4[31:0]),
	     .wbs_dat_i4		(wbs_dat_i4[31:0]),
	     .wbs_dat64_i4		(wbs_dat64_i4[31:0]),
	     .ss_we0			(ss_we0),
	     .ss_we1			(ss_we1),
	     .ss_we2			(ss_we2),
	     .ss_we3			(ss_we3),
	     .ss_done0			(ss_done0),
	     .ss_done1			(ss_done1),
	     .ss_done2			(ss_done2),
	     .ss_done3			(ss_done3),
	     .ss_dat0			(ss_dat0[31:0]),
	     .ss_dat1			(ss_dat1[31:0]),
	     .ss_dat2			(ss_dat2[31:0]),
	     .ss_dat3			(ss_dat3[31:0]),
	     .ss_adr0			(ss_adr0[1:0]),
	     .ss_adr1			(ss_adr1[1:0]),
	     .ss_adr2			(ss_adr2[1:0]),
	     .ss_adr3			(ss_adr3[1:0]),
	     .ss_ready0			(ss_ready0),
	     .ss_ready1			(ss_ready1),
	     .ss_ready2			(ss_ready2),
	     .ss_ready3			(ss_ready3),
	     .wbs_dat_i0		(wbs_dat_i0[31:0]),
	     .wbs_dat_i1		(wbs_dat_i1[31:0]),
	     .wbs_dat_i2		(wbs_dat_i2[31:0]),
	     .wbs_dat_i3		(wbs_dat_i3[31:0]),
	     .wbs_dat64_i0		(wbs_dat64_i0[31:0]),
	     .wbs_dat64_i1		(wbs_dat64_i1[31:0]),
	     .wbs_dat64_i2		(wbs_dat64_i2[31:0]),
	     .wbs_dat64_i3		(wbs_dat64_i3[31:0]),
	     .wb_int_o			(wb_int_o),
	     // Inputs
	     .wb_clk_i			(wb_clk_i),
	     .wb_rst_i			(wb_rst_i),
	     .wbs_dat_o4		(wbs_dat_o4[31:0]),
	     .wbs_dat64_o4		(wbs_dat64_o4[31:0]),
	     .wbs_ack4			(wbs_ack4),
	     .wbs_err4			(wbs_err4),
	     .wbs_rty4			(wbs_rty4),
	     .sg_state0			(sg_state0[7:0]),
	     .sg_state1			(sg_state1[7:0]),
	     .sg_state2			(sg_state2[7:0]),
	     .sg_state3			(sg_state3[7:0]),
	     .sg_desc0			(sg_desc0[15:0]),
	     .sg_desc1			(sg_desc1[15:0]),
	     .sg_desc2			(sg_desc2[15:0]),
	     .sg_desc3			(sg_desc3[15:0]),
	     .sg_addr0			(sg_addr0[31:3]),
	     .sg_addr1			(sg_addr1[31:3]),
	     .sg_addr2			(sg_addr2[31:3]),
	     .sg_addr3			(sg_addr3[31:3]),
	     .sg_next0			(sg_next0[31:3]),
	     .sg_next1			(sg_next1[31:3]),
	     .sg_next2			(sg_next2[31:3]),
	     .sg_next3			(sg_next3[31:3]),
	     .ss_xfer0			(ss_xfer0),
	     .ss_xfer1			(ss_xfer1),
	     .ss_xfer2			(ss_xfer2),
	     .ss_xfer3			(ss_xfer3));

   /* gnt */
   arbiter arbiter(/*AUTOINST*/
		   // Outputs
		   .gnt			(gnt[4:0]),
		   // Inputs
		   .wb_clk_i		(wb_clk_i),
		   .wb_rst_i		(wb_rst_i),
		   .wbs_cyc0		(wbs_cyc0),
		   .wbs_cyc1		(wbs_cyc1),
		   .wbs_cyc2		(wbs_cyc2),
		   .wbs_cyc3		(wbs_cyc3),
		   .wbs_cyc4		(wbs_cyc4));

   wbm wbm(/*AUTOINST*/
	   // Outputs
	   .wbs_dat_o			(wbs_dat_o[31:0]),
	   .wbs_ack_o			(wbs_ack_o),
	   .wbs_err_o			(wbs_err_o),
	   .wbs_rty_o			(wbs_rty_o),
	   .spi_sel_o			(spi_sel_o),
	   .spi_di_o			(spi_di_o),
	   .spi_do_o			(spi_do_o),
	   .spi_clk_o			(spi_clk_o),
	   .spi_en			(spi_en),
	   .spi_do_en			(spi_do_en),
	   .spi_di_en			(spi_di_en),
	   // Inputs
	   .wb_clk_i			(wb_clk_i),
	   .wb_rst_i			(wb_rst_i),
	   .sg_state0			(sg_state0[7:0]),
	   .sg_state1			(sg_state1[7:0]),
	   .sg_state2			(sg_state2[7:0]),
	   .sg_state3			(sg_state3[7:0]),
	   .sg_desc0			(sg_desc0[15:0]),
	   .sg_desc1			(sg_desc1[15:0]),
	   .sg_desc2			(sg_desc2[15:0]),
	   .sg_desc3			(sg_desc3[15:0]),
	   .sg_addr0			(sg_addr0[31:3]),
	   .sg_addr1			(sg_addr1[31:3]),
	   .sg_addr2			(sg_addr2[31:3]),
	   .sg_addr3			(sg_addr3[31:3]),
	   .sg_next0			(sg_next0[31:3]),
	   .sg_next1			(sg_next1[31:3]),
	   .sg_next2			(sg_next2[31:3]),
	   .sg_next3			(sg_next3[31:3]),
	   .wbs_sel_i			(wbs_sel_i[3:0]),
	   .wbs_cyc_i			(wbs_cyc_i),
	   .wbs_stb_i			(wbs_stb_i),
	   .wbs_we_i			(wbs_we_i),
	   .wbs_cab_i			(wbs_cab_i),
	   .wbs_adr_i			(wbs_adr_i[31:0]),
	   .wbs_dat_i			(wbs_dat_i[31:0]),
	   .spi_sel_i			(spi_sel_i),
	   .spi_di_i			(spi_di_i),
	   .spi_do_i			(spi_do_i),
	   .spi_clk_i			(spi_clk_i));
   
   /* for fifo */
endmodule // top