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
module ch0(/*AUTOARG*/
   // Outputs
   ss_start0, ss_start1, ss_end0, ss_end1, wbs_dat_i0,
   wbs_dat_i1, wbs_dat64_i0, wbs_dat64_i1, m_src, m_last,
   m_src_empty, m_dst_full,
   // Inputs
   wb_clk_i, wb_rst_i, ss_xfer0, ss_xfer1, wbs_dat_o0,
   wbs_dat_o1, wbs_dat64_o0, wbs_dat64_o1, dc0, m_src_getn,
   m_dst_putn, m_dst
   );
   input wb_clk_i;
   input wb_rst_i;

   input ss_xfer0,
	 ss_xfer1;
   output ss_start0,
	  ss_start1,
	  ss_end0,
	  ss_end1;
   input [31:0] wbs_dat_o0,
		wbs_dat_o1,
		wbs_dat64_o0,
		wbs_dat64_o1;
   output [31:0] wbs_dat_i0,
		 wbs_dat_i1,
		 wbs_dat64_i0,
		 wbs_dat64_i1;
   input [23:0]  dc0;

   /* module interface */
   input         m_src_getn; /* module get src */
   output [63:0] m_src;      /* src data */
   output        m_last;
   output        m_src_empty;
   
   input         m_dst_putn; /* module put dst */
   input [63:0]  m_dst;      /* dst data */
   output        m_dst_full;
   
   parameter 	 FIFO_WIDTH = 9;
   wire [FIFO_WIDTH-1:0] src_waddr,
			 src_raddr,
			 dst_waddr,
			 dst_raddr;
   
   parameter 		 DATA_WIDTH = 72;
   wire [DATA_WIDTH-1:0] src_di,
			 src_do,
			 dst_di,
			 dst_do;
   fifo_control
     src_control (.rclock_in(wb_clk_i),
		  .wclock_in(wb_clk_i),
		  .renable_in(!m_src_getn),
		  .wenable_in(ss_xfer0),
		  .reset_in(wb_rst_i),
		  .clear_in(m_reset),
		  .almost_empty_out(),
		  .almost_full_out(),
		  .empty_out(),
		  .waddr_out(src_waddr),
		  .raddr_out(src_raddr),
		  .rallow_out(),
		  .wallow_out(),
		  .full_out(),
		  .half_full_out());

   tpram
     src_ram (.clk_a(wb_clk_i),
	      .rst_a(wb_rst_i),
	      .ce_a(1'b1),
	      .we_a(ss_xfer0),
	      .addr_a(src_waddr),
	      .di_a(src_di),
	      .do_a(),
	      .oe_a(1'b1),

	      .clk_b(wb_clk_i),
	      .rst_b(wb_rst_i),
	      .ce_b(1'b1),
	      .we_b(1'b0),
	      .oe_b(1'b1),
	      .addr_b(src_raddr),
	      .do_b(src_do),
	      .di_b());
   defparam 		 src_control.ADDR_LENGTH = FIFO_WIDTH;   
   defparam 		 src_ram.aw = FIFO_WIDTH;
   defparam 		 src_ram.dw = DATA_WIDTH;

   fifo_control
     dst_control (.rclock_in(wb_clk_i),
		  .wclock_in(wb_clk_i),
		  .renable_in(ss_xfer1),
		  .wenable_in(!m_dst_putn),
		  .reset_in(wb_rst_i),
		  .clear_in(m_reset),
		  .almost_empty_out(),
		  .almost_full_out(),
		  .empty_out(),
		  .waddr_out(dst_waddr),
		  .raddr_out(dst_raddr),
		  .rallow_out(),
		  .wallow_out(),
		  .full_out(),
		  .half_full_out());
   tpram
     dst_ram (.clk_a(wb_clk_i),
	      .rst_a(wb_rst_i),
	      .ce_a(1'b1),
	      .we_a(!m_dst_putn),
	      .addr_a(dst_waddr),
	      .di_a(dst_di),
	      .do_a(),
	      .oe_a(1'b1),

	      .clk_b(wb_clk_i),
	      .rst_b(wb_rst_i),
	      .ce_b(1'b1),
	      .we_b(1'b0),
	      .oe_b(1'b1),
	      .addr_b(dst_raddr),
	      .do_b(dst_do),
	      .di_b());
   defparam 		 dst_control.ADDR_LENGTH = FIFO_WIDTH;   
   defparam 		 dst_ram.aw = FIFO_WIDTH;
   defparam 		 dst_ram.dw = DATA_WIDTH;

   /* DATA path */
   assign 		 
     src_di[63:0] = {wbs_dat64_o0, wbs_dat_o0};
   assign
     m_src = src_do[63:0];
   
   assign
     dst_di[63:0] = m_dst;
   assign 
     {wbs_dat64_i1, wbs_dat_i1} = dst_do[63:0];

   /* control path */
   
endmodule // ch
