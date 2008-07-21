/************************************************************************
 *     File Name  : ch1.v
 *        Version :
 *           Date : 
 *    Description : copy from ch0.v
 *   Dependencies : 
 *
 *        Company : Beijing Soul Tech.
 *
 *   Copyright (C) 2008 Beijing Soul tech.
 *
 *
 ***********************************************************************/
module ch1(/*AUTOARG*/
   // Outputs
   ss_stop2, ss_stop3, ss_start2, ss_start3, ss_end2,
   ss_end3, wbs_dat_i2, wbs_dat_i3, wbs_dat64_i2,
   wbs_dat64_i3, m_src1, m_src_last1, m_src_almost_empty1,
   m_src_empty1, m_dst_almost_full1, m_dst_full1, ocnt1,
   // Inputs
   wb_clk_i, wb_rst_i, ss_xfer2, ss_xfer3, ss_last2,
   ss_last3, wbs_dat_o2, wbs_dat_o3, wbs_dat64_o2,
   wbs_dat64_o3, dc1, m_reset1, m_src_getn1, m_dst_putn1,
   m_dst1, m_dst_last1, m_endn1
   );
   input wb_clk_i;
   input wb_rst_i;
   
   input ss_xfer2,
	 ss_xfer3;
   input ss_last2,
	 ss_last3;
   output ss_stop2,
	  ss_stop3;
   output ss_start2,
	  ss_start3,
	  ss_end2,
	  ss_end3;
   input [31:0] wbs_dat_o2,
		wbs_dat_o3,
		wbs_dat64_o2,
		wbs_dat64_o3;
   output [31:0] wbs_dat_i2, 
		 wbs_dat_i3,
		 wbs_dat64_i2,
		 wbs_dat64_i3;
   input [23:0]  dc1;

   /* module interface */
   input 	 m_reset1;
   
   input         m_src_getn1; 
   output [63:0] m_src1;      
   output        m_src_last1;
   output        m_src_almost_empty1;
   output 	 m_src_empty1;
   
   input         m_dst_putn1;
   input [63:0]  m_dst1;     
   input 	 m_dst_last1;
   output 	 m_dst_almost_full1;
   output        m_dst_full1;
   input 	 m_endn1;

   output [15:0] ocnt1;
   
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
		  .renable_in(!m_src_getn1),
		  .wenable_in(ss_xfer2),
		  .reset_in(wb_rst_i),
		  .clear_in(m_reset1),
		  .almost_empty_out(m_src_almost_empty1),
		  .almost_full_out(src_almost_full),
		  .empty_out(m_src_empty1),
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
	      .we_a(ss_xfer2),
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
		  .renable_in(ss_xfer3 && ~ss_end3),
		  .wenable_in(!m_dst_putn1),
		  .reset_in(wb_rst_i),
		  .clear_in(m_reset1),
		  .almost_empty_out(dst_almost_empty),
		  .almost_full_out(m_dst_almost_full1),
		  .empty_out(dst_empty),
		  .waddr_out(dst_waddr),
		  .raddr_out(dst_raddr),
		  .rallow_out(),
		  .wallow_out(),
		  .full_out(m_dst_full1),
		  .half_full_out(dst_half_full));
   tpram
     dst_ram (.clk_a(wb_clk_i),
	      .rst_a(wb_rst_i),
	      .ce_a(1'b1),
	      .we_a(!m_dst_putn1),
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
   
   reg [15:0] 		 ocnt1;
   always @(posedge wb_clk_i)
     begin
	if (m_reset1)
	  ocnt1 <= #1 16'h0;
	else if (!m_dst_putn1 && !m_dst_last1)
	  ocnt1 <= #1 ocnt1 + 1'b1;
     end

   defparam 		 dst_control.ADDR_LENGTH = FIFO_WIDTH;   
   defparam 		 dst_ram.aw = FIFO_WIDTH;
   defparam 		 dst_ram.dw = DATA_WIDTH;

   /* DATA path */
   assign 		 src_di[63:32]= wbs_dat64_o2;
   assign 		 src_di[31:00]= wbs_dat_o2;
   assign 		 src_di[71:64]= {ss_last2, 7'b0};
   
   assign 		 m_src1       = src_do[63:0];
   assign 		 m_src_last1  = src_do[71];
   
   assign 		 dst_di[63:0] = m_dst1;
   assign 		 dst_di[71:64]= {m_dst_last1, 7'b0};
   
   assign 		 wbs_dat64_i3 = dst_do[63:32];
   assign 		 wbs_dat_i3   = dst_do[31:00];

   /*
    * start: 表示可以启动读取或者写入
    * stop : 指示需要停止读取或者写入
    * end  : 指示该任务结束
    * 
    */
   assign 		 ss_stop2     = src_almost_full;
   assign 		 ss_stop3     = dst_almost_empty /*|| dst_empty*/;
   
   assign                ss_end2      = 1'b0;
   assign 		 ss_end3      = dst_do[71];

   assign 		 ss_start2    = !src_half_full;
   assign 		 ss_start3    = dst_half_full ||
					((!m_endn1) && (!dst_empty));
endmodule // ch
