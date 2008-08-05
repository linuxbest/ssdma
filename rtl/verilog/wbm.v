/************************************************************************
 *     File Name  : wbm.v
 *        Version :
 *           Date : 
 *    Description : 
 *   Dependencies :
 *
 *        Company : Beijing Soul Tech.
 *
 *   Copyright (C) 2008 Beijing Soul tech.
 *
 *         TODO   : 实现 spi 接口。
 *
 ***********************************************************************/
module wbm(/*AUTOARG*/
   // Outputs
   wbs_dat_o, wbs_ack_o, wbs_err_o, wbs_rty_o, spi_sel_o,
   spi_di_o, spi_do_o, spi_clk_o, spi_en, spi_do_en,
   spi_di_en, ndar_dirty, ndar, append, enable,
   wb_int_clear,
   // Inputs
   wb_clk_i, wb_rst_i, sg_state0, sg_state1, sg_state2,
   sg_state3, sg_desc0, sg_desc1, sg_desc2, sg_desc3,
   sg_addr0, sg_addr1, sg_addr2, sg_addr3, sg_next0,
   sg_next1, sg_next2, sg_next3, wbs_sel_i, wbs_cyc_i,
   wbs_stb_i, wbs_we_i, wbs_cab_i, wbs_adr_i, wbs_dat_i,
   spi_sel_i, spi_di_i, spi_do_i, spi_clk_i, dar, csr,
   ndar_dirty_clear, append_clear, wb_int_o, busy, ctl_adr0,
   ctl_adr1, next_desc, ctrl_state, dc0, dc1, m_enable0,
   m_enable1, m_src_last0, m_src_last1, m_src_almost_empty0,
   m_src_almost_empty1, m_src_empty0, m_src_empty1,
   m_dst_last0, m_dst_last1, m_dst_almost_full0,
   m_dst_almost_full1, m_dst_full0, m_dst_full1, m_endn0,
   m_endn1
   );
   
   input wb_clk_i,
	 wb_rst_i;
   
   input [7:0] sg_state0,
	       sg_state1,
	       sg_state2,
	       sg_state3;
   input [15:0] sg_desc0,
		sg_desc1,
		sg_desc2,
		sg_desc3;
   input [31:3] sg_addr0,
		sg_addr1,
		sg_addr2,
		sg_addr3;
   input [31:3] sg_next0,
		sg_next1,
		sg_next2,
		sg_next3;

   /* wb slave interface */
   input [3:0] 	 wbs_sel_i;
   input 	 wbs_cyc_i,
		 wbs_stb_i,
		 wbs_we_i,
		 wbs_cab_i;
   input [31:0]  wbs_adr_i,
		 wbs_dat_i;
   output [31:0] wbs_dat_o;
   output 	 wbs_ack_o,
		 wbs_err_o,
		 wbs_rty_o;

   /* SPI */
   input 	 spi_sel_i,
		 spi_di_i,
		 spi_do_i,
		 spi_clk_i;
   output 	 spi_sel_o,
		 spi_di_o,
		 spi_do_o,
		 spi_clk_o,
		 spi_en,
		 spi_do_en,
		 spi_di_en;

   /* from dma */
   input [31:0]  dar;
   input [7:0] 	 csr;
   input 	 ndar_dirty_clear,
		 append_clear,
		 wb_int_o,
		 busy;
   
   output 	 ndar_dirty;
   output [31:3] ndar;
   output 	 append, enable, wb_int_clear;

   input [31:3] ctl_adr0,
		ctl_adr1,
		next_desc;
   input [7:0] 	ctrl_state;

   input [23:0] dc0, dc1;

   input 	m_enable0, m_enable1;
   input 	m_src_last0, m_src_last1;
   input 	m_src_almost_empty0, m_src_almost_empty1;
   input 	m_src_empty0, m_src_empty1;

   input 	m_dst_last0, m_dst_last1;
   input 	m_dst_almost_full0, m_dst_almost_full1;
   input 	m_dst_full0, m_dst_full1;
   input 	m_endn0, m_endn1;
   
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg			append;
   reg			enable;
   reg [31:3]		ndar;
   reg			ndar_dirty;
   reg			wb_int_clear;
   reg			wbs_ack_o;
   reg [31:0]		wbs_dat_o;
   reg			wbs_err_o;
   // End of automatics

   reg 			valid_access;
   /* valid access */
   always @(/*AS*/wbs_adr_i)
     begin
	if (wbs_adr_i[10]) 
	  valid_access = 1;
	else
	  valid_access = 0;
     end
   
   /* rty */
   assign 	   wbs_rty_o = 1'b0;

   wire [4:0] 	   adr = wbs_adr_i[6:2];

   reg [7:0] 	   m_status0, m_status1;
   reg [7:0] 	   m_src0, m_src1;
   reg [7:0] 	   m_dst0, m_dst1;
   always @(/*AS*/m_enable0 or m_endn0)
     m_status0 = {m_enable0, m_endn0};
   always @(/*AS*/m_src_almost_empty0 or m_src_empty0
	    or m_src_last0)
     m_src0 = {m_src_last0, m_src_almost_empty0, m_src_empty0};
   always @(/*AS*/m_dst_almost_full0 or m_dst_full0
	    or m_dst_last0)
     m_dst0 = {m_dst_last0, m_dst_almost_full0, m_dst_full0};
   
   always @(/*AS*/m_enable1 or m_endn1)
     m_status1 = {m_enable1, m_endn1};
   always @(/*AS*/m_src_almost_empty1 or m_src_empty1
	    or m_src_last1)
     m_src1 = {m_src_last1, m_src_almost_empty1, m_src_empty1};
   always @(/*AS*/m_dst_almost_full1 or m_dst_full1
	    or m_dst_last1)
     m_dst1 = {m_dst_last1, m_dst_almost_full1, m_dst_full1};

   reg [7:0] 	   spi_i;
   always @(/*AS*/spi_clk_i or spi_di_en or spi_di_i
	    or spi_do_en or spi_do_i or spi_en or spi_sel_i)
     spi_i = {spi_en, spi_di_en, spi_do_en,
	      spi_sel_i, spi_di_i,  spi_do_i, spi_clk_i};
   
   reg [7:0] 	   spi_reg;
   assign 	   
     {spi_en,    spi_di_en, spi_do_en,
      spi_sel_o, spi_di_o,  spi_do_o, spi_clk_o} = spi_reg;
   
   always @(/*AS*/append or busy or ctl_adr0 or ctl_adr1
	    or dar or dc0 or dc1 or enable or m_dst0
	    or m_dst1 or m_src0 or m_src1 or m_status0
	    or m_status1 or ndar or next_desc or sg_addr0
	    or sg_addr1 or sg_addr2 or sg_addr3 or sg_desc0
	    or sg_desc1 or sg_desc2 or sg_desc3 or sg_next0
	    or sg_next1 or sg_next2 or sg_next3 or sg_state0
	    or sg_state1 or sg_state2 or sg_state3 or spi_i
	    or wb_int_o or wbs_adr_i)
     begin
	wbs_dat_o = 32'h0;
	case (wbs_adr_i[6:2])
	  5'h0: wbs_dat_o = {enable, append};
	  5'h1: wbs_dat_o = {busy, wb_int_o};
	  5'h2: wbs_dat_o = dar;
	  5'h3: wbs_dat_o = {ndar, 3'b000};

	  5'h4: wbs_dat_o = sg_state0;
	  5'h5: wbs_dat_o = sg_desc0;
	  5'h6: wbs_dat_o = {sg_addr0, 3'b000};
	  5'h7: wbs_dat_o = {sg_next0, 3'b000};

	  5'h8: wbs_dat_o = sg_state1;
	  5'h9: wbs_dat_o = sg_desc1;
	  5'ha: wbs_dat_o = {sg_addr1, 3'b000};
	  5'hb: wbs_dat_o = {sg_next1, 3'b000};

	  5'hc: wbs_dat_o = sg_state2;
	  5'hd: wbs_dat_o = sg_desc2;
	  5'he: wbs_dat_o = {sg_addr2, 3'b000};
	  5'hf: wbs_dat_o = {sg_next2, 3'b000};

	  5'h10: wbs_dat_o = sg_state3;
	  5'h11: wbs_dat_o = sg_desc3;
	  5'h12: wbs_dat_o = {sg_addr3, 3'b000};
	  5'h13: wbs_dat_o = {sg_next3, 3'b000};

	  5'h14: wbs_dat_o = {ctl_adr0, 3'b000};
	  5'h15: wbs_dat_o = {ctl_adr1, 3'b000};
	  5'h16: wbs_dat_o = {next_desc,3'b000};
	  5'h17: ;
	  
	  5'h18: wbs_dat_o = dc0;
	  5'h19: wbs_dat_o = dc1;
	  5'h1a: ;
	  5'h1b: ;
	  
	  5'h1c: wbs_dat_o = {m_status0, m_src0, m_dst0};
	  5'h1d: wbs_dat_o = {m_status1, m_src1, m_dst1};
	  5'h1e: ;
          5'h1f: wbs_dat_o = {spi_i, 16'haa55};
	endcase
     end

   /* ndar write */
   reg ndar_we;
   always @(posedge wb_clk_i or posedge wb_rst_i)
     begin
	if (wb_rst_i)
	  ndar_dirty <= #1 0;
	else if (ndar_we)
	  ndar_dirty <= #1 1;
	else if (ndar_dirty_clear)
	  ndar_dirty <= #1 0;
     end
   always @(posedge wb_clk_i)
     begin
	if (ndar_we)
	  ndar <= #1 wbs_dat_i[31:3];
     end

   /* ccr write */
   reg ccr_we;
   always @(posedge wb_clk_i or posedge wb_rst_i)
     begin
	if (wb_rst_i) begin
	   enable <= #1 1'b0;
	end else if (ccr_we) begin
	   enable <= #1 wbs_dat_i[1];
	end
     end
   always @(posedge wb_clk_i or posedge wb_rst_i)
     begin
	if (wb_rst_i) begin
	   wb_int_clear <= #1 0;
	end else if (ccr_we) begin
	   wb_int_clear <= #1 wbs_dat_i[2];
	end else begin
	   wb_int_clear <= #1 0;
	end
     end
   always @(posedge wb_clk_i or posedge wb_rst_i)
     begin
	if (wb_rst_i) begin
	   append <= #1 0;
	end else if (ccr_we) begin
	   append <= #1 wbs_dat_i[0];
	end else if (append_clear) begin
	   append <= #1 0;
	end
     end
   
   /* ndar_we and ccr_we */
   always @(/*AS*/enable or valid_access or wbs_adr_i
	    or wbs_we_i)
     begin
	ndar_we = 0;
	ccr_we  = 0;
	
	if (wbs_we_i && valid_access) begin
	   case (wbs_adr_i[3:2])
	     2'b00: ccr_we = 1;
	     2'b01:;
	     2'b10:;
	     2'b11: ndar_we = !enable;/* to write NDAR must disable enable */
	   endcase // case(wbs_adr_i[3:2])
	end
     end // always @ (...

   always @(posedge wb_clk_i or posedge wb_rst_i)
     begin
	if (wb_rst_i)
	  spi_reg <= #1 8'h0;
	else if (wbs_adr_i[10] && (&wbs_adr_i[6:2]))
	  spi_reg <= #1 wbs_dat_i[23:16];
     end
   
endmodule // wbm
