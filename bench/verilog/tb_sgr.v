/************************************************************************
 *     File Name  : tb_sgr.v
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
`timescale 1ns/1ns

module tb_sgr(/*AUTOARG*/);
   /*AUTOINPUT*/
   /*AUTOOUTPUT*/
   
   /*AUTOREG*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [31:3]		sg_addr;		// From sgr of ss_sgr.v
   wire [15:0]		sg_desc;		// From sgr of ss_sgr.v
   wire [31:3]		sg_next;		// From sgr of ss_sgr.v
   wire [7:0]		sg_state;		// From sgr of ss_sgr.v
   wire [1:0]		ss_adr;			// From ben of ben_sgr.v
   wire [31:0]		ss_dat;			// From ben of ben_sgr.v
   wire			ss_done;		// From ben of ben_sgr.v
   wire			ss_ready;		// From ben of ben_sgr.v
   wire			ss_we;			// From ben of ben_sgr.v
   wire			ss_xfer;		// From sgr of ss_sgr.v
   wire			wb_clk_i;		// From ben of ben_sgr.v
   wire			wb_rst_i;		// From ben of ben_sgr.v
   wire			wbs_ack;		// From ben of ben_sgr.v
   wire [31:0]		wbs_adr;		// From sgr of ss_sgr.v
   wire			wbs_cab;		// From sgr of ss_sgr.v
   wire			wbs_cyc;		// From sgr of ss_sgr.v
   wire [31:0]		wbs_dat64_i;		// From sgr of ss_sgr.v
   wire [31:0]		wbs_dat64_o;		// From ben of ben_sgr.v
   wire [31:0]		wbs_dat_i;		// From sgr of ss_sgr.v
   wire [31:0]		wbs_dat_o;		// From ben of ben_sgr.v
   wire			wbs_err;		// From ben of ben_sgr.v
   wire			wbs_rty;		// From ben of ben_sgr.v
   wire [3:0]		wbs_sel;		// From sgr of ss_sgr.v
   wire			wbs_stb;		// From sgr of ss_sgr.v
   wire			wbs_we;			// From sgr of ss_sgr.v
   // End of automatics
   
   ss_sgr sgr(/*AUTOINST*/
	      // Outputs
	      .wbs_cyc			(wbs_cyc),
	      .wbs_stb			(wbs_stb),
	      .wbs_we			(wbs_we),
	      .wbs_cab			(wbs_cab),
	      .wbs_sel			(wbs_sel[3:0]),
	      .wbs_adr			(wbs_adr[31:0]),
	      .wbs_dat_i		(wbs_dat_i[31:0]),
	      .wbs_dat64_i		(wbs_dat64_i[31:0]),
	      .sg_state			(sg_state[7:0]),
	      .sg_desc			(sg_desc[15:0]),
	      .sg_addr			(sg_addr[31:3]),
	      .sg_next			(sg_next[31:3]),
	      .ss_xfer			(ss_xfer),
	      // Inputs
	      .wb_clk_i			(wb_clk_i),
	      .wb_rst_i			(wb_rst_i),
	      .wbs_dat_o		(wbs_dat_o[31:0]),
	      .wbs_dat64_o		(wbs_dat64_o[31:0]),
	      .wbs_ack			(wbs_ack),
	      .wbs_err			(wbs_err),
	      .wbs_rty			(wbs_rty),
	      .ss_dat			(ss_dat[31:0]),
	      .ss_we			(ss_we),
	      .ss_adr			(ss_adr[1:0]),
	      .ss_done			(ss_done),
	      .ss_ready			(ss_ready));

   ben_sgr ben(/*AUTOINST*/
	       // Outputs
	       .wb_clk_i		(wb_clk_i),
	       .wb_rst_i		(wb_rst_i),
	       .wbs_dat_o		(wbs_dat_o[31:0]),
	       .wbs_dat64_o		(wbs_dat64_o[31:0]),
	       .wbs_rty			(wbs_rty),
	       .wbs_err			(wbs_err),
	       .wbs_ack			(wbs_ack),
	       .ss_ready		(ss_ready),
	       .ss_we			(ss_we),
	       .ss_done			(ss_done),
	       .ss_adr			(ss_adr[1:0]),
	       .ss_dat			(ss_dat[31:0]),
	       // Inputs
	       .wbs_we			(wbs_we),
	       .wbs_stb			(wbs_stb),
	       .wbs_cyc			(wbs_cyc),
	       .wbs_cab			(wbs_cab),
	       .wbs_sel			(wbs_sel[3:0]),
	       .wbs_dat_i		(wbs_dat_i[31:0]),
	       .wbs_dat64_i		(wbs_dat64_i[31:0]),
	       .wbs_adr			(wbs_adr[31:0]),
	       .sg_state		(sg_state[7:0]),
	       .ss_xfer			(ss_xfer),
	       .sg_addr			(sg_addr[31:3]),
	       .sg_desc			(sg_desc[15:0]),
	       .sg_next			(sg_next[31:3]));

   initial begin
      $dumpfile("tb_sgr.vcd");
      $dumpvars(0, sgr);
   end
endmodule // tb_sgr

// Local Variables:
// verilog-library-directories:("../../rtl/verilog/" ".")
// verilog-library-files:("")
// verilog-library-extensions:(".v" ".h")
// End: