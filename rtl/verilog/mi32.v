module mi32(/*AUTOARG*/
   // Outputs
   O0, O1, O2, O3, O4,
   // Inputs
   I, gnt
   );
   input [31:0] I;
   input [4:0] gnt;
   output [31:0] O0,
		 O1,
		 O2,
		 O3,
		 O4;

   /*assign 	O4 = gnt[4] ? I : 32'hz;
   assign 	O3 = gnt[3] ? I : 32'hz;
   assign 	O2 = gnt[2] ? I : 32'hz;
   assign 	O1 = gnt[1] ? I : 32'hz;
   assign 	O0 = gnt[0] ? I : 32'hz;*/
   assign 	O0 = I;
   assign 	O1 = I;
   assign 	O2 = I;
   assign 	O3 = I;
   assign 	O4 = I;
   
endmodule // mi
