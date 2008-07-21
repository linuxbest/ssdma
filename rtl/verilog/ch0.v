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
   ss_stop0, ss_stop1, ss_start0, ss_start1, ss_end0,
   ss_end1, wbs_dat_i0, wbs_dat_i1, wbs_dat64_i0,
   wbs_dat64_i1, m_src0, m_src_last0, m_src_almost_empty0,
   m_src_empty0, m_dst_almost_full0, m_dst_full0, ocnt0,
   // Inputs
   wb_clk_i, wb_rst_i, ss_xfer0, ss_xfer1, ss_last0,
   ss_last1, wbs_dat_o0, wbs_dat_o1, wbs_dat64_o0,
   wbs_dat64_o1, dc0, m_reset0, m_src_getn0, m_dst_putn0,
   m_dst0, m_dst_last0, m_endn0
   );
   input wb_clk_i;
   input wb_rst_i;
   
   input ss_xfer0,
	 ss_xfer1;
   input ss_last0,
	 ss_last1;
   output ss_stop0,
	  ss_stop1;
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
   input 	 m_reset0;
   
   input         m_src_getn0; 
   output [63:0] m_src0;      
   output        m_src_last0;
   output        m_src_almost_empty0;
   output 	 m_src_empty0;
   
   input         m_dst_putn0;
   input [63:0]  m_dst0;     
   input 	 m_dst_last0;
   output 	 m_dst_almost_full0;
   output        m_dst_full0;
   input 	 m_endn0;

   output [15:0] ocnt0;
   
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
   wire 		 src_almost_empty, 
			 src_empty,
			 src_half_full,
			 src_almost_full,
			 dst_half_full,
			 dst_empty,
			 dst_almost_empty;
   
   fifo_control
     src_control (.rclock_in(wb_clk_i),
		  .wclock_in(wb_clk_i),
		  .renable_in(!m_src_getn0),
		  .wenable_in(ss_xfer0),
		  .reset_in(wb_rst_i),
		  .clear_in(m_reset0),
		  .almost_empty_out(m_src_almost_empty0),
		  .almost_full_out(src_almost_full),
		  .empty_out(m_src_empty0),
		  .waddr_out(src_waddr),
		  .raddr_out(src_raddr),
		  .rallow_out(),
		  .wallow_out(),
		  .full_out(),
		  .half_full_out(src_half_full));

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
	      .di_b(0));
   defparam 		 src_control.ADDR_LENGTH = FIFO_WIDTH;   
   defparam 		 src_ram.aw = FIFO_WIDTH;
   defparam 		 src_ram.dw = DATA_WIDTH;

   fifo_control
     dst_control (.rclock_in(wb_clk_i),
		  .wclock_in(wb_clk_i),
		  .renable_in(ss_xfer1 && ~ss_end1),
		  .wenable_in(!m_dst_putn0),
		  .reset_in(wb_rst_i),
		  .clear_in(m_reset0),
		  .almost_empty_out(dst_almost_empty),
		  .almost_full_out(m_dst_almost_full0),
		  .empty_out(dst_empty),
		  .waddr_out(dst_waddr),
		  .raddr_out(dst_raddr),
		  .rallow_out(),
		  .wallow_out(),
		  .full_out(m_dst_full0),
		  .half_full_out(dst_half_full));
   tpram
     dst_ram (.clk_a(wb_clk_i),
	      .rst_a(wb_rst_i),
	      .ce_a(1'b1),
	      .we_a(!m_dst_putn0),
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
	      .di_b(0));
   defparam 		 dst_control.ADDR_LENGTH = FIFO_WIDTH;   
   defparam 		 dst_ram.aw = FIFO_WIDTH;
   defparam 		 dst_ram.dw = DATA_WIDTH;

   reg [15:0] 		 ocnt0;
   always @(posedge wb_clk_i)
     begin
	if (m_reset0)
	  ocnt0 <= #1 16'h0;
	else if (!m_dst_putn0 & !m_dst_last0)
	  ocnt0 <= #1 ocnt0 + 1'b1;
     end
   
   /* DATA path */
   assign 		 src_di[63:32]= wbs_dat64_o0;
   assign 		 src_di[31:00]= wbs_dat_o0;
   assign 		 src_di[71:64]= {ss_last0, 7'b0};
   
   assign 		 m_src0       = src_do[63:0];
   assign 		 m_src_last0  = src_do[71];
   
   assign 		 dst_di[63:0] = m_dst0;
   assign 		 dst_di[71:64]= {m_dst_last0, 7'b0};
   
   assign 		 wbs_dat64_i1 = dst_do[63:32];
   assign 		 wbs_dat_i1   = dst_do[31:00];

   /*
    * start: 表示可以启动读取或者写入
    * stop : 指示需要停止读取或者写入
    * end  : 指示该任务结束
    * 
    */
   assign 		 ss_stop0     = src_almost_full;
   assign 		 ss_stop1     = dst_almost_empty /*|| dst_empty*/;
   
   assign                ss_end0      = 1'b0;
   assign 		 ss_end1      = dst_do[71];

   assign 		 ss_start0    = !src_half_full;
   assign 		 ss_start1    = dst_half_full ||
					((!m_endn0) && (!dst_empty));
endmodule // ch
