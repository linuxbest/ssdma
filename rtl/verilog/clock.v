/************************************************************************
 *     File Name  : clock.v
 *        Version :
 *           Date : 
 *    Description : 
 *   Dependencies :
 *
 *        Company : Beijing Soul Tech.
 *
 *   Copyright (C) 2008 Beijing Soul tech.
 *
 *
 ***********************************************************************/
module clock (/*AUTOARG*/
   // Outputs
   wb_clk_i, wb_rst_i,
   // Inputs
   PCI_CLK, PCI_RSTn
   );
   input PCI_CLK,
	 PCI_RSTn;

   output wb_clk_i;
   output wb_rst_i;

   wire   clk_locked;
   // Tie DCM to output of first division
   DCM Vid_DCM (
		.CLKIN     (PCI_CLK), // insert clock input
		.CLKFB     (),    // insert clock feedback
		.DSSEN     (1'b0),// Spread spectrum enable input
		.PSINCDEC  (1'b0),// Phase shifting - increment/decrement input
		.PSEN      (1'b0),// Phase shifting - enable input
		.PSCLK     (1'b0),// Phase shifting - clock input
		.RST       (~PCI_RSTn),// DCM reset input
		.CLK0      (), // clock output
		.CLK90     (), // clock output
		.CLK180    (), // clock output
		.CLK270    (), // clock output
		.CLK2X     (), // clock output
		.CLK2X180  (), // clock output
		.CLKDV     (), // clock output
		.CLKFX     (wb_clk_i),   // clock output
		.CLKFX180  (), // clock output
		.LOCKED    (clk_locked), // Locked signal
		.PSDONE    (), // Phase shifting done output
		.STATUS    ()  // Status bus output
		);
   
   defparam Vid_DCM.DLL_FREQUENCY_MODE = "HIGH";
   defparam Vid_DCM.DUTY_CYCLE_CORRECTION = "TRUE";
   defparam Vid_DCM.STARTUP_WAIT = "FALSE";
   defparam Vid_DCM.CLKFX_DIVIDE   = 4;
   defparam Vid_DCM.CLKFX_MULTIPLY = 8;
   defparam Vid_DCM.CLK_FEEDBACK = "NONE";

   reg [15:0] rst_sync_r;
   always @(posedge PCI_CLK)
     begin
	if (~clk_locked) begin
	   rst_sync_r <= #1 16'hffff;
	end else begin
	   rst_sync_r <= #1 rst_sync_r << 1;
	end
     end
   assign wb_rst_i = rst_sync_r[15];
endmodule // clock
