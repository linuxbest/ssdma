/************************************************************************
 *     File Name  : mixer.v
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
module mixer(/*AUTOARG*/
   // Outputs
   wbs_dat_o0, wbs_dat64_o0, wbs_ack0, wbs_err0, wbs_rty0,
   wbs_dat_o1, wbs_dat64_o1, wbs_ack1, wbs_err1, wbs_rty1,
   wbs_dat_o2, wbs_dat64_o2, wbs_ack2, wbs_err2, wbs_rty2,
   wbs_dat_o3, wbs_dat64_o3, wbs_ack3, wbs_err3, wbs_rty3,
   wbs_dat_o4, wbs_dat64_o4, wbs_ack4, wbs_err4, wbs_rty4,
   wbm_cyc_o, wbm_stb_o, wbm_we_o, wbm_cab_o, wbm_sel_o,
   wbm_adr_o, wbm_dat_o, wbm_dat64_o,
   // Inputs
   wb_clk_i, wb_rst_i, wbs_cyc0, wbs_stb0, wbs_we0,
   wbs_cab0, wbs_sel0, wbs_adr0, wbs_dat_i0, wbs_dat64_i0,
   wbs_cyc1, wbs_stb1, wbs_we1, wbs_cab1, wbs_sel1,
   wbs_adr1, wbs_dat_i1, wbs_dat64_i1, wbs_cyc2, wbs_stb2,
   wbs_we2, wbs_cab2, wbs_sel2, wbs_adr2, wbs_dat_i2,
   wbs_dat64_i2, wbs_cyc3, wbs_stb3, wbs_we3, wbs_cab3,
   wbs_sel3, wbs_adr3, wbs_dat_i3, wbs_dat64_i3, wbs_cyc4,
   wbs_stb4, wbs_we4, wbs_cab4, wbs_sel4, wbs_adr4,
   wbs_dat_i4, wbs_dat64_i4, gnt, wbm_ack_i, wbm_err_i,
   wbm_rty_i, wbm_dat_i, wbm_dat64_i
   );

   input wb_clk_i,
	 wb_rst_i;

   /* Channel 0 */
   input wbs_cyc0,
	 wbs_stb0,
	 wbs_we0,
	 wbs_cab0;
   input [3:0] wbs_sel0;
   input [31:0] wbs_adr0,
		wbs_dat_i0,
		wbs_dat64_i0;
   output [31:0] wbs_dat_o0,
		 wbs_dat64_o0;
   output wbs_ack0,
	  wbs_err0,
	  wbs_rty0;

   /* Channel 1*/
   input  wbs_cyc1,
	  wbs_stb1,
	  wbs_we1,
	  wbs_cab1;
   input [3:0] wbs_sel1;
   input [31:0] wbs_adr1,
		wbs_dat_i1,
		wbs_dat64_i1;
   output [31:0] wbs_dat_o1,
		 wbs_dat64_o1;
   output wbs_ack1,
	  wbs_err1,
	  wbs_rty1;

   /* Channel 2*/
   input  wbs_cyc2,
	  wbs_stb2,
	  wbs_we2,
	  wbs_cab2;
   input [3:0] wbs_sel2;
   input [31:0] wbs_adr2,
		wbs_dat_i2,
		wbs_dat64_i2;
   output [31:0] wbs_dat_o2,
		 wbs_dat64_o2;
   output wbs_ack2,
	  wbs_err2,
	  wbs_rty2;

   /* Channel 3*/
   input  wbs_cyc3,
	  wbs_stb3,
	  wbs_we3,
	  wbs_cab3;
   input [3:0] wbs_sel3;
   input [31:0] wbs_adr3,
		wbs_dat_i3,
		wbs_dat64_i3;
   output [31:0] wbs_dat_o3,
		 wbs_dat64_o3;
   output wbs_ack3,
	  wbs_err3,
	  wbs_rty3;

   /* Channel M */
   input  wbs_cyc4,
	  wbs_stb4,
	  wbs_we4,
	  wbs_cab4;
   input [3:0] wbs_sel4;
   input [31:0] wbs_adr4,
		wbs_dat_i4,
		wbs_dat64_i4;
   output [31:0] wbs_dat_o4,
		 wbs_dat64_o4;
   output wbs_ack4,
	  wbs_err4,
	  wbs_rty4;

   /* gnt */
   input [4:0] gnt;

   /* WB interface */
   output      wbm_cyc_o,
	       wbm_stb_o,
	       wbm_we_o,
	       wbm_cab_o;
   output [3:0] wbm_sel_o;
   output [31:0] wbm_adr_o,
		 wbm_dat_o,
		 wbm_dat64_o;
   input 	 wbm_ack_i,
		 wbm_err_i,
		 wbm_rty_i;
   input [31:0]  wbm_dat_i,
		 wbm_dat64_i;
   
   /* mo AUTO_TEMPLATE "_\([a-z] +\)" (
    .O(wbm_@_o[]),
    .gnt(gnt[]),
    .I({wbs_@4,wbs_@3,wbs_@2,wbs_@1,wbs_@0}),
    );*/

   mo o_cyc(/*AUTOINST*/
	    // Outputs
	    .O				(wbm__o),		 // Templated
	    // Inputs
	    .gnt			(gnt[4:0]),		 // Templated
	    .I				({wbs_4,wbs_3,wbs_2,wbs_1,wbs_0})); // Templated
   mo o_stb(/*AUTOINST*/
	    // Outputs
	    .O				(wbm__o),		 // Templated
	    // Inputs
	    .gnt			(gnt[4:0]),		 // Templated
	    .I				({wbs_4,wbs_3,wbs_2,wbs_1,wbs_0})); // Templated
   mo o_we(/*AUTOINST*/
	   // Outputs
	   .O				(wbm__o),		 // Templated
	   // Inputs
	   .gnt				(gnt[4:0]),		 // Templated
	   .I				({wbs_4,wbs_3,wbs_2,wbs_1,wbs_0})); // Templated
   mo o_cab(/*AUTOINST*/
	    // Outputs
	    .O				(wbm__o),		 // Templated
	    // Inputs
	    .gnt			(gnt[4:0]),		 // Templated
	    .I				({wbs_4,wbs_3,wbs_2,wbs_1,wbs_0})); // Templated

   mo4 o_sel(.O				(wbm_sel_o[3:0]),
	     .gnt			(gnt[4:0]),		
	     .I0			(wbs_sel0),
	     .I1			(wbs_sel1),
	     .I2			(wbs_sel2),
	     .I3			(wbs_sel3),
	     .I4                        (wbs_sel4));

   mo32 o_adr(
	      // Outputs
	      .O			(wbm_adr_o[31:0]),
	      // Inputs
	      .gnt			(gnt[4:0]),
	      .I0			(wbs_adr0),
	      .I1			(wbs_adr1),
	      .I2			(wbs_adr2),
	      .I3			(wbs_adr3),
	      .I4			(wbs_adr4));
   mo32 o_dat(
		// Outputs
		.O			(wbm_dat_o[31:0]),
		// Inputs
		.gnt			(gnt[4:0]),
		.I0			(wbs_dat_i0),
		.I1			(wbs_dat_i1),
		.I2			(wbs_dat_i2),
		.I3			(wbs_dat_i3),
		.I4			(wbs_dat_i4));
   mo32 o_dat64(
		// Outputs
		.O			(wbm_dat64_o[31:0]),
		// Inputs
		.gnt			(gnt[4:0]),
		.I0			(wbs_dat64_i0),
		.I1			(wbs_dat64_i1),
		.I2			(wbs_dat64_i2),
		.I3			(wbs_dat64_i3),
		.I4			(wbs_dat64_i4));

   mi i_ack (.O({wbs_ack4,wbs_ack3,wbs_ack2,wbs_ack1,wbs_ack0}),
	     .I(wbm_ack_i),
	     .gnt(gnt));
   mi i_err (.O({wbs_err4,wbs_err3,wbs_err2,wbs_err1,wbs_err0}),
	     .I(wbm_err_i),
	     .gnt(gnt));
   mi i_rty (.O({wbs_rty4,wbs_rty3,wbs_rty2,wbs_rty1,wbs_rty0}),
	     .I(wbm_rty_i),
	     .gnt(gnt));

   mi32 i_dat(.O0(wbs_dat_o0),
	      .O1(wbs_dat_o1),
	      .O2(wbs_dat_o2),
	      .O3(wbs_dat_o3),
	      .O4(wbs_dat_o4),
	      .gnt(gnt),
	      .I(wbm_dat_i));
   
   mi32 i_dat64(.O0(wbs_dat64_o0),
		.O1(wbs_dat64_o1),
		.O2(wbs_dat64_o2),
		.O3(wbs_dat64_o3),
		.O4(wbs_dat64_o4),
		.gnt(gnt),
		.I(wbm_dat64_i));
   
   endmodule // mixer
