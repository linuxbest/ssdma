/************************************************************************
 *     File Name  : ch1.v
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

module ch1 (/*AUTOARG*/
   // Outputs
   ss_stop2, ss_stop3, ss_start2, ss_start3, ss_end2,
   ss_end3, m_src_last1, m_src_almost_empty1, m_src_empty1,
   m_dst_almost_full1, m_dst_full1, ocnt1, wbs_dat_i2,
   wbs_dat_i3, wbs_dat64_i2, wbs_dat64_i3, m_src1,
   // Inputs
   wb_clk_i, wb_rst_i, ss_xfer2, ss_xfer3, ss_last2,
   ss_last3, m_reset1, m_src_getn1, m_dst_putn1,
   m_dst_last1, m_endn1, wbs_dat_o2, wbs_dat_o3,
   wbs_dat64_o2, wbs_dat64_o3, dc1, m_dst1
   );
   /* output */
   output ss_stop2,
	  ss_stop3,
	  ss_start2,
	  ss_start3,
	  ss_end2,
	  ss_end3,
	  m_src_last1,
	  m_src_almost_empty1,
	  m_src_empty1,
	  m_dst_almost_full1,
	  m_dst_full1;
   output [15:0] ocnt1;
   output [31:0] wbs_dat_i2,
		 wbs_dat_i3,
		 wbs_dat64_i2,
		 wbs_dat64_i3;
   output [63:0] m_src1;

   /* input */
   input wb_clk_i,
	 wb_rst_i,
	 ss_xfer2,
	 ss_xfer3,
	 ss_last2,
	 ss_last3,
	 m_reset1,
	 m_src_getn1,
	 m_dst_putn1,
	 m_dst_last1,
	 m_endn1;
   input [31:0] wbs_dat_o2,
		wbs_dat_o3,
		wbs_dat64_o2,
		wbs_dat64_o3;
   input [23:0] dc1;
   input [63:0] m_dst1;
   
   ch ch1(
	   // Outputs
	   .src_stop			(ss_stop2),
	   .dst_stop			(ss_stop3),
	   .src_start			(ss_start2),
	   .dst_start			(ss_start3),
	   .src_end			(ss_end2),
	   .dst_end			(ss_end3),
	   .src_dat_i			(wbs_dat_i2[31:0]),
	   .dst_dat_i			(wbs_dat_i3[31:0]),
	   .src_dat64_i 		(wbs_dat64_i2[31:0]),
	   .dst_dat64_i 		(wbs_dat64_i3[31:0]),
	   .m_src			(m_src1[63:0]),
	   .m_src_last			(m_src_last1),
	   .m_src_almost_empty		(m_src_almost_empty1),
	   .m_src_empty 		(m_src_empty1),
	   .m_dst_almost_full		(m_dst_almost_full1),
	   .m_dst_full			(m_dst_full1),
	   .ocnt			(ocnt1[15:0]),
	   // Inputs
	   .wb_clk_i			(wb_clk_i),
	   .wb_rst_i			(wb_rst_i),
	   .src_xfer			(ss_xfer2),
	   .dst_xfer			(ss_xfer3),
	   .src_last			(ss_last2),
	   .dst_last			(ss_last3),
	   .src_dat_o			(wbs_dat_o2[31:0]),
	   .dst_dat_o			(wbs_dat_o3[31:0]),
	   .src_dat64_o 		(wbs_dat64_o2[31:0]),
	   .dst_dat64_o 		(wbs_dat64_o3[31:0]),
	   .dc				(dc1[23:0]),
	   .m_reset			(m_reset1),
	   .m_src_getn			(m_src_getn1),
	   .m_dst_putn			(m_dst_putn1),
	   .m_dst			(m_dst1[63:0]),
	   .m_dst_last			(m_dst_last1),
	   .m_endn			(m_endn1));
   
endmodule // ch1
