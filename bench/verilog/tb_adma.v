/************************************************************************
 *     File Name  : tb_adma.v
 *        Version :
 *           Date :
 *    Description : test bench for ss_adma.v
 *   Dependencies : ss_adma.v
 *
 *        Company : Beijing Soul Tech.
 *
 *   Copyright (C) 2008 Beijing Soul tech.
 *
 *
 ***********************************************************************/
`timescale 1ns/1ns

module tb_adma(/*AUTOARG*/
   // Outputs
   ctrl_state
   );
   /*AUTOINPUT*/
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [7:0]		ctrl_state;		// From adma of ss_adma.v
   // End of automatics
   /*AUTOREG*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			spi_clk_i;		// From spi of dummy_spi.v
   wire			spi_clk_o;		// From adma of ss_adma.v
   wire			spi_di_en;		// From adma of ss_adma.v
   wire			spi_di_i;		// From spi of dummy_spi.v
   wire			spi_di_o;		// From adma of ss_adma.v
   wire			spi_do_en;		// From adma of ss_adma.v
   wire			spi_do_i;		// From spi of dummy_spi.v
   wire			spi_do_o;		// From adma of ss_adma.v
   wire			spi_en;			// From adma of ss_adma.v
   wire			spi_sel_i;		// From spi of dummy_spi.v
   wire			spi_sel_o;		// From adma of ss_adma.v
   wire			wb_clk_i;		// From badma of ben_adma.v
   wire			wb_int_o;		// From adma of ss_adma.v
   wire			wb_rst_i;		// From badma of ben_adma.v
   wire			wbm_ack_i;		// From badma of ben_adma.v
   wire [31:0]		wbm_adr_o;		// From adma of ss_adma.v
   wire			wbm_cab_o;		// From adma of ss_adma.v
   wire			wbm_cyc_o;		// From adma of ss_adma.v
   wire [31:0]		wbm_dat64_i;		// From badma of ben_adma.v
   wire [31:0]		wbm_dat64_o;		// From adma of ss_adma.v
   wire [31:0]		wbm_dat_i;		// From badma of ben_adma.v
   wire [31:0]		wbm_dat_o;		// From adma of ss_adma.v
   wire			wbm_err_i;		// From badma of ben_adma.v
   wire			wbm_rty_i;		// From badma of ben_adma.v
   wire [3:0]		wbm_sel_o;		// From adma of ss_adma.v
   wire			wbm_stb_o;		// From adma of ss_adma.v
   wire			wbm_we_o;		// From adma of ss_adma.v
   wire			wbs_ack_o;		// From adma of ss_adma.v
   wire [31:0]		wbs_adr_i;		// From badma of ben_adma.v
   wire			wbs_cab_i;		// From badma of ben_adma.v
   wire			wbs_cyc_i;		// From badma of ben_adma.v
   wire [31:0]		wbs_dat_i;		// From badma of ben_adma.v
   wire [31:0]		wbs_dat_o;		// From adma of ss_adma.v
   wire			wbs_err_o;		// From adma of ss_adma.v
   wire			wbs_rty_o;		// From adma of ss_adma.v
   wire [3:0]		wbs_sel_i;		// From badma of ben_adma.v
   wire			wbs_stb_i;		// From badma of ben_adma.v
   wire			wbs_we_i;		// From badma of ben_adma.v
   // End of automatics

   ss_adma adma(/*AUTOINST*/
		// Outputs
		.ctrl_state		(ctrl_state[7:0]),
		.spi_clk_o		(spi_clk_o),
		.spi_di_en		(spi_di_en),
		.spi_di_o		(spi_di_o),
		.spi_do_en		(spi_do_en),
		.spi_do_o		(spi_do_o),
		.spi_en			(spi_en),
		.spi_sel_o		(spi_sel_o),
		.wbm_adr_o		(wbm_adr_o[31:0]),
		.wbm_cab_o		(wbm_cab_o),
		.wbm_cyc_o		(wbm_cyc_o),
		.wbm_dat64_o		(wbm_dat64_o[31:0]),
		.wbm_dat_o		(wbm_dat_o[31:0]),
		.wbm_sel_o		(wbm_sel_o[3:0]),
		.wbm_stb_o		(wbm_stb_o),
		.wbm_we_o		(wbm_we_o),
		.wbs_ack_o		(wbs_ack_o),
		.wbs_dat_o		(wbs_dat_o[31:0]),
		.wbs_err_o		(wbs_err_o),
		.wbs_rty_o		(wbs_rty_o),
		.wb_int_o		(wb_int_o),
		// Inputs
		.spi_clk_i		(spi_clk_i),
		.spi_di_i		(spi_di_i),
		.spi_do_i		(spi_do_i),
		.spi_sel_i		(spi_sel_i),
		.wb_clk_i		(wb_clk_i),
		.wb_rst_i		(wb_rst_i),
		.wbm_ack_i		(wbm_ack_i),
		.wbm_dat64_i		(wbm_dat64_i[31:0]),
		.wbm_dat_i		(wbm_dat_i[31:0]),
		.wbm_err_i		(wbm_err_i),
		.wbm_rty_i		(wbm_rty_i),
		.wbs_adr_i		(wbs_adr_i[31:0]),
		.wbs_cab_i		(wbs_cab_i),
		.wbs_cyc_i		(wbs_cyc_i),
		.wbs_dat_i		(wbs_dat_i[31:0]),
		.wbs_sel_i		(wbs_sel_i[3:0]),
		.wbs_stb_i		(wbs_stb_i),
		.wbs_we_i		(wbs_we_i));

   dummy_spi spi(/*AUTOINST*/
		 // Outputs
		 .spi_clk_i		(spi_clk_i),
		 .spi_di_i		(spi_di_i),
		 .spi_do_i		(spi_do_i),
		 .spi_sel_i		(spi_sel_i),
		 // Inputs
		 .spi_clk_o		(spi_clk_o),
		 .spi_di_en		(spi_di_en),
		 .spi_do_en		(spi_do_en),
		 .spi_do_o		(spi_do_o),
		 .spi_en		(spi_en),
		 .spi_sel_o		(spi_sel_o),
		 .spi_di_o		(spi_di_o));
   
   ben_adma badma(/*AUTOINST*/
		  // Outputs
		  .wb_clk_i		(wb_clk_i),
		  .wb_rst_i		(wb_rst_i),
		  .wbs_dat_i		(wbs_dat_i[31:0]),
		  .wbs_adr_i		(wbs_adr_i[31:0]),
		  .wbs_we_i		(wbs_we_i),
		  .wbs_stb_i		(wbs_stb_i),
		  .wbs_cyc_i		(wbs_cyc_i),
		  .wbs_cab_i		(wbs_cab_i),
		  .wbs_sel_i		(wbs_sel_i[3:0]),
		  .wbm_err_i		(wbm_err_i),
		  .wbm_ack_i		(wbm_ack_i),
		  .wbm_rty_i		(wbm_rty_i),
		  .wbm_dat_i		(wbm_dat_i[31:0]),
		  .wbm_dat64_i		(wbm_dat64_i[31:0]),
		  // Inputs
		  .wb_int_o		(wb_int_o),
		  .wbs_rty_o		(wbs_rty_o),
		  .wbs_err_o		(wbs_err_o),
		  .wbs_ack_o		(wbs_ack_o),
		  .wbs_dat_o		(wbs_dat_o[31:0]),
		  .wbm_we_o		(wbm_we_o),
		  .wbm_stb_o		(wbm_stb_o),
		  .wbm_cyc_o		(wbm_cyc_o),
		  .wbm_cab_o		(wbm_cab_o),
		  .wbm_dat_o		(wbm_dat_o[31:0]),
		  .wbm_dat64_o		(wbm_dat64_o[31:0]),
		  .wbm_adr_o		(wbm_adr_o[31:0]),
		  .wbm_sel_o		(wbm_sel_o[3:0]));
   
endmodule // tb_adma

// Local Variables:
// verilog-library-directories:("../../rtl/verilog/" ".")
// verilog-library-files:("")
// verilog-library-extensions:(".v" ".h")
// End: