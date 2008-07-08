/************************************************************************
 *     File Name  : ben_sgr.v
 *        Version :
 *           Date :
 *    Description : test bench for ss_sgr.v
 *   Dependencies : ss_sgr.v
 *
 *        Company : Beijing Soul Tech.
 *
 *   Copyright (C) 2008 Beijing Soul tech.
 *
 *
 ***********************************************************************/
module ben_sgr(/*AUTOARG*/
   // Outputs
   wb_clk_i, wb_rst_i, wbs_dat_o, wbs_dat64_o, wbs_rty,
   wbs_err, wbs_ack, ss_ready, ss_we, ss_done, ss_adr,
   ss_dat,
   // Inputs
   wbs_we, wbs_stb, wbs_cyc, wbs_cab, wbs_sel, wbs_dat_i,
   wbs_dat64_i, wbs_adr, sg_state, ss_xfer, sg_addr,
   sg_desc, sg_next
   );
   /*AUTOINPUT*/
   /*AUTOOUTPUT*/
   input wbs_we,
	 wbs_stb,
	 wbs_cyc,
	 wbs_cab;

   /* input */
   input [3:0] wbs_sel;
   input [31:0] wbs_dat_i,
		wbs_dat64_i;
   input [31:0] wbs_adr;

   input [7:0] 	sg_state;
   input 	ss_xfer;
   input [31:3] sg_addr;
   input [15:0] sg_desc;
   input [31:3] sg_next;

   /* output */
   output 	wb_clk_i,
		wb_rst_i;
		
   output [31:0] wbs_dat_o,
		 wbs_dat64_o;
   output 	 wbs_rty,
		 wbs_err,
		 wbs_ack;
   output 	 ss_ready,
		 ss_we,
		 ss_done;
   output [1:0]  ss_adr;
   output [31:0] ss_dat;

   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [1:0]		ss_adr;
   reg [31:0]		ss_dat;
   reg			ss_done;
   reg			ss_ready;
   reg			ss_we;
   reg			wb_clk_i;
   reg			wb_rst_i;
   reg			wbs_ack;
   reg [31:0]		wbs_dat64_o;
   reg [31:0]		wbs_dat_o;
   reg			wbs_err;
   reg			wbs_rty;
   // End of automatics
   
   always #7.5   wb_clk_i = !wb_clk_i; // 66MHz

   // doing reset
   task do_reset ;
      begin
	 @(negedge wb_clk_i);
	 @(negedge wb_clk_i);
	 wb_rst_i = 1;
	 @(negedge wb_clk_i);
	 @(negedge wb_clk_i);
	 @(negedge wb_clk_i);
	 wb_rst_i = 0;
	 @(negedge wb_clk_i);
	 @(negedge wb_clk_i);
      end
   endtask // do_reset

   // prepare a job
   task pre_job ;
      begin
      end
   endtask // pre_job

   reg [31:0] wbmL[4095:0];
   reg [31:0] wbmH[4095:0];
   reg [31:0] inc;
   always @(/*AS*/ /*memory or*/ inc or wbs_adr)
     begin
	wbs_dat_o   = wbmL[wbs_adr+inc];
	wbs_dat64_o = wbmH[wbs_adr+inc];
     end
   
   always @(/*AS*/wbs_adr or wbs_cyc)
     begin
	if (wbs_adr[8] && wbs_cyc)      /* 0x100 */
	  wbs_ack = 1;
	else if (wbs_adr[9] && wbs_cyc) /* 0x200 */
	  wbs_ack = 1;
	else if (wbs_adr[10] && wbs_cyc)/* 0x400 */
	  wbs_ack = 1;
	else
	  wbs_ack = 0;
     end

   // auto increase
   always @(posedge wb_clk_i)
     begin
	if (wbs_cyc == 0)
	  inc = 0;
	else if (wbs_cyc && wbs_ack && wbs_cab)
	  inc = inc + 1;
     end
   
   integer i = 0;
   // ssadma
   task do_ssadma ;
      begin
	 /* 0 [15:00] total size
	      [20]    LAST
	    1 [31:03] address
	    2 [31:03] next
	    3 
	  */
	 i = 'h100;
	 wbmH[i] = 'h10; /* total size */
	 wbmL[i] = 'h200;/* address    */
	 i = i + 1;
	 wbmH[i] = 'h400;/* next       */
	 wbmL[i] = 'h0;
	 i = 'h400;
	 wbmH[i] = 'h100010;  /* total size */
	 wbmL[i] = 'h200;
	 
	 ss_adr = 0;
	 ss_dat = 0;
	 ss_we  = 1;
	 @(negedge wb_clk_i); // 00
	 ss_adr = 1;
	 ss_dat = 0;
	 ss_we  = 1;
	 @(negedge wb_clk_i); // 01 dc and fc
	 ss_adr = 2;
	 ss_dat = 32'h100;
	 ss_we  = 1;
	 @(negedge wb_clk_i); // 10 address
	 ss_adr = 3;
	 ss_dat = 0;
	 ss_we  = 1;
	 @(negedge wb_clk_i); // 11
      end
   endtask // do_ssadma

   initial begin
      wb_clk_i = 1;
      wb_rst_i = 0;
      wbs_err  = 0;
      wbs_rty  = 0;
      inc      = 0;
      
      pre_job;
      do_reset;
      do_ssadma;
      
      @(negedge wb_clk_i);
      @(negedge wb_clk_i);
      ss_ready = 1;

      for (i = 0; i < 50; i = i + 1) begin
	 @(negedge wb_clk_i);
      end
      ss_done = 1;
      @(negedge wb_clk_i);
      @(negedge wb_clk_i);
      
      $finish;
   end
   
endmodule // ben_sgr
