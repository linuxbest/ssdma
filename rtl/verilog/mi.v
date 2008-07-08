module mi(/*AUTOARG*/
   // Outputs
   O,
   // Inputs
   I, gnt
   );
   input I;
   input [4:0] gnt;
   output [4:0] O;

   assign 	O[4] = gnt[4] ? I : 1'b0;
   assign 	O[3] = gnt[3] ? I : 1'b0;
   assign 	O[2] = gnt[2] ? I : 1'b0;
   assign 	O[1] = gnt[1] ? I : 1'b0;
   assign 	O[0] = gnt[0] ? I : 1'b0;
   
endmodule // mi
