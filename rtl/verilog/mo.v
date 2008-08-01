/************************************************************************
 *     File Name  : mo.v
 *        Version :
 *           Date : 
 *    Description : 
 *   Dependencies :
 *
 *        Company : Beijing Soul Tech.
 *
 *   Copyright (C) 2008 Beijing Soul tech.
 *
 ***********************************************************************/
module mo(/*AUTOARG*/
   // Outputs
   O,
   // Inputs
   gnt, I, wb_clk_i, wb_rst_i
   );
   input [4:0] gnt;
   input [4:0] I;
   output      O;
   
   input wb_clk_i;
   input wb_rst_i;
   reg [4:0]   gnt_r;
   always @(posedge wb_clk_i)
     gnt_r <= #1 gnt;
   
   assign O = gnt_r[4] ? I[4] :
	      gnt_r[3] ? I[3] :
	      gnt_r[2] ? I[2] :
	      gnt_r[1] ? I[1] :
	      /*gnt_r[0] ?*/ I[0] /*: 1'bz*/;
   
endmodule // mixer0
