module mi(/*AUTOARG*/
   // Outputs
   O,
   // Inputs
   I, gnt
   );
   input I;
   input [4:0] gnt;
   output [4:0] O;

   input 	wb_clk_i;
   input 	wb_rst_i;
   reg [4:0] 	gnt_r;
   always @(posedge wb_clk_i)
     gnt_r <= #1 gnt;

   assign 	O[4] = gnt_r[4] ? I : 1'b0;
   assign 	O[3] = gnt_r[3] ? I : 1'b0;
   assign 	O[2] = gnt_r[2] ? I : 1'b0;
   assign 	O[1] = gnt_r[1] ? I : 1'b0;
   assign 	O[0] = gnt_r[0] ? I : 1'b0;
   
endmodule // mi
