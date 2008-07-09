module mo32(/*AUTOARG*/
   // Outputs
   O,
   // Inputs
   gnt, I0, I1, I2, I3, I4, wb_clk_i, wb_rst_i
   );
   input [4:0] gnt;
   input [31:0] I0,
	       I1, 
	       I2,
	       I3,
	       I4;
   output [31:0] O;

   input wb_clk_i;
   input wb_rst_i;
   reg [4:0]   gnt_r;
   always @(posedge wb_clk_i)
     gnt_r <= #1 gnt;
   
   assign O = gnt_r[4] ? I4 :
	      gnt_r[3] ? I3 :
	      gnt_r[2] ? I2 :
	      gnt_r[1] ? I1 :
	      gnt_r[0] ? I0 : 32'hz;
   
endmodule // mixer0
