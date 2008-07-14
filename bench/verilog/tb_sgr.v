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

module tb_sgr(/*AUTOARG*/
   // Outputs
   ss_last, c_done,
   // Inputs
   wbs_dat_i, wbs_dat64_i, ss_stop, ss_end, ss_dc, rw
   );
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		rw;			// To sgr of ss_sg.v
   input [23:0]		ss_dc;			// To sgr of ss_sg.v
   input		ss_end;			// To sgr of ss_sg.v
   input		ss_stop;		// To sgr of ss_sg.v
   input [31:0]		wbs_dat64_i;		// To ben of ben_sgr.v
   input [31:0]		wbs_dat_i;		// To ben of ben_sgr.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output		c_done;			// From sgr of ss_sg.v
   output		ss_last;		// From sgr of ss_sg.v
   // End of automatics
   
   /*AUTOREG*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [31:3]		sg_addr;		// From sgr of ss_sg.v
   wire [15:0]		sg_desc;		// From sgr of ss_sg.v
   wire [31:3]		sg_next;		// From sgr of ss_sg.v
   wire [7:0]		sg_state;		// From sgr of ss_sg.v
   wire [1:0]		ss_adr;			// From ben of ben_sgr.v
   wire [31:0]		ss_dat;			// From ben of ben_sgr.v
   wire			ss_done;		// From ben of ben_sgr.v
   wire			ss_start;		// From ben of ben_sgr.v
   wire			ss_we;			// From ben of ben_sgr.v
   wire			ss_xfer;		// From sgr of ss_sg.v
   wire			wb_clk_i;		// From ben of ben_sgr.v
   wire			wb_rst_i;		// From ben of ben_sgr.v
   wire			wbs_ack;		// From ben of ben_sgr.v
   wire [31:0]		wbs_adr;		// From sgr of ss_sg.v
   wire			wbs_cab;		// From sgr of ss_sg.v
   wire			wbs_cyc;		// From sgr of ss_sg.v
   wire [31:0]		wbs_dat64_o;		// From ben of ben_sgr.v
   wire [31:0]		wbs_dat_o;		// From ben of ben_sgr.v
   wire			wbs_err;		// From ben of ben_sgr.v
   wire			wbs_rty;		// From ben of ben_sgr.v
   wire [3:0]		wbs_sel;		// From sgr of ss_sg.v
   wire			wbs_stb;		// From sgr of ss_sg.v
   wire			wbs_we;			// From sgr of ss_sg.v
   // End of automatics
   
   ss_sg  sgr(/*AUTOINST*/
	      // Outputs
	      .wbs_cyc			(wbs_cyc),
	      .wbs_stb			(wbs_stb),
	      .wbs_we			(wbs_we),
	      .wbs_cab			(wbs_cab),
	      .wbs_sel			(wbs_sel[3:0]),
	      .wbs_adr			(wbs_adr[31:0]),
	      .sg_state			(sg_state[7:0]),
	      .sg_desc			(sg_desc[15:0]),
	      .sg_addr			(sg_addr[31:3]),
	      .sg_next			(sg_next[31:3]),
	      .ss_xfer			(ss_xfer),
	      .ss_last			(ss_last),
	      .c_done			(c_done),
	      // Inputs
	      .wb_clk_i			(wb_clk_i),
	      .wb_rst_i			(wb_rst_i),
	      .rw			(rw),
	      .wbs_dat_o		(wbs_dat_o[31:0]),
	      .wbs_dat64_o		(wbs_dat64_o[31:0]),
	      .wbs_ack			(wbs_ack),
	      .wbs_err			(wbs_err),
	      .wbs_rty			(wbs_rty),
	      .ss_dat			(ss_dat[31:0]),
	      .ss_we			(ss_we),
	      .ss_adr			(ss_adr[1:0]),
	      .ss_done			(ss_done),
	      .ss_dc			(ss_dc[23:0]),
	      .ss_start			(ss_start),
	      .ss_end			(ss_end),
	      .ss_stop			(ss_stop));

   ben_sgr ben(/*AUTOINST*/
	       // Outputs
	       .wb_clk_i		(wb_clk_i),
	       .wb_rst_i		(wb_rst_i),
	       .wbs_dat_o		(wbs_dat_o[31:0]),
	       .wbs_dat64_o		(wbs_dat64_o[31:0]),
	       .wbs_rty			(wbs_rty),
	       .wbs_err			(wbs_err),
	       .wbs_ack			(wbs_ack),
	       .ss_start		(ss_start),
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
