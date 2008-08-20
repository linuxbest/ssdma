/******************************************************************************
 *
 *           File Name : history_mem.v
 *             Version : 0.1
 *                Date : Feb 20, 2008
 *         Description : LZS decode algorithm top module
 *        Dependencies :
 *
 *             Company : Beijing Soul
 *              Author : Hu Gang
 *
 *****************************************************************************/
module history_mem (/*AUTOARG*/
   // Outputs
   ce_hdata, de_hdata,
   // Inputs
   wb_clk_i, wb_rst_i, dc, ce_hraddr, ce_hwaddr, ce_hwe,
   ce_data, de_hraddr, de_hwaddr, de_hwe, de_data
   );
   input wb_clk_i,
	 wb_rst_i;
   input [23:0] dc;

   input [10:0] ce_hraddr, ce_hwaddr;
   input 	ce_hwe;
   input [7:0] 	ce_data;
   output [7:0] ce_hdata;
   
   input [10:0] de_hraddr, de_hwaddr;
   input 	de_hwe;
   input [7:0] 	de_data;
   output [7:0] de_hdata;
   
   wire 	hwe;
   wire [7:0] 	data_in;
   wire [7:0] 	hdata_out, hdata;
   wire [10:0] 	raddr, waddr;
   
   assign 	hwe      = dc[5] ? ce_hwe   : de_hwe;
   assign 	data_in  = dc[5] ? ce_data  : de_data;
   assign 	raddr    = dc[5] ? ce_hraddr: de_hraddr;
   assign 	waddr    = dc[5] ? ce_hwaddr: de_hwaddr;
   assign 	hdata_out= raddr == waddr ? data_in : hdata;
   assign 	ce_hdata = hdata_out;
   assign 	de_hdata = hdata_out;
   
   generic_tpram mem (.clk_a(wb_clk_i),
		      .rst_a(wb_rst_i),
		      .ce_a(1'b1),
		      .we_a(hwe),
		      .oe_a(1'b0),
		      .addr_a(waddr),
		      .di_a(data_in),
		      .do_a(),
		      
		      .clk_b(wb_clk_i),
		      .rst_b(wb_rst_i),
		      .ce_b(1'b1),
		      .we_b(1'b0),
		      .oe_b(1'b1),
		      .addr_b(raddr),
		      .di_b(),
		      .do_b(hdata));
   
   defparam 	mem.aw = 11;
   defparam 	mem.dw = 8;
   
endmodule // history_mem
