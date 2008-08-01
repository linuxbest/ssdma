/************************************************************************
 *     File Name  : mod.v
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
module codeout (/*AUTOARG*/
   // Outputs
   m_dst, m_dst_putn, m_dst_last, m_endn,
   // Inputs
   wb_clk_i, wb_rst_i, dc, en_out_data, de_out_data,
   en_out_valid, de_out_valid, en_out_done, de_out_done
   );
   input wb_clk_i, 
	 wb_rst_i;
   input [23:0] dc;

   input [15:0] en_out_data,  de_out_data;
   input 	en_out_valid, de_out_valid;
   input 	en_out_done,  de_out_done;

   output [63:0] m_dst;
   output 	 m_dst_putn;
   output 	 m_dst_last;
   output 	 m_endn;
   
endmodule // codeout

     