module dummy(/*AUTOARG*/
   // Outputs
   ss_start2, ss_start3, ss_end2, ss_end3, ss_stop2,
   ss_stop3, wbs_dat_i2, wbs_dat_i3, wbs_dat64_i2,
   wbs_dat64_i3, m_src_getn0, m_dst_putn0, m_dst0,
   m_dst_last0,
   // Inputs
   wb_clk_i, wb_rst_i, ss_xfer2, ss_xfer3, ss_last2,
   ss_last3, wbs_dat_o2, wbs_dat_o3, wbs_dat64_o2,
   wbs_dat64_o3, dc1, m_src0, m_src_last0,
   m_src_almost_empty0, m_src_empty0, m_dst_almost_full0,
   m_dst_full0, m_reset1
   );
   
   input wb_clk_i;		// clock signal
   input wb_rst_i;		// reset signal
   
   /* 0,1
    * xfer   true 表示数据读入成功
    * ready  true  表示 fifo 就要满了，
    *        false
    * 
    */
   input ss_xfer2,
	 ss_xfer3;
   output ss_start2, 
	  ss_start3,
	  ss_end2,
	  ss_end3;
   output ss_stop2,
	  ss_stop3;
   input ss_last2,
	 ss_last3;
   input [31:0]	wbs_dat_o2,
		wbs_dat_o3,
		wbs_dat64_o2,
		wbs_dat64_o3;
   output [31:0] wbs_dat_i2,
		 wbs_dat_i3,
		 wbs_dat64_i2,
		 wbs_dat64_i3;
   
   input [23:0]  dc1;

   output 	 m_src_getn0;
   input [63:0]  m_src0;
   input 	 m_src_last0;
   input 	 m_src_almost_empty0;
   input 	 m_src_empty0;
   
   output 	 m_dst_putn0;
   output [63:0] m_dst0;
   output 	 m_dst_last0;
   input 	 m_dst_almost_full0;
   input 	 m_dst_full0;
   
   input 	 m_reset1;
   
endmodule // dummy