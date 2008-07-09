/************************************************************************
 *     File Name  : gnt.v
 *        Version : 0.1
 *           Date :
 *    Description : accept command from ss_adma
 *                  doing sg memory access 
 *  
 *   Dependencies : ss_adma.v
 *
 *        Company : Beijing Soul Tech.
 *
 *   Copyright (C) 2008 Beijing Soul tech.
 *
 *
 ***********************************************************************/

module gnt(/*AUTOARG*/
   // Outputs
   gnt,
   // Inputs
   wb_clk_i, wb_rst_i, wbs_cyc0, wbs_cyc1, wbs_cyc2,
   wbs_cyc3, wbs_cyc4
   );
   input wb_clk_i,
	 wb_rst_i;
   
   input wbs_cyc0,
	 wbs_cyc1,
	 wbs_cyc2,
	 wbs_cyc3,
	 wbs_cyc4;
   output [4:0] gnt;

endmodule // gnt
