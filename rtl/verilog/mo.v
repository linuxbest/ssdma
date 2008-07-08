module mo(/*AUTOARG*/
   // Outputs
   O,
   // Inputs
   gnt, I
   );
   input [4:0] gnt;
   input [4:0] I;
   output      O;

   assign O = gnt[4] ? I[4] :
	      gnt[3] ? I[3] :
	      gnt[2] ? I[2] :
	      gnt[1] ? I[1] :
	      gnt[0] ? I[0] : 1'bz;
   
endmodule // mixer0
