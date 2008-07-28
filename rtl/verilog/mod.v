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
	     .m_enable			(m_enable),
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
	     .m_enable			(m_enable),
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
	     .m_enable			(m_enable),
	     .dc			(dc[23:0]),
	     .m_src			(m_src[63:0]),
	     .m_src_last		(m_src_last),
	     .m_src_almost_empty	(m_src_almost_empty),
	     .m_src_empty		(m_src_empty),
	     .m_dst_almost_full		(m_dst_almost_full),
	     .m_dst_full		(m_dst_full));

   wire 	 fo_full   = m_dst_full  || m_dst_almost_full;
   wire 	 src_empty = m_src_empty || m_src_almost_empty;
   
   encode encode(
		 // Outputs
		 .m_dst			(m_dst[63:0]),
		 .m_dst_putn		(m_dst_putn),
		 .m_endn		(m_endn),
		 .m_src_getn		(m_src_getn),
                 .m_dst_last            (m_dst_last),
		 // Inputs
		 .ce			(dc[5] && m_enable),
		 .clk			(wb_clk_i),
		 .fi			(m_src[63:0]),
		 .fo_full		(fo_full),
		 .m_last		(m_src_last),
		 .rst			(wb_rst_i),
		 .src_empty		(src_empty));

   decode_dp decode(
		    // Outputs
		    .m_dst		(m_dst[63:0]),
		    .m_dst_putn		(m_dst_putn),
		    .m_endn		(m_endn),
		    .m_src_getn		(m_src_getn),
		    //.m_dst_last         (m_dst_last),
		    // Inputs
		    .ce			(dc[6] && m_enable),
		    .clk		(wb_clk_i),
		    .rst		(wb_rst_i),
		    .fo_full		(fo_full),
		    .fi			(m_src[63:0]),
		    .m_src_empty	(src_empty),
		    .m_last		(m_src_last),
		    .sbc_done           (m_src_last));
		    
endmodule // mod

// Local Variables:
// verilog-library-directories:("." "/p/hw/lzs/encode/rtl/verilog" "/p/hw/lzs/decode/rtl/verilog/")
// verilog-library-files:("/some/path/technology.v" "/some/path/tech2.v")
// verilog-library-extensions:(".v" ".h")
// End:
