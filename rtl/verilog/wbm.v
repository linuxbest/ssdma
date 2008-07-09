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
   spi_di_en,
   // Inputs
   wb_clk_i, wb_rst_i, sg_state0, sg_state1, sg_state2,
   sg_state3, sg_desc0, sg_desc1, sg_desc2, sg_desc3,
   sg_addr0, sg_addr1, sg_addr2, sg_addr3, sg_next0,
   sg_next1, sg_next2, sg_next3, wbs_sel_i, wbs_cyc_i,
   wbs_stb_i, wbs_we_i, wbs_cab_i, wbs_adr_i, wbs_dat_i,
   spi_sel_i, spi_di_i, spi_do_i, spi_clk_i
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

   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg			spi_clk_o;
   reg			spi_di_en;
   reg			spi_di_o;
   reg			spi_do_en;
   reg			spi_do_o;
   reg			spi_en;
   reg			spi_sel_o;
   reg			wbs_ack_o;
   reg [31:0]		wbs_dat_o;
   reg			wbs_err_o;
   // End of automatics
   
   reg 			valid_access;
   always @(posedge wb_clk_i or posedge wb_rst_i)
     if (wb_rst_i) begin
	wbs_ack_o <= #1 1'b0;
	wbs_err_o <= #1 1'b0;
     end else if (valid_access) begin
	wbs_ack_o <= #1 1'b1;
	wbs_err_o <= #1 1'b0;
     end else if (wbs_cyc_i & wbs_stb_i) begin
	wbs_ack_o <= #1 1'b0;
	wbs_err_o <= #1 1'b1;
     end else begin
	wbs_ack_o <= #1 1'b0;
	wbs_err_o <= #1 1'b0;
     end // else: !if(wbs_cyc_i & wbs_stb_i)

   /* valid access */
   always @(/*AS*/wbs_cyc_i or wbs_sel_i or wbs_stb_i)
     begin
	if (wbs_cyc_i && wbs_stb_i && wbs_sel_i == 4'b1111)
	  valid_access = 1;
	else
	  valid_access = 0;
     end
   
   /* rty */
   assign 	   wbs_rty_o = 1'b0;

   wire [4:0] 	   adr = wbs_adr_i[6:2];

   always @(/*AS*/sg_addr0 or sg_addr1 or sg_addr2
	    or sg_addr3 or sg_desc0 or sg_desc1 or sg_desc2
	    or sg_desc3 or sg_next0 or sg_next1 or sg_next2
	    or sg_next3 or sg_state0 or sg_state1
	    or sg_state2 or sg_state3 or wbs_adr_i)
     begin
	case (wbs_adr_i[6:2])
	  5'h0: wbs_dat_o = 0/* CCR */; 
	  5'h1: wbs_dat_o = 1/* CSR */;
	  5'h2: wbs_dat_o = 2/* DAR */;
	  5'h3: wbs_dat_o = 3/* NDAR*/;

	  5'h4: wbs_dat_o = sg_state0;
	  5'h5: wbs_dat_o = sg_desc0;
	  5'h6: wbs_dat_o = sg_addr0;
	  5'h7: wbs_dat_o = sg_next0;

	  5'h8: wbs_dat_o = sg_state1;
	  5'h9: wbs_dat_o = sg_desc1;
	  5'ha: wbs_dat_o = sg_addr1;
	  5'hb: wbs_dat_o = sg_next1;

	  5'hc: wbs_dat_o = sg_state2;
	  5'hd: wbs_dat_o = sg_desc2;
	  5'he: wbs_dat_o = sg_addr2;
	  5'hf: wbs_dat_o = sg_next2;

	  5'h10: wbs_dat_o = sg_state3;
	  5'h11: wbs_dat_o = sg_desc3;
	  5'h12: wbs_dat_o = sg_addr3;
	  5'h13: wbs_dat_o = sg_next3;
	  /*14-1f*/
	  default:wbs_dat_o = 32'h0;
	endcase
     end
   
endmodule // wbm
