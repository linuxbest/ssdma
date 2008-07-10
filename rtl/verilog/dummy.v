module dummy(/*AUTOARG*/
   // Outputs
   ss_ready0, ss_ready1, ss_ready2, ss_ready3, wbs_dat_i0,
   wbs_dat_i1, wbs_dat_i2, wbs_dat_i3, wbs_dat64_i0,
   wbs_dat64_i1, wbs_dat64_i2, wbs_dat64_i3,
   // Inputs
   wb_clk_i, wb_rst_i, sg_state0, sg_state1, sg_state2,
   sg_state3, sg_desc0, sg_desc1, sg_desc2, sg_desc3,
   sg_addr0, sg_addr1, sg_addr2, sg_addr3, sg_next0,
   sg_next1, sg_next2, sg_next3, ss_xfer0, ss_xfer1,
   ss_xfer2, ss_xfer3, dc0, dc1
   );
   
   input wb_clk_i;		// clock signal
   input wb_rst_i;		// reset signal
   
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
   input [23:0]  dc0, dc1;
   
endmodule // dummy