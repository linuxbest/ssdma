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
module ch(/*AUTOARG*/
   // Outputs
   src_stop, dst_stop, src_start, dst_start, src_end,
   dst_end, src_dat_i, dst_dat_i, src_dat64_i, dst_dat64_i,
   m_src, m_src_last, m_src_almost_empty, m_src_empty,
   m_dst_almost_full, m_dst_full, ocnt,
   // Inputs
   wb_clk_i, wb_rst_i, src_xfer, dst_xfer, src_last,
   dst_last, src_dat_o, dst_dat_o, src_dat64_o, dst_dat64_o,
   dc, m_reset, m_src_getn, m_dst_putn, m_dst, m_dst_last,
   m_endn
   );
   input wb_clk_i;
   input wb_rst_i;
   
   input src_xfer,
	 dst_xfer;
   input src_last,
	 dst_last;
   output src_stop,
	  dst_stop;
   output src_start,
	  dst_start,
	  src_end,
	  dst_end;
   input [31:0] src_dat_o,
		dst_dat_o,
		src_dat64_o,
		dst_dat64_o;
   output [31:0] src_dat_i, 
		 dst_dat_i,
		 src_dat64_i,
		 dst_dat64_i;
   input [23:0]  dc;

   /* module interface */
   input 	 m_reset;
   
   input         m_src_getn; 
   output [63:0] m_src;      
   output        m_src_last;
   output        m_src_almost_empty;
   output 	 m_src_empty;
   
   input         m_dst_putn;
   input [63:0]  m_dst;     
   input 	 m_dst_last;
   output 	 m_dst_almost_full;
   output        m_dst_full;
   input 	 m_endn;

   output [15:0] ocnt;
   
   parameter 	 FIFO_WIDTH = 8;
   wire [FIFO_WIDTH-1:0] src_waddr,
			 src_raddr,
			 dst_waddr,
			 dst_raddr;
   
   parameter 		 DATA_WIDTH = 65;
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

   wire 		 src_rallow,
			 src_wallow,
			 dst_rallow,
			 dst_wallow;
   
   fifo_control
     src_control (.rclock_in(wb_clk_i),
		  .wclock_in(wb_clk_i),
		  .renable_in(!m_src_getn),
		  .wenable_in(src_xfer),
		  .reset_in(wb_rst_i),
		  .clear_in(m_reset),
		  .almost_empty_out(m_src_almost_empty),
		  .almost_full_out(src_almost_full),
		  .empty_out(m_src_empty),
		  .waddr_out(src_waddr),
		  .raddr_out(src_raddr),
		  .rallow_out(src_rallow),
		  .wallow_out(src_wallow),
		  .full_out(),
		  .half_full_out(src_half_full));

   fifo_control
     dst_control (.rclock_in(wb_clk_i),
		  .wclock_in(wb_clk_i),
		  .renable_in(dst_xfer && ~dst_end),
		  .wenable_in(!m_dst_putn),
		  .reset_in(wb_rst_i),
		  .clear_in(m_reset),
		  .almost_empty_out(dst_almost_empty),
		  .almost_full_out(m_dst_almost_full),
		  .empty_out(dst_empty),
		  .waddr_out(dst_waddr),
		  .raddr_out(dst_raddr),
		  .rallow_out(dst_rallow),
		  .wallow_out(dst_wallow),
		  .full_out(m_dst_full),
		  .half_full_out(dst_half_full));
   
   tpram
     src_ram (.clk_a(wb_clk_i),
	      .rst_a(wb_rst_i),
	      .ce_a(1'b1),
	      .oe_a(1'b1),
	      .we_a(src_wallow),
	      .addr_a(src_waddr),
	      .di_a(src_di),
	      .do_a(),

	      .clk_b(wb_clk_i),
	      .rst_b(wb_rst_i),
	      .ce_b(1'b1),
	      .oe_b(1'b1),
	      .we_b(1'b0),
	      .addr_b(src_raddr),
              .di_b(),
	      .do_b(src_do));
   tpram
     dst_ram (.clk_a(wb_clk_i),
	      .rst_a(wb_rst_i),
	      .ce_a(1'b1),
	      .oe_a(1'b1),
	      .we_a(dst_wallow),
	      .addr_a(dst_waddr),
	      .di_a(dst_di),
	      .do_a(),

	      .clk_b(wb_clk_i),
	      .rst_b(wb_rst_i),
	      .ce_b(1'b1),
	      .oe_b(1'b1),
	      .we_b(1'b0),
	      .addr_b(dst_raddr),
              .di_b(),
	      .do_b(dst_do));
   defparam 		 dst_control.ADDR_LENGTH = FIFO_WIDTH;
   defparam 		 src_control.ADDR_LENGTH = FIFO_WIDTH;   
   defparam 		 src_ram.aw = FIFO_WIDTH;
   defparam 		 src_ram.dw = DATA_WIDTH;
   defparam 		 dst_ram.aw = FIFO_WIDTH;
   defparam 		 dst_ram.dw = DATA_WIDTH;
   
   reg [15:0] 		 ocnt;
   always @(posedge wb_clk_i)
     begin
	if (m_reset)
	  ocnt <= #1 16'h0;
	else if (!m_dst_putn & !m_dst_last)
	  ocnt <= #1 ocnt + 1'b1;
     end
   
   /* DATA path */
   assign 		 src_di[63:32]= src_dat64_o;
   assign 		 src_di[31:00]= src_dat_o;
   assign 		 src_di[64]   = src_last;
   
   assign 		 m_src       = src_do[63:0];
   assign 		 m_src_last  = src_do[64];
   
   assign 		 dst_di[63:0] = m_dst;
   assign 		 dst_di[64]   = m_dst_last;
   
   assign 		 dst_dat64_i = dst_do[63:32];
   assign 		 dst_dat_i   = dst_do[31:00];

   /*
    * start: ��ʾ����������ȡ����д��
    * stop : ָʾ��Ҫֹͣ��ȡ����д��
    * end  : ָʾ���������
    * 
    */
   assign 		 src_stop     = src_almost_full;
   assign 		 dst_stop     = dst_almost_empty /*|| dst_empty*/;
   
   assign                src_end      = 1'b0;
   assign 		 dst_end      = dst_do[64];

   assign 		 src_start    = !src_half_full;
   assign 		 dst_start    = dst_half_full ||
					((!m_endn) && (!dst_empty));
endmodule // ch
