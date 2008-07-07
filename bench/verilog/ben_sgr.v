/************************************************************************
 *     File Name  : ben_sgr.v
 *        Version :
 *           Date :
 *    Description : test bench for ss_sgr.v
 *   Dependencies : ss_sgr.v
 *
 *        Company : Beijing Soul Tech.
 *
 *   Copyright (C) 2008 Beijing Soul tech.
 *
 *
 ***********************************************************************/
module ben_sgr(/*AUTOARG*/
   // Outputs
   wb_clk_i, wb_rst_i, wbs_dat_o, wbs_dat64_o, wbs_rty,
   wbs_err, wbs_ack, ss_ready, ss_we, ss_done, ss_adr,
   ss_dat,
   // Inputs
   wbs_we, wbs_stb, wbs_cyc, wbs_cab, wbs_sel, wbs_dat_i,
   wbs_dat64_i, wbs_adr, sg_state, ss_xfer, sg_addr,
   sg_desc, sg_next
   );
   /*AUTOINPUT*/
   /*AUTOOUTPUT*/
   input wbs_we,
	 wbs_stb,
	 wbs_cyc,
	 wbs_cab;

   /* input */
   input [3:0] wbs_sel;
   input [31:0] wbs_dat_i,
		wbs_dat64_i;
   input [31:0] wbs_adr;

   input [7:0] 	sg_state;
   input 	ss_xfer;
   input [31:3] sg_addr;
   input [15:0] sg_desc;
   input [31:3] sg_next;

   /* output */
   output 	wb_clk_i,
		wb_rst_i;
		
   output [31:0] wbs_dat_o,
		 wbs_dat64_o;
   output 	 wbs_rty,
		 wbs_err,
		 wbs_ack;
   output 	 ss_ready,
		 ss_we,
		 ss_done;
   output [1:0]  ss_adr;
   output [31:0] ss_dat;

   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [1:0]		ss_adr;
   reg [31:0]		ss_dat;
   reg			ss_done;
   reg			ss_ready;
   reg			ss_we;
   reg			wb_clk_i;
   reg			wb_rst_i;
   reg			wbs_ack;
   reg [31:0]		wbs_dat64_o;
   reg [31:0]		wbs_dat_o;
   reg			wbs_err;
   reg			wbs_rty;
   // End of automatics
   
   always #7.5   wb_clk_i = !wb_clk_i; // 66MHz

   // doing reset
   task do_reset ;
      begin
	 @(negedge wb_clk_i);
	 @(negedge wb_clk_i);
	 wb_rst_i = 1;
	 @(negedge wb_clk_i);
	 @(negedge wb_clk_i);
	 @(negedge wb_clk_i);
	 wb_rst_i = 0;
	 @(negedge wb_clk_i);
	 @(negedge wb_clk_i);
      end
   endtask // do_reset
   
   initial begin
      wb_clk_i = 1;
      wb_rst_i = 0;
      do_reset;
      $finish;
   end
   
endmodule // ben_sgr
