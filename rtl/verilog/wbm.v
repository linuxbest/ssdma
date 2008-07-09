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

endmodule // wbm
