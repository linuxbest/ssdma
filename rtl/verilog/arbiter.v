/************************************************************************
 *     File Name  : arbiter.v
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

module arbiter(/*AUTOARG*/
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

   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [4:0]		gnt;
   // End of automatics

   parameter [4:0] 
		grant0 = 5'b00001,
		grant1 = 5'b00010,
		grant2 = 5'b00100,
		grant3 = 5'b01000,
		grant4 = 5'b10000;

   reg [4:0] 		gnt_n;

   always @(posedge wb_clk_i or posedge wb_rst_i)
     begin
	if (wb_rst_i)
	  gnt <= #1 grant0;
	else
	  gnt <= #1 gnt_n;
     end

   always @(/*AS*/gnt or wbs_cyc0 or wbs_cyc1 or wbs_cyc2
	    or wbs_cyc3 or wbs_cyc4)
     begin
	gnt_n = gnt;
	case (1)
	  gnt[0]: begin
	     if (!wbs_cyc0) begin
		if (wbs_cyc1)       gnt_n = grant1;
		else if (wbs_cyc2)  gnt_n = grant2;
		else if (wbs_cyc3)  gnt_n = grant3;
		else if (wbs_cyc4)  gnt_n = grant4;
	     end
	  end
	  
	  gnt[1]: begin
	     if (!wbs_cyc1) begin
		if (wbs_cyc2)       gnt_n = grant2;
		else if (wbs_cyc3)  gnt_n = grant3;
		else if (wbs_cyc4)  gnt_n = grant4;
		else if (wbs_cyc0)  gnt_n = grant0;
	     end
	  end
	  
	  gnt[2]: begin
	     if (!wbs_cyc2) begin
		if (wbs_cyc3)       gnt_n = grant3;
		else if (wbs_cyc4)  gnt_n = grant4;
		else if (wbs_cyc0)  gnt_n = grant0;
		else if (wbs_cyc1)  gnt_n = grant1;
	     end
	  end
	  
	  gnt[3]: begin
	     if (!wbs_cyc3) begin
		if (wbs_cyc4)       gnt_n = grant4;
		else if (wbs_cyc0)  gnt_n = grant0;
		else if (wbs_cyc1)  gnt_n = grant1;
		else if (wbs_cyc2)  gnt_n = grant2;
	     end
	  end
	  
	  gnt[4]: begin
	     if (!wbs_cyc4) begin
		if (wbs_cyc0)       gnt_n = grant0;
		else if (wbs_cyc1)  gnt_n = grant1;
		else if (wbs_cyc2)  gnt_n = grant2;
		else if (wbs_cyc3)  gnt_n = grant3;
	     end
	  end
	  
	endcase // case(gnt)
     end // always @ (...
   
endmodule // gnt
