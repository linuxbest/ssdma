/************************************************************************
 *     File Name  : ben_adma.v
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
module ben_adma(/*AUTOARG*/
   // Outputs
   wb_clk_i, wb_rst_i, wbs_dat_i, wbs_adr_i, wbs_we_i,
   wbs_stb_i, wbs_cyc_i, wbs_cab_i, wbs_sel_i, wbm_err_i,
   wbm_ack_i, wbm_rty_i, wbm_dat_i, wbm_dat64_i,
   // Inputs
   wb_int_o, wbs_rty_o, wbs_err_o, wbs_ack_o, wbs_dat_o,
   wbm_we_o, wbm_stb_o, wbm_cyc_o, wbm_cab_o, wbm_dat_o,
   wbm_dat64_o, wbm_adr_o, wbm_sel_o
   );
   /* system */
   output wb_clk_i;
   output wb_rst_i;
   input  wb_int_o;
   
   /* WBS */
   input wbs_rty_o,
	 wbs_err_o,
	 wbs_ack_o;
   input [31:0] wbs_dat_o;
   output [31:0] wbs_dat_i,
		 wbs_adr_i;
   output wbs_we_i,
	  wbs_stb_i,
	  wbs_cyc_i,
	  wbs_cab_i;
   output [3:0] wbs_sel_i;

   /* WBM */
   input wbm_we_o,
	 wbm_stb_o,
	 wbm_cyc_o,
	 wbm_cab_o;
   input [31:0] wbm_dat_o,
		wbm_dat64_o,
		wbm_adr_o;
   input [3:0] 	wbm_sel_o;
   output wbm_err_i,
	  wbm_ack_i,
	  wbm_rty_i;
   output [31:0] wbm_dat_i,
		 wbm_dat64_i;
   
endmodule // ben_adma
