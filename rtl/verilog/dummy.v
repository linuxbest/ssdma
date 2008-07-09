module dummy(/*AUTOARG*/
   // Outputs
   wbs_cyc4, wbs_stb4, wbs_we4, wbs_cab4, wbs_sel4,
   wbs_adr4, wbs_dat_i4, wbs_dat64_i4, ss_we0, ss_we1,
   ss_we2, ss_we3, ss_done0, ss_done1, ss_done2, ss_done3,
   ss_dat0, ss_dat1, ss_dat2, ss_dat3, ss_adr0, ss_adr1,
   ss_adr2, ss_adr3, ss_ready0, ss_ready1, ss_ready2,
   ss_ready3, wbs_dat_i0, wbs_dat_i1, wbs_dat_i2,
   wbs_dat_i3, wbs_dat64_i0, wbs_dat64_i1, wbs_dat64_i2,
   wbs_dat64_i3, wb_int_o, dar, csr, ndar_dirty_clear,
   int_ack_clear, busy, resume_clear,
   // Inputs
   wb_clk_i, wb_rst_i, wbs_dat_o4, wbs_dat64_o4, wbs_ack4,
   wbs_err4, wbs_rty4, sg_state0, sg_state1, sg_state2,
   sg_state3, sg_desc0, sg_desc1, sg_desc2, sg_desc3,
   sg_addr0, sg_addr1, sg_addr2, sg_addr3, sg_next0,
   sg_next1, sg_next2, sg_next3, ss_xfer0, ss_xfer1,
   ss_xfer2, ss_xfer3, ndar_dirty, ndar, int_ack, resume,
   enable
   );
   
   input wb_clk_i;		// clock signal
   input wb_rst_i;		// reset signal
   
   /* WB interface */
   output wbs_cyc4, 		// cycle signal
	  wbs_stb4, 		// strobe 
	  wbs_we4, 		// we 
	  wbs_cab4;		// 
   output [3:0] wbs_sel4;	// byte select
   output [31:0] wbs_adr4, 	// address 
		 wbs_dat_i4, 	// data output
		 wbs_dat64_i4;	// data output high 64
   input [31:0]  wbs_dat_o4,	// data input
		 wbs_dat64_o4;	// data input high 64
   input 	 wbs_ack4, 	// acknowledge
		 wbs_err4, 	// error report
		 wbs_rty4;	// retry report
   
   output ss_we0,
	  ss_we1,
	  ss_we2,
	  ss_we3;

   output ss_done0,
	  ss_done1,
	  ss_done2,
	  ss_done3;

   output [31:0] ss_dat0,
		 ss_dat1,
		 ss_dat2,
		 ss_dat3;

   output [1:0] ss_adr0,
		ss_adr1,
		ss_adr2,
		ss_adr3;

   /* dma channel information */
   input [7:0] sg_state0,
	       sg_state1,
	       sg_state2,
	       sg_state3;
   input [15:0] sg_desc0,
		sg_desc1,
		sg_desc2,
		sg_desc3;
   input [31:3] sg_addr0,
		sg_addr1,
		sg_addr2,
		sg_addr3;
   input [31:3] sg_next0,
		sg_next1,
		sg_next2,
		sg_next3;

   /* fifos */
   input 	ss_xfer0, 
		ss_xfer1,
		ss_xfer2,
		ss_xfer3;
   output 	ss_ready0,
		ss_ready1, 
		ss_ready2, 
		ss_ready3;
   output [31:0] wbs_dat_i0,
		 wbs_dat_i1,
		 wbs_dat_i2,
		 wbs_dat_i3;
   output [31:0] wbs_dat64_i0,
		 wbs_dat64_i1,
		 wbs_dat64_i2,
		 wbs_dat64_i3;

   output 	 wb_int_o;

   output [31:0] dar;
   output [7:0]  csr;
   
   input 	 ndar_dirty;
   output 	 ndar_dirty_clear;
   input [31:3]  ndar;

   input 	 int_ack;
   output 	 int_ack_clear;
   input 	 resume, enable;
   output 	 busy;

   output 	 resume_clear;
   
   
endmodule // dummy