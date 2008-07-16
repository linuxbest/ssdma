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
   wbm_cab_o, wbm_adr_o, spi_sel_o, spi_en, spi_do_o,
   spi_do_en, spi_di_o, spi_di_en, spi_clk_o, wb_int_o,
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

   output 		wb_int_o;
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			append;			// From wbm of wbm.v
   wire			append_clear;		// From ctrl of ctrl.v
   wire			busy;			// From ctrl of ctrl.v
   wire			c_done0;		// From r_0 of ss_sg.v
   wire			c_done1;		// From r_1 of ss_sg.v
   wire			c_done2;		// From r_2 of ss_sg.v
   wire			c_done3;		// From r_3 of ss_sg.v
   wire [7:0]		csr;			// From ctrl of ctrl.v
   wire [31:3]		ctl_adr0;		// From ctrl of ctrl.v
   wire [31:3]		ctl_adr1;		// From ctrl of ctrl.v
   wire [7:0]		ctrl_state;		// From ctrl of ctrl.v
   wire [31:0]		dar;			// From ctrl of ctrl.v
   wire [23:0]		dc0;			// From ctrl of ctrl.v
   wire [23:0]		dc1;			// From ctrl of ctrl.v
   wire			enable;			// From wbm of wbm.v
   wire [4:0]		gnt;			// From arbiter of arbiter.v
   wire [63:0]		m_dst0;			// From mod_0 of mod.v
   wire [63:0]		m_dst1;			// From mod_1 of mod.v
   wire			m_dst_almost_full0;	// From ch0 of ch0.v
   wire			m_dst_almost_full1;	// From ch1 of ch1.v
   wire			m_dst_full0;		// From ch0 of ch0.v
   wire			m_dst_full1;		// From ch1 of ch1.v
   wire			m_dst_last0;		// From mod_0 of mod.v
   wire			m_dst_last1;		// From mod_1 of mod.v
   wire			m_dst_putn0;		// From mod_0 of mod.v
   wire			m_dst_putn1;		// From mod_1 of mod.v
   wire			m_enable0;		// From ctrl of ctrl.v
   wire			m_enable1;		// From ctrl of ctrl.v
   wire			m_endn0;		// From mod_0 of mod.v
   wire			m_endn1;		// From mod_1 of mod.v
   wire			m_reset0;		// From ctrl of ctrl.v
   wire			m_reset1;		// From ctrl of ctrl.v
   wire [63:0]		m_src0;			// From ch0 of ch0.v
   wire [63:0]		m_src1;			// From ch1 of ch1.v
   wire			m_src_almost_empty0;	// From ch0 of ch0.v
   wire			m_src_almost_empty1;	// From ch1 of ch1.v
   wire			m_src_empty0;		// From ch0 of ch0.v
   wire			m_src_empty1;		// From ch1 of ch1.v
   wire			m_src_getn0;		// From mod_0 of mod.v
   wire			m_src_getn1;		// From mod_1 of mod.v
   wire			m_src_last0;		// From ch0 of ch0.v
   wire			m_src_last1;		// From ch1 of ch1.v
   wire [31:3]		ndar;			// From wbm of wbm.v
   wire			ndar_dirty;		// From wbm of wbm.v
   wire			ndar_dirty_clear;	// From ctrl of ctrl.v
   wire [31:3]		next_desc;		// From ctrl of ctrl.v
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
   wire [1:0]		ss_adr0;		// From ctrl of ctrl.v
   wire [1:0]		ss_adr1;		// From ctrl of ctrl.v
   wire [1:0]		ss_adr2;		// From ctrl of ctrl.v
   wire [1:0]		ss_adr3;		// From ctrl of ctrl.v
   wire [31:0]		ss_dat0;		// From ctrl of ctrl.v
   wire [31:0]		ss_dat1;		// From ctrl of ctrl.v
   wire [31:0]		ss_dat2;		// From ctrl of ctrl.v
   wire [31:0]		ss_dat3;		// From ctrl of ctrl.v
   wire [23:0]		ss_dc0;			// From ctrl of ctrl.v
   wire [23:0]		ss_dc1;			// From ctrl of ctrl.v
   wire [23:0]		ss_dc2;			// From ctrl of ctrl.v
   wire [23:0]		ss_dc3;			// From ctrl of ctrl.v
   wire			ss_done0;		// From ctrl of ctrl.v
   wire			ss_done1;		// From ctrl of ctrl.v
   wire			ss_done2;		// From ctrl of ctrl.v
   wire			ss_done3;		// From ctrl of ctrl.v
   wire			ss_end0;		// From ch0 of ch0.v
   wire			ss_end1;		// From ch0 of ch0.v
   wire			ss_end2;		// From ch1 of ch1.v
   wire			ss_end3;		// From ch1 of ch1.v
   wire			ss_last0;		// From r_0 of ss_sg.v
   wire			ss_last1;		// From r_1 of ss_sg.v
   wire			ss_last2;		// From r_2 of ss_sg.v
   wire			ss_last3;		// From r_3 of ss_sg.v
   wire			ss_start0;		// From ch0 of ch0.v
   wire			ss_start1;		// From ch0 of ch0.v
   wire			ss_start2;		// From ch1 of ch1.v
   wire			ss_start3;		// From ch1 of ch1.v
   wire			ss_stop0;		// From ch0 of ch0.v
   wire			ss_stop1;		// From ch0 of ch0.v
   wire			ss_stop2;		// From ch1 of ch1.v
   wire			ss_stop3;		// From ch1 of ch1.v
   wire			ss_we0;			// From ctrl of ctrl.v
   wire			ss_we1;			// From ctrl of ctrl.v
   wire			ss_we2;			// From ctrl of ctrl.v
   wire			ss_we3;			// From ctrl of ctrl.v
   wire			ss_xfer0;		// From r_0 of ss_sg.v
   wire			ss_xfer1;		// From r_1 of ss_sg.v
   wire			ss_xfer2;		// From r_2 of ss_sg.v
   wire			ss_xfer3;		// From r_3 of ss_sg.v
   wire			wb_int_clear;		// From wbm of wbm.v
   wire			wbs_ack0;		// From m0 of mixer.v
   wire			wbs_ack1;		// From m0 of mixer.v
   wire			wbs_ack2;		// From m0 of mixer.v
   wire			wbs_ack3;		// From m0 of mixer.v
   wire			wbs_ack4;		// From m0 of mixer.v
   wire [31:0]		wbs_adr0;		// From r_0 of ss_sg.v
   wire [31:0]		wbs_adr1;		// From r_1 of ss_sg.v
   wire [31:0]		wbs_adr2;		// From r_2 of ss_sg.v
   wire [31:0]		wbs_adr3;		// From r_3 of ss_sg.v
   wire [31:0]		wbs_adr4;		// From ctrl of ctrl.v
   wire			wbs_cab0;		// From r_0 of ss_sg.v
   wire			wbs_cab1;		// From r_1 of ss_sg.v
   wire			wbs_cab2;		// From r_2 of ss_sg.v
   wire			wbs_cab3;		// From r_3 of ss_sg.v
   wire			wbs_cab4;		// From ctrl of ctrl.v
   wire			wbs_cyc0;		// From r_0 of ss_sg.v
   wire			wbs_cyc1;		// From r_1 of ss_sg.v
   wire			wbs_cyc2;		// From r_2 of ss_sg.v
   wire			wbs_cyc3;		// From r_3 of ss_sg.v
   wire			wbs_cyc4;		// From ctrl of ctrl.v
   wire [31:0]		wbs_dat64_i0;		// From ch0 of ch0.v
   wire [31:0]		wbs_dat64_i1;		// From ch0 of ch0.v
   wire [31:0]		wbs_dat64_i2;		// From ch1 of ch1.v
   wire [31:0]		wbs_dat64_i3;		// From ch1 of ch1.v
   wire [31:0]		wbs_dat64_i4;		// From ctrl of ctrl.v
   wire [31:0]		wbs_dat64_o0;		// From m0 of mixer.v
   wire [31:0]		wbs_dat64_o1;		// From m0 of mixer.v
   wire [31:0]		wbs_dat64_o2;		// From m0 of mixer.v
   wire [31:0]		wbs_dat64_o3;		// From m0 of mixer.v
   wire [31:0]		wbs_dat64_o4;		// From m0 of mixer.v
   wire [31:0]		wbs_dat_i0;		// From ch0 of ch0.v
   wire [31:0]		wbs_dat_i1;		// From ch0 of ch0.v
   wire [31:0]		wbs_dat_i2;		// From ch1 of ch1.v
   wire [31:0]		wbs_dat_i3;		// From ch1 of ch1.v
   wire [31:0]		wbs_dat_i4;		// From ctrl of ctrl.v
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
   wire [3:0]		wbs_sel4;		// From ctrl of ctrl.v
   wire			wbs_stb0;		// From r_0 of ss_sg.v
   wire			wbs_stb1;		// From r_1 of ss_sg.v
   wire			wbs_stb2;		// From r_2 of ss_sg.v
   wire			wbs_stb3;		// From r_3 of ss_sg.v
   wire			wbs_stb4;		// From ctrl of ctrl.v
   wire			wbs_we0;		// From r_0 of ss_sg.v
   wire			wbs_we1;		// From r_1 of ss_sg.v
   wire			wbs_we2;		// From r_2 of ss_sg.v
   wire			wbs_we3;		// From r_3 of ss_sg.v
   wire			wbs_we4;		// From ctrl of ctrl.v
   // End of automatics
   
   /* ss_sg AUTO_TEMPLATE "_\([0-9]+\)" (
    .wb_clk_i(wb_clk_i),
    .wb_rst_i(wb_rst_i),
    .\(.*\)(\1@[]),
    );
    */
   ss_sg r_0(.rw(1'b0),
	     /*AUTOINST*/
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
	     .ss_last			(ss_last0),		 // Templated
	     .c_done			(c_done0),		 // Templated
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
	     .ss_dc			(ss_dc0[23:0]),		 // Templated
	     .ss_start			(ss_start0),		 // Templated
	     .ss_end			(ss_end0),		 // Templated
	     .ss_stop			(ss_stop0));		 // Templated

   ss_sg r_1 (.rw(1'b1),
	      /*AUTOINST*/
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
	      .ss_last			(ss_last1),		 // Templated
	      .c_done			(c_done1),		 // Templated
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
	      .ss_dc			(ss_dc1[23:0]),		 // Templated
	      .ss_start			(ss_start1),		 // Templated
	      .ss_end			(ss_end1),		 // Templated
	      .ss_stop			(ss_stop1));		 // Templated

   ss_sg r_2 (.rw(1'b0),
	      /*AUTOINST*/
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
	      .ss_last			(ss_last2),		 // Templated
	      .c_done			(c_done2),		 // Templated
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
	      .ss_dc			(ss_dc2[23:0]),		 // Templated
	      .ss_start			(ss_start2),		 // Templated
	      .ss_end			(ss_end2),		 // Templated
	      .ss_stop			(ss_stop2));		 // Templated

   ss_sg r_3 (.rw(1'b1),
	      /*AUTOINST*/
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
	      .ss_last			(ss_last3),		 // Templated
	      .c_done			(c_done3),		 // Templated
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
	      .ss_dc			(ss_dc3[23:0]),		 // Templated
	      .ss_start			(ss_start3),		 // Templated
	      .ss_end			(ss_end3),		 // Templated
	      .ss_stop			(ss_stop3));		 // Templated
   
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
	   .ndar_dirty			(ndar_dirty),
	   .ndar			(ndar[31:3]),
	   .append			(append),
	   .enable			(enable),
	   .wb_int_clear		(wb_int_clear),
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
	   .spi_clk_i			(spi_clk_i),
	   .dar				(dar[31:0]),
	   .csr				(csr[7:0]),
	   .ndar_dirty_clear		(ndar_dirty_clear),
	   .append_clear		(append_clear),
	   .wb_int_o			(wb_int_o),
	   .busy			(busy),
	   .ctl_adr0			(ctl_adr0[31:3]),
	   .ctl_adr1			(ctl_adr1[31:3]),
	   .next_desc			(next_desc[31:3]),
	   .ctrl_state			(ctrl_state[7:0]));

   ctrl ctrl(/*AUTOINST*/
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
	     .ss_dc0			(ss_dc0[23:0]),
	     .ss_dc1			(ss_dc1[23:0]),
	     .ss_dc2			(ss_dc2[23:0]),
	     .ss_dc3			(ss_dc3[23:0]),
	     .wb_int_o			(wb_int_o),
	     .dar			(dar[31:0]),
	     .csr			(csr[7:0]),
	     .ndar_dirty_clear		(ndar_dirty_clear),
	     .busy			(busy),
	     .append_clear		(append_clear),
	     .dc0			(dc0[23:0]),
	     .dc1			(dc1[23:0]),
	     .ctl_adr0			(ctl_adr0[31:3]),
	     .ctl_adr1			(ctl_adr1[31:3]),
	     .next_desc			(next_desc[31:3]),
	     .m_reset0			(m_reset0),
	     .m_reset1			(m_reset1),
	     .m_enable0			(m_enable0),
	     .m_enable1			(m_enable1),
	     .ctrl_state		(ctrl_state[7:0]),
	     // Inputs
	     .wb_clk_i			(wb_clk_i),
	     .wb_rst_i			(wb_rst_i),
	     .wbs_dat_o4		(wbs_dat_o4[31:0]),
	     .wbs_dat64_o4		(wbs_dat64_o4[31:0]),
	     .wbs_ack4			(wbs_ack4),
	     .wbs_err4			(wbs_err4),
	     .wbs_rty4			(wbs_rty4),
	     .c_done0			(c_done0),
	     .c_done1			(c_done1),
	     .c_done2			(c_done2),
	     .c_done3			(c_done3),
	     .ndar_dirty		(ndar_dirty),
	     .ndar			(ndar[31:3]),
	     .wb_int_clear		(wb_int_clear),
	     .append			(append),
	     .enable			(enable));
   
   ch0 ch0(/*AUTOINST*/
	   // Outputs
	   .ss_stop0			(ss_stop0),
	   .ss_stop1			(ss_stop1),
	   .ss_start0			(ss_start0),
	   .ss_start1			(ss_start1),
	   .ss_end0			(ss_end0),
	   .ss_end1			(ss_end1),
	   .wbs_dat_i0			(wbs_dat_i0[31:0]),
	   .wbs_dat_i1			(wbs_dat_i1[31:0]),
	   .wbs_dat64_i0		(wbs_dat64_i0[31:0]),
	   .wbs_dat64_i1		(wbs_dat64_i1[31:0]),
	   .m_src0			(m_src0[63:0]),
	   .m_src_last0			(m_src_last0),
	   .m_src_almost_empty0		(m_src_almost_empty0),
	   .m_src_empty0		(m_src_empty0),
	   .m_dst_almost_full0		(m_dst_almost_full0),
	   .m_dst_full0			(m_dst_full0),
	   // Inputs
	   .wb_clk_i			(wb_clk_i),
	   .wb_rst_i			(wb_rst_i),
	   .ss_xfer0			(ss_xfer0),
	   .ss_xfer1			(ss_xfer1),
	   .ss_last0			(ss_last0),
	   .ss_last1			(ss_last1),
	   .wbs_dat_o0			(wbs_dat_o0[31:0]),
	   .wbs_dat_o1			(wbs_dat_o1[31:0]),
	   .wbs_dat64_o0		(wbs_dat64_o0[31:0]),
	   .wbs_dat64_o1		(wbs_dat64_o1[31:0]),
	   .dc0				(dc0[23:0]),
	   .m_reset0			(m_reset0),
	   .m_src_getn0			(m_src_getn0),
	   .m_dst_putn0			(m_dst_putn0),
	   .m_dst0			(m_dst0[63:0]),
	   .m_dst_last0			(m_dst_last0),
	   .m_endn0			(m_endn0));

   ch1 ch1(/*AUTOINST*/
	   // Outputs
	   .ss_stop2			(ss_stop2),
	   .ss_stop3			(ss_stop3),
	   .ss_start2			(ss_start2),
	   .ss_start3			(ss_start3),
	   .ss_end2			(ss_end2),
	   .ss_end3			(ss_end3),
	   .wbs_dat_i2			(wbs_dat_i2[31:0]),
	   .wbs_dat_i3			(wbs_dat_i3[31:0]),
	   .wbs_dat64_i2		(wbs_dat64_i2[31:0]),
	   .wbs_dat64_i3		(wbs_dat64_i3[31:0]),
	   .m_src1			(m_src1[63:0]),
	   .m_src_last1			(m_src_last1),
	   .m_src_almost_empty1		(m_src_almost_empty1),
	   .m_src_empty1		(m_src_empty1),
	   .m_dst_almost_full1		(m_dst_almost_full1),
	   .m_dst_full1			(m_dst_full1),
	   // Inputs
	   .wb_clk_i			(wb_clk_i),
	   .wb_rst_i			(wb_rst_i),
	   .ss_xfer2			(ss_xfer2),
	   .ss_xfer3			(ss_xfer3),
	   .ss_last2			(ss_last2),
	   .ss_last3			(ss_last3),
	   .wbs_dat_o2			(wbs_dat_o2[31:0]),
	   .wbs_dat_o3			(wbs_dat_o3[31:0]),
	   .wbs_dat64_o2		(wbs_dat64_o2[31:0]),
	   .wbs_dat64_o3		(wbs_dat64_o3[31:0]),
	   .dc1				(dc1[23:0]),
	   .m_reset1			(m_reset1),
	   .m_src_getn1			(m_src_getn1),
	   .m_dst_putn1			(m_dst_putn1),
	   .m_dst1			(m_dst1[63:0]),
	   .m_dst_last1			(m_dst_last1),
	   .m_endn1			(m_endn1));
   
   /* mod AUTO_TEMPLATE "_\([0-9]+\)" (
    .wb_clk_i(wb_clk_i),
    .wb_rst_i(wb_rst_i),
    .\(.*\)(\1@[]),
    );
    */
   mod mod_0(/*AUTOINST*/
	     // Outputs
	     .m_src_getn		(m_src_getn0),		 // Templated
	     .m_dst_putn		(m_dst_putn0),		 // Templated
	     .m_dst			(m_dst0[63:0]),		 // Templated
	     .m_dst_last		(m_dst_last0),		 // Templated
	     .m_endn			(m_endn0),		 // Templated
	     // Inputs
	     .wb_clk_i			(wb_clk_i),		 // Templated
	     .m_reset			(m_reset0),		 // Templated
	     .m_enable			(m_enable0),		 // Templated
	     .dc			(dc0[23:0]),		 // Templated
	     .m_src			(m_src0[63:0]),		 // Templated
	     .m_src_last		(m_src_last0),		 // Templated
	     .m_src_almost_empty	(m_src_almost_empty0),	 // Templated
	     .m_src_empty		(m_src_empty0),		 // Templated
	     .m_dst_almost_full		(m_dst_almost_full0),	 // Templated
	     .m_dst_full		(m_dst_full0));		 // Templated
   mod mod_1(/*AUTOINST*/
	     // Outputs
	     .m_src_getn		(m_src_getn1),		 // Templated
	     .m_dst_putn		(m_dst_putn1),		 // Templated
	     .m_dst			(m_dst1[63:0]),		 // Templated
	     .m_dst_last		(m_dst_last1),		 // Templated
	     .m_endn			(m_endn1),		 // Templated
	     // Inputs
	     .wb_clk_i			(wb_clk_i),		 // Templated
	     .m_reset			(m_reset1),		 // Templated
	     .m_enable			(m_enable1),		 // Templated
	     .dc			(dc1[23:0]),		 // Templated
	     .m_src			(m_src1[63:0]),		 // Templated
	     .m_src_last		(m_src_last1),		 // Templated
	     .m_src_almost_empty	(m_src_almost_empty1),	 // Templated
	     .m_src_empty		(m_src_empty1),		 // Templated
	     .m_dst_almost_full		(m_dst_almost_full1),	 // Templated
	     .m_dst_full		(m_dst_full1));		 // Templated
   
endmodule // top