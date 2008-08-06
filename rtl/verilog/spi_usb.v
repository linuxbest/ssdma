/************************************************************************
 *     File Name  : spi_usb.v
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
module spi_usb(/*AUTOARG*/
   // Outputs
   LED, FIFO_RD, spi_clk_i, spi_sel_i, spi_do_i, spi_di_i,
   // Inouts
   USB_D, USB_FWRn, SPI_SEL,
   // Inputs
   CLK24, USB_FRDn, USB_PC6, USB_PC7, spi_en, spi_clk_o,
   spi_sel_o, spi_do_en, spi_do_o, spi_di_en, spi_di_o
   );
   output 	LED;
   /* USB */
   output 	FIFO_RD;
   input 	CLK24,
		USB_FRDn,
		USB_PC6,
		USB_PC7;
   inout [7:0] 	USB_D;
   inout 	USB_FWRn;
   /* SPI */
   inout 	SPI_SEL;
   
   /*reg [23:0] cnt;
   always @(posedge CLK24)
     cnt <= #1 cnt + 1;
   assign     LED = cnt[20] & ~cnt[22];*/

   input      spi_en,
	      spi_clk_o,
	      spi_sel_o,
	      spi_do_en,
	      spi_do_o,
	      spi_di_en,
	      spi_di_o;
   output     spi_clk_i,
	      spi_sel_i,
	      spi_do_i,
	      spi_di_i;
   
   
   reg [7:0] USB_Data;
   
   assign 	USB_FWRn   = spi_en ? spi_clk_o : 1'bz;
   assign 	SPI_SEL    = spi_en ? spi_sel_o : 1'bz;
   assign 	spi_clk_i  = USB_FWRn;
   assign 	spi_sel_i  = SPI_SEL;
   assign 	USB_D[0]   = (spi_en ? spi_do_en : ~USB_FRDn) ?
			     (spi_en ? spi_do_o  : USB_Data[0]) : 1'bz;
   assign 	USB_D[2:1] = ~USB_FRDn ? USB_Data[2:1] : 2'hz;
   assign 	USB_D[3]   = (spi_en ? spi_di_en : ~USB_FRDn) ?
			     (spi_en ? spi_di_o  : USB_Data[3]) : 1'bz;
   assign 	USB_D[7:4] = ~USB_FRDn ? USB_Data[7:4] : 4'hz;
   assign 	spi_do_i   = USB_D[0];
   assign 	spi_di_i   = USB_D[3];
   
endmodule // spi_usb
