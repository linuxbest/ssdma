/************************************************************************
 *     File Name  : ch0.v
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
module ch0 (/*AUTOARG*/
   // Outputs
   ss_stop0, ss_stop1, ss_start0, ss_start1, ss_end0,
   ss_end1, m_src_last0, m_src_almost_empty0, m_src_empty0,
   m_dst_almost_full0, m_dst_full0, ocnt0, wbs_dat_i0,
   wbs_dat_i1, wbs_dat64_i0, wbs_dat64_i1, m_src0,
   // Inputs
   wb_clk_i, wb_rst_i, ss_xfer0, ss_xfer1, ss_last0,
   ss_last1, m_reset0, m_src_getn0, m_dst_putn0,
   m_dst_last0, m_endn0, wbs_dat_o0, wbs_dat_o1,
   wbs_dat64_o0, wbs_dat64_o1, dc0, m_dst0
   );
   /* output */
   output ss_stop0,
	  ss_stop1,
	  ss_start0,
	  ss_start1,
	  ss_end0,
	  ss_end1,
	  m_src_last0,
	  m_src_almost_empty0,
	  m_src_empty0,
	  m_dst_almost_full0,
	  m_dst_full0;
   output [15:0] ocnt0;
   output [31:0] wbs_dat_i0,
		 wbs_dat_i1,
		 wbs_dat64_i0,
		 wbs_dat64_i1;
   output [63:0] m_src0;

   /* input */
   input wb_clk_i,
	 wb_rst_i,
	 ss_xfer0,
	 ss_xfer1,
	 ss_last0,
	 ss_last1,
	 m_reset0,
	 m_src_getn0,
	 m_dst_putn0,
	 m_dst_last0,
	 m_endn0;
   input [31:0] wbs_dat_o0,
		wbs_dat_o1,
		wbs_dat64_o0,
		wbs_dat64_o1;
   input [23:0] dc0;
   input [63:0] m_dst0;

   ch ch0(
	   // Outputs
	   .src_stop			(ss_stop0),
	   .dst_stop			(ss_stop1),
	   .src_start			(ss_start0),
	   .dst_start			(ss_start1),
	   .src_end			(ss_end0),
	   .dst_end			(ss_end1),
	   .src_dat_i			(wbs_dat_i0[31:0]),
	   .dst_dat_i			(wbs_dat_i1[31:0]),
	   .src_dat64_i		        (wbs_dat64_i0[31:0]),
	   .dst_dat64_i		        (wbs_dat64_i1[31:0]),
	   .m_src			(m_src0[63:0]),
	   .m_src_last			(m_src_last0),
	   .m_src_almost_empty		(m_src_almost_empty0),
	   .m_src_empty		        (m_src_empty0),
	   .m_dst_almost_full		(m_dst_almost_full0),
	   .m_dst_full			(m_dst_full0),
	   .ocnt			(ocnt0[15:0]),
	   // Inputs
	   .wb_clk_i			(wb_clk_i),
	   .wb_rst_i			(wb_rst_i),
	   .src_xfer			(ss_xfer0),
	   .dst_xfer			(ss_xfer1),
	   .src_last			(ss_last0),
	   .dst_last			(ss_last1),
	   .src_dat_o			(wbs_dat_o0[31:0]),
	   .dst_dat_o			(wbs_dat_o1[31:0]),
	   .src_dat64_o 		(wbs_dat64_o0[31:0]),
	   .dst_dat64_o 		(wbs_dat64_o1[31:0]),
	   .dc				(dc0[23:0]),
	   .m_reset			(m_reset0),
	   .m_src_getn			(m_src_getn0),
	   .m_dst_putn			(m_dst_putn0),
	   .m_dst			(m_dst0[63:0]),
	   .m_dst_last			(m_dst_last0),
	   .m_endn			(m_endn0));
   
endmodule // ch0
