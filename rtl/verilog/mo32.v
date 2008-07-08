module mo32(/*AUTOARG*/
   // Outputs
   O,
   // Inputs
   gnt, I0, I1, I2, I3, I4
   );
   input [4:0] gnt;
   input [31:0] I0,
	       I1, 
	       I2,
	       I3,
	       I4;
   output [31:0] O;
   
   assign O = gnt[4] ? I4 :
	      gnt[3] ? I3 :
	      gnt[2] ? I2 :
	      gnt[1] ? I1 :
	      gnt[0] ? I0 : 32'hz;
   
endmodule // mixer0
