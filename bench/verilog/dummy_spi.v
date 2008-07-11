/************************************************************************
 *     File Name  : dummy_spi.v
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
module dummy_spi(/*AUTOARG*/
   // Outputs
   spi_clk_i, spi_di_i, spi_do_i, spi_sel_i,
   // Inputs
   spi_clk_o, spi_di_en, spi_do_en, spi_do_o, spi_en,
   spi_sel_o, spi_di_o
   );
   output spi_clk_i,
	  spi_di_i,
	  spi_do_i,
	  spi_sel_i;
   input  spi_clk_o,
	  spi_di_en,
	  spi_do_en,
	  spi_do_o,
	  spi_en,
	  spi_sel_o,
	  spi_di_o;
   
endmodule // dummy_spi

     