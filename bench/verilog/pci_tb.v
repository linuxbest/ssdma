`timescale 1ns / 1ps

module main;

   // Signals of the PCI BUS
   wire reset;
   tri1 frame, irdy, trdy, stop, devsel, par;
   wire [31:0] ad;
   wire [3:0]  c_be;
   /*wire*/tri1 [3:0]  req;
   wire [3:0]  gnt;
   tri0 [15:0] irq;

   wire [31:0] ad64;
   wire [3:0]  c_be64;
   tri1        req64;
   tri1        ack64;
   tri1        par64;

   /* 66MHZ */
   reg 	       clk = 1;
   always #7.5 clk = !clk;

   // This is the system arbiter.
   pci_arbiter arb(clk, reset, frame, irdy, req, gnt);
   
   // This is the device that talks to the host operating system.
   pci_master cpu(.CLK(clk), .RESET(reset),
		  .FRAME(frame), .IRDY(irdy), .TRDY(trdy),
		  .STOP(stop), .DEVSEL(devsel),
		  .AD(ad), .C_BE(c_be), .PAR(par),
		  .REQ(req[0] ), .GNT(gnt[0]),
		  .nIRQ(irq), .PAR64(par64), .AD64(ad64), .C_BE64(c_be64),
                  .ACK64(ack64));

   // Need a memory device to act as a target.
   pci_memory #(.BAR0_MASK(32'hf0000000), .RETRY_RATE(0), .DISCON_RATE(0)) 
     mem1 (.CLK(clk), .RESET(reset),
	   .FRAME(frame), .IRDY(irdy), .TRDY(trdy),
	   .STOP(stop), .DEVSEL(devsel), .IDSEL(ad[17]),
	   .AD(ad), .C_BE(c_be), .PAR(par), .PAR64(par64),
	   .AD64(ad64), .C_BE64(c_be64), 
	   .REQ64(req64),
	   .ACK64(ack64)
	   );

   wire [7:0] usb_d;
   wire usb_fwrn;
   wire spi_sel;
   top //#(.PCI_MEM_ADDRESS(19'h7d0), .PCI_MEM_ENABLE(1))
     top (.PCI_CLK(clk), .PCI_RSTn(reset),
	  .PCI_FRAMEn(frame), .PCI_IRDYn(irdy), .PCI_TRDYn(trdy),
	  .PCI_STOPn(stop), .PCI_DEVSELn(devsel), .PCI_IDSEL(ad[18]),
	  .PCI_AD(ad), .PCI_CBE(c_be), .PCI_PAR(par),
	  .PCI_REQn(req[1]), .PCI_GNTn(gnt[1]), .PCI_ACK64n(ack64),
	  .PCI_AD64(ad64), .PCI_CBE64(c_be64),
	  .PCI_REQ64n(req64), .PCI_PAR64(par64),
          .USB_D(usb_d), .USB_FWRn(usb_fwrn),
          .SPI_SEL(spi_sel), .USB_FRDn(1) ,.PCI_INTAn(irq[0]));

   assign usb_d = 0;
   assign usb_fwrn = 0;
   assign spi_sel = 0;
   initial begin
      $dumpfile("pci.vcd");
      $dumpvars(0, top);
   end
   reg vcd = 0;
   /*always @(posedge clk) begin
     if (top.adma.enable && vcd == 0) begin
      $dumpvars(0, top);
      vcd = 1;
     end
   end*/
endmodule
