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
   m_src_getn, m_dst_putn, m_dst, m_dst_last, m_endn, m_cap,
   // Inputs
   wb_clk_i, m_reset, m_enable, dc, m_src, m_src_last,
   m_src_almost_empty, m_src_empty, m_dst_almost_full,
   m_dst_full
   );
   input wb_clk_i;
   input m_reset;
   input m_enable;
   
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

   output [7:0]  m_cap;
   
   // synopsys translate_off
   pullup(m_dst_putn);
   pullup(m_src_getn);
   pullup(m_endn);
   // synopsys translate_on

   rabin64_fp rbhash(/*AUTOINST*/
	     // Outputs
	     .m_src_getn		(m_src_getn),
	     .m_dst_putn		(m_dst_putn),
	     .m_dst			(m_dst[63:0]),
	     .m_dst_last		(m_dst_last),
	     .m_endn			(m_endn),
	     // Inputs
	     .wb_clk_i			(wb_clk_i),
	     .wb_rst_i			(wb_rst_i),
	     .m_enable			(m_enable),
	     .dc			(dc[23:0]),
	     .m_src			(m_src[63:0]),
	     .m_src_last		(m_src_last),
	     .m_src_almost_empty	(m_src_almost_empty),
	     .m_src_empty		(m_src_empty),
	     .m_dst_almost_full		(m_dst_almost_full),
	     .m_dst_full		(m_dst_full));

   assign 	 m_cap = {1'b0,  /* decode */
			  1'b0,  /* encode */
			  1'b0,  /* memcpy */
			  1'b1,  /* rabinpoly */
			  1'b0, 
			  1'b0, 
			  1'b0};
   
endmodule // mod

// Local Variables:
// verilog-library-directories:("." "/p/hw/lzs/encode/rtl/verilog" "/p/hw/lzs/decode/rtl/verilog/")
// verilog-library-files:("/some/path/technology.v" "/some/path/tech2.v")
// verilog-library-extensions:(".v" ".h")
// End:
