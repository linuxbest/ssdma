/************************************************************************
 *     File Name  : mod.v
 *        Version :
 *           Date : 
 *    Description : 
 *   Dependencies :
 *
 *        Company : Beijing Soul Tech.
 *
 *   Copyright (C) 2008 Beijing Soul tech.
 *
 ***********************************************************************/

module mod(/*AUTOARG*/
   // Outputs
   m_src_getn, m_dst_putn, m_dst, m_dst_last, m_endn,
   // Inputs
   wb_clk_i, m_reset, dc, m_src, m_src_last,
   m_src_almost_empty, m_src_empty, m_dst_almost_full,
   m_dst_full
   );
   input wb_clk_i;
   input m_reset;

   wire  wb_rst_i = m_reset;
   
   input [23:0] dc;   
   output 	m_src_getn;
   input [63:0] m_src;
   input 	m_src_last;
   input 	m_src_almost_empty;
   input 	m_src_empty;
   
   output 	m_dst_putn;
   output [63:0] m_dst;
   output 	 m_dst_last;
   input 	 m_dst_almost_full;
   input 	 m_dst_full;

   output 	 m_endn;
   
   // synopsys translate_off
   pullup(m_dst_putn);
   pullup(m_src_getn);
   pullup(m_endn);
   // synopsys translate_on

   read read(/*AUTOINST*/
	     // Outputs
	     .m_src_getn		(m_src_getn),
	     .m_dst_putn		(m_dst_putn),
	     .m_dst			(m_dst[63:0]),
	     .m_dst_last		(m_dst_last),
	     .m_endn			(m_endn),
	     // Inputs
	     .wb_clk_i			(wb_clk_i),
	     .wb_rst_i			(wb_rst_i),
	     .dc			(dc[23:0]),
	     .m_src			(m_src[63:0]),
	     .m_src_last		(m_src_last),
	     .m_src_almost_empty	(m_src_almost_empty),
	     .m_src_empty		(m_src_empty),
	     .m_dst_almost_full		(m_dst_almost_full),
	     .m_dst_full		(m_dst_full));
   fill fill(/*AUTOINST*/
	     // Outputs
	     .m_src_getn		(m_src_getn),
	     .m_dst_putn		(m_dst_putn),
	     .m_dst			(m_dst[63:0]),
	     .m_dst_last		(m_dst_last),
	     .m_endn			(m_endn),
	     // Inputs
	     .wb_clk_i			(wb_clk_i),
	     .wb_rst_i			(wb_rst_i),
	     .dc			(dc[23:0]),
	     .m_src			(m_src[63:0]),
	     .m_src_last		(m_src_last),
	     .m_src_almost_empty	(m_src_almost_empty),
	     .m_src_empty		(m_src_empty),
	     .m_dst_almost_full		(m_dst_almost_full),
	     .m_dst_full		(m_dst_full));
   copy copy(/*AUTOINST*/
	     // Outputs
	     .m_src_getn		(m_src_getn),
	     .m_dst_putn		(m_dst_putn),
	     .m_dst			(m_dst[63:0]),
	     .m_dst_last		(m_dst_last),
	     .m_endn			(m_endn),
	     // Inputs
	     .wb_clk_i			(wb_clk_i),
	     .wb_rst_i			(wb_rst_i),
	     .dc			(dc[23:0]),
	     .m_src			(m_src[63:0]),
	     .m_src_last		(m_src_last),
	     .m_src_almost_empty	(m_src_almost_empty),
	     .m_src_empty		(m_src_empty),
	     .m_dst_almost_full		(m_dst_almost_full),
	     .m_dst_full		(m_dst_full));
   
endmodule // mod