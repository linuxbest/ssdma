// spi_tri.v --- 
// 
// Filename: spi_tri.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: ËÄ  8ÔÂ 27 15:43:51 2009 (+0800)
// Version: 
// Last-Updated: 
//           By: 
//     Update #: 0
// URL: 
// Keywords: 
// Compatibility: 
// 
// 

// Commentary: 
// 
// 
// 
// 

// Change log:
// 
// 
// 

// Copyright (C) 2008,2009 Beijing Soul tech.
// -------------------------------------
// Naming Conventions:
// 	active low signals                 : "*_n"
// 	clock signals                      : "clk", "clk_div#", "clk_#x"
// 	reset signals                      : "rst", "rst_n"
// 	generics                           : "C_*"
// 	user defined types                 : "*_TYPE"
// 	state machine next state           : "*_ns"
// 	state machine current state        : "*_cs"
// 	combinatorial signals              : "*_com"
// 	pipelined or register delay signals: "*_d#"
// 	counter signals                    : "*cnt*"
// 	clock enable signals               : "*_ce"
// 	internal version of output port    : "*_i"
// 	device pins                        : "*_pin"
// 	ports                              : - Names begin with Uppercase
// Code:

module spi_tri (/*AUTOARG*/
   // Outputs
   spi_in_reg,
   // Inouts
   spi_dat_pin, spi_cmd_pin, spi_sel_pin, spi_clk_pin,
   // Inputs
   spi_out_reg, spi_en_reg
   );

   inout 	spi_dat_pin;
   inout 	spi_cmd_pin;
   inout 	spi_sel_pin;
   inout 	spi_clk_pin;
   
   input [7:0] spi_out_reg;
   input [7:0] spi_en_reg;
   output [7:0] spi_in_reg;
   
   assign spi_clk_pin = spi_en_reg[0] ? spi_out_reg[0] : 1'bz;
   assign spi_sel_pin = spi_en_reg[1] ? spi_out_reg[1] : 1'bz;
   assign spi_cmd_pin = spi_en_reg[2] ? spi_out_reg[2] : 1'bz;
   assign spi_dat_pin = spi_en_reg[3] ? spi_out_reg[3] : 1'bz;
   assign spi_in_reg[0] = spi_clk_pin;
   assign spi_in_reg[1] = spi_sel_pin;
   assign spi_in_reg[2] = spi_cmd_pin;
   assign spi_in_reg[3] = spi_dat_pin;

endmodule
// 
// spi_tri.v ends here
