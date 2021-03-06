/************************************************************************
 *     File Name  : ben_adma.v
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
module ben_adma(/*AUTOARG*/
   // Outputs
   wb_clk_i, wb_rst_i, wbs_dat_i, wbs_adr_i, wbs_we_i,
   wbs_stb_i, wbs_cyc_i, wbs_cab_i, wbs_sel_i, wbm_err_i,
   wbm_ack_i, wbm_rty_i, wbm_dat_i, wbm_dat64_i,
   // Inputs
   wb_int_o, wbs_rty_o, wbs_err_o, wbs_ack_o, wbs_dat_o,
   wbm_we_o, wbm_stb_o, wbm_cyc_o, wbm_cab_o, wbm_dat_o,
   wbm_dat64_o, wbm_adr_o, wbm_sel_o, ctrl_state
   );
   /* system */
   output wb_clk_i;
   output wb_rst_i;
   input  wb_int_o;
   
   /* WBS */
   input  wbs_rty_o,
	  wbs_err_o,
	  wbs_ack_o;
   input [31:0] wbs_dat_o;
   output [31:0] wbs_dat_i,
		 wbs_adr_i;
   output 	 wbs_we_i,
		 wbs_stb_i,
		 wbs_cyc_i,
		 wbs_cab_i;
   output [3:0]  wbs_sel_i;
   
   /* WBM */
   input 	 wbm_we_o,
		 wbm_stb_o,
		 wbm_cyc_o,
		 wbm_cab_o;
   input [31:0]  wbm_dat_o,
		 wbm_dat64_o,
		 wbm_adr_o;
   input [3:0] 	 wbm_sel_o;
   output 	 wbm_err_i,
		 wbm_ack_i,
		 wbm_rty_i;
   output [31:0] wbm_dat_i,
		 wbm_dat64_i;

   input [7:0] 	 ctrl_state;
   
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg			wb_clk_i;
   reg			wb_rst_i;
   reg			wbm_ack_i;
   reg [31:0]		wbm_dat64_i;
   reg [31:0]		wbm_dat_i;
   reg			wbm_err_i;
   reg			wbm_rty_i;
   reg [31:0]		wbs_adr_i;
   reg			wbs_cab_i;
   reg			wbs_cyc_i;
   reg [31:0]		wbs_dat_i;
   reg [3:0]		wbs_sel_i;
   reg			wbs_stb_i;
   reg			wbs_we_i;
   // End of automatics

   always #7.5   wb_clk_i = !wb_clk_i; // 66MHz

   // doing reset
   task do_reset ;
      begin
	 wbs_cyc_i = 0;
	 wbm_rty_i = 0;
	 wbm_err_i = 0;
	 
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

   integer err, cor;
   
   task check_val ;
      input [255:0] s;
      input [31:0] e;
      input [31:0] v;
      begin
	 $display("      except  value :%x", e);
	 $display("      current value :%x", v);
	 if (e !== v) begin
	    err = err + 1;
	    $display(" **** FAILED ( total failed %d) %d", err, $time);
	 end else begin
	    $display("      PASSED ( total passed %d) ", cor);
	    cor = cor + 1;
	 end
      end
   endtask // check_val

   task check_reg ;
      input [255:0] s;
      input [4:0]   o;
      input [31:0]  e;
      begin
	 //$display("%s", s);
	 wbs_cyc_i = 1'b1;
	 wbs_adr_i = {o, 2'b00}; /* ctl_adr0 */
	 wbs_we_i  = 1'b0;
	 @(posedge wbs_ack_o);
	 check_val(s, e, wbs_dat_o);
	 wbs_cyc_i = 1'b0;
	 @(posedge wb_clk_i);
      end
   endtask // check_reg
   
   reg [31:0] 	 wbmH[1048575:0];
   reg [31:0] 	 wbmL[1048575:0];
   reg [31:0] 	 inc;
   wire [31:3] 	 adr = wbm_adr_o[31:3];
   
   always @(negedge wb_clk_i)
     begin
	if (wbm_we_o) begin
	   wbmH[adr] = wbm_dat_o;
	   wbmL[adr] = wbm_dat64_o;
	   //$write("%x, %x, %x\n", wbm_dat_o, wbm_dat64_o, adr);
	end else begin
	   wbm_dat_i   = wbmH[adr];
	   wbm_dat64_i = wbmL[adr];
	end
     end

   always @(/*AS*/wbm_cyc_o)
     begin
	wbm_ack_i = wbm_cyc_o;
     end
   /* auto inc */
   always @(posedge wb_clk_i)
     begin
	if (wbm_cyc_o == 0)
	  inc = 0;
	else if (wbm_cyc_o && wbm_ack_i)
	  inc = inc + 1;
     end

   integer i;
   task pre_job_0;
      begin
	 /* [31:0] next_desc
	  * [31:0] ctl_addr
	  * [31:0] dc_fc
	  * [31:0] u0
	  * [31:0] src_desc
	  * [31:0] u1
	  * [31:0] dst_desc
	  * [31:0] u2
	  */
	 i = 'h0;
	 wbmH[i] = 32'h300; /* next desc */
	 wbmL[i] = 32'h200; /* ctrl addr */
	 i = i + 1;
	 wbmH[i] = 32'h1;   /* DC_NULL */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = 32'h400; /* src */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = 32'h500; /* dst */
	 wbmL[i] = 32'h0;
      end
   endtask // do_ssadma

   task check_job_0;
      begin
	 check_reg("ctl_adr0 ", 5'h14, 32'h200);
	 check_reg("next_desc", 5'h16, 32'h300);
      end
   endtask // check_job_0

   integer j;
   task pre_job_1;
      begin
	 i = 'h0;
	 wbmH[i] = 32'h100;
	 wbmL[i] = 32'h200;
	 i = i + 1;
	 wbmH[i] = {8'ha, 16'b000000010}; /* READ */
	 wbmL[i] = 32'h0;   /* u0 */
	 i = i + 1;
	 wbmH[i] = {16'h40, 3'b000}; /* src */
	 wbmL[i] = 32'h0;   /* u1  */
	 i = i + 1;
	 wbmH[i] = 32'h0;   /* dst */
	 wbmL[i] = 32'h0;   /* u2  */

	 i = 'h40;
	 wbmH[i] = 'h100040;            /* LAST with 0x80 */
	 wbmL[i] = {16'h50, 3'b000};    /* address */
	 
	 i = 'h50;
	 for (j = i; j < i + 100; j = j + 1) begin
	    wbmH[j] = j;
	    wbmL[j] = j;
	 end
      end
   endtask // pre_job_1

   task check_job_1;
      begin
	 check_reg("ctl_adr0 ", 5'h14, 32'h200);
	 check_reg("next_desc", 5'h16, 32'h100);
      end
   endtask

   task pre_job_2;
      begin
	 i = 'h0;
	 wbmH[i] = 32'h100;
	 wbmL[i] = 32'h200;
	 i = i + 1;
	 wbmH[i] = {8'h1, 8'h2}; /* READ */
	 wbmL[i] = 32'h0;   /* u0 */
	 i = i + 1;
	 wbmH[i] = {16'h40, 3'b000}; /* src */
	 wbmL[i] = 32'h0;   /* u1  */
	 i = i + 1;
	 wbmH[i] = 32'h0;   /* dst */
	 wbmL[i] = 32'h0;   /* u2  */
	 
	 i = 'h40;
	 wbmH[i] = 'h000040;             /* LAST with 0x80 */
	 wbmL[i] = {16'h50,  3'b000};    /* address */
	 i = i + 1;
	 wbmH[i] = {16'h100, 3'b000};    /* Next */
	 wbmL[i] = 0;

	 i = 'h100;
	 wbmH[i] = 'h100040;
	 wbmL[i] = {16'h60,  3'b000};
	 i = i + 1;
	 wbmH[i] = 0;
	 wbmL[i] = 0;
	 
	 /* fake data */
	 i = 'h50;
	 for (j = i; j < i + 100; j = j + 1) begin
	    wbmH[j] = j;
	    wbmL[j] = j;
	 end
      end
   endtask // pre_job_2

   task check_job_2;
      begin
	 check_reg("ctl_adr0 ", 5'h14, 32'h200);
	 check_reg("next_desc", 5'h16, 32'h100);
      end
   endtask

   task pre_job_10;
      begin
	 i = 'h0;
	 wbmH[i] = 32'h1000;  /* next */
	 wbmL[i] = 32'h2000;  /* ctl */
	 i = i + 1;
	 wbmH[i] = {8'ha, 8'h0, 8'hc}; /* FILL */
	 wbmL[i] = 32'h0;   /* u0 */
	 i = i + 1;
	 wbmH[i] = 32'h0;   /* src */
	 wbmL[i] = 32'h0;   /* u1  */
	 i = i + 1;
	 wbmH[i] = {16'h40, 3'b000};   /* dst */
	 wbmL[i] = 32'h0;   /* u2  */
	 
	 i = 'h40;
	 wbmH[i] = 'h000040;             /* LAST with 0x40 */
	 wbmL[i] = {16'h50,  3'b000};    /* address */
	 i = i + 1;
	 wbmH[i] = {16'h100, 3'b000};    /* Next */
	 wbmL[i] = 0;

	 i = 'h100;
	 wbmH[i] = 'h100040;
	 wbmL[i] = {16'h200,  3'b000};
	 i = i + 1;
	 wbmH[i] = 0;
	 wbmL[i] = 0;
	 
	 /* fake data */
	 i = 'h200;
	 for (j = 0; j < 9000; j = j + 1) begin
	    wbmH[j+i] = j;
	    wbmL[j+i] = j;
	 end
      end
   endtask // pre_job_2

   task check_job_10;
      begin
	 check_reg("ctl_adr0 ", 5'h14, 32'h2000);
	 check_reg("next_desc", 5'h16, 32'h1000);
	 for (i = 'h50; i < 'h58; i = i + 1) begin
	    check_val("memory", 32'h0a0a0a0a, wbmH[i]);
	    check_val("memory", 32'h0a0a0a0a, wbmL[i]);
	 end
	 for (i = 'h200; i < 'h208; i = i + 1) begin
	    check_val("memory", 32'h0a0a0a0a, wbmH[i]);
	    check_val("memory", 32'h0a0a0a0a, wbmL[i]);
	 end
      end
   endtask // check_job_10

   integer t;
   task pre_job_20;
      begin
	 i = 'h0;
	 wbmH[i] = 32'h100;  /* next */
	 wbmL[i] = 32'h200;  /* ctl */
	 i = i + 1;
	 wbmH[i] = {8'ha, 16'h16}; /* copy */
	 wbmL[i] = 32'h0;   /* u0 */
	 i = i + 1;
	 wbmH[i] = {16'h20, 3'b000}; /* src */
	 wbmL[i] = 32'h0;   /* u1  */
	 i = i + 1;
	 wbmH[i] = {16'h40, 3'b000}; /* dst */
	 wbmL[i] = 32'h0;   /* u2  */

	 /* dst */
	 i = 'h40;
	 wbmH[i] = 'h100080;             /* LAST with 0x40 */
	 wbmL[i] = {16'h500,  3'b000};    /* address */
	 i = i + 1;
	 wbmH[i] = 0;                   
	 wbmL[i] = 0;

	 /* src */
	 i = 'h20;
	 wbmH[i] = 'h000040;
	 wbmL[i] = {16'h600,  3'b000};
	 i = i + 1;
	 wbmH[i] = {16'h70,   3'b000};
	 wbmL[i] = 0;

	 i = 'h70;
	 wbmH[i] = 'h100040;
	 wbmL[i] = {16'h700,  3'b000};
	 i = i + 1;
	 wbmH[i] = 0;
	 wbmL[i] = 0;
	 
	 /* fake data */
	 i = 'h600;
	 t = 0;
	 for (j = i; j < i + 'h200; j = j + 1) begin
	    wbmH[j] = t;
	    t = t + 1;
	    wbmL[j] = t;
	    t = t + 1;
	 end
      end
   endtask // pre_job_2

   task check_job_20;
      integer s1, s2, d1;
      begin
	 check_reg("ctl_adr0 ", 5'h14, 32'h200);
	 check_reg("ctl_adr0 ", 5'h16, 32'h100);

	 s1 = 'h600;
	 s2 = 'h700;
	 d1 = 'h500;
	 for (i = 0; i < 8; i = i + 1) begin
	    check_val("memory", wbmH[s1+i], wbmH[d1+i]);
	    check_val("memory", wbmL[s1+i], wbmL[d1+i]);
	 end
	 for (i = 0; i < 8; i = i + 1) begin
	    check_val("memory", wbmH[s2+i], wbmH[d1+i+8]);
	    check_val("memory", wbmL[s2+i], wbmL[d1+i+8]);
	 end
      end
   endtask // check_job_10

   task pre_job_100;
      begin
	 /* [31:0] next_desc
	  * [31:0] ctl_addr
	  * [31:0] dc_fc
	  * [31:0] u0
	  * [31:0] src_desc
	  * [31:0] u1
	  * [31:0] dst_desc
	  * [31:0] u2
	  */
	 i = 'h0;
	 wbmH[i] = {16'h10, 3'b000}; /* next desc */
	 wbmL[i] = 32'h1000;          /* ctrl addr */
	 i = i + 1;
	 wbmH[i] = {8'h40, 8'h1};   /* DC_NULL with CONT */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = 32'h400; /* src */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = 32'h500; /* dst */
	 wbmL[i] = 32'h0;
	 
	 i = 'h10;
	 wbmH[i] = 32'h100;        /* next */
	 wbmL[i] = 32'h2000;        /* ctrl */
	 i = i + 1;
	 wbmH[i] = {8'h0, 8'h1};    /* DC_NULL */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = 32'h600; /* src */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = 32'h700; /* dst */
	 wbmL[i] = 32'h0;
      end
   endtask // do_ssadma

   task check_job_100;
      begin
	 check_reg("ctl_adr0 ", 5'h14, 32'h1000);
	 check_reg("ctl_adr1 ", 5'h15, 32'h2000);
	 check_reg("ctl_adr1 ", 5'h16, 32'h0100);
      end
   endtask // check_job_100

   task pre_job_101;
      begin
	 /* [31:0] next_desc
	  * [31:0] ctl_addr
	  * [31:0] dc_fc
	  * [31:0] u0
	  * [31:0] src_desc
	  * [31:0] u1
	  * [31:0] dst_desc
	  * [31:0] u2
	  */
	 i = 'h0;
	 wbmH[i] = {16'h10, 3'b000}; /* next desc */
	 wbmL[i] = 32'h1000;          /* ctrl addr */
	 i = i + 1;
	 wbmH[i] = {8'h40, 8'h1};   /* DC_NULL with CONT */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = 32'h400; /* src */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = 32'h500; /* dst */
	 wbmL[i] = 32'h0;
	 
	 i = 'h10;
	 wbmH[i] = {16'h20, 3'b000};/* next */
	 wbmL[i] = 32'h2000;        /* ctrl */
	 i = i + 1;
	 wbmH[i] = {8'h40, 8'h1};    /* DC_NULL */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = 32'h600; /* src */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = 32'h700; /* dst */
	 wbmL[i] = 32'h0;

	 i = 'h20;
	 wbmH[i] = {16'h30, 3'b000}; /* next desc */
	 wbmL[i] = 32'h1000;          /* ctrl addr */
	 i = i + 1;
	 wbmH[i] = {8'h40, 8'h1};   /* DC_NULL with CONT */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = 32'h400; /* src */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = 32'h500; /* dst */
	 wbmL[i] = 32'h0;

	 i = 'h30;
	 wbmH[i] = 32'h1100; /* next desc */
	 wbmL[i] = 32'h2100;          /* ctrl addr */
	 i = i + 1;
	 wbmH[i] = {8'h00, 8'h1};   /* DC_NULL with CONT */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = 32'h400; /* src */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = 32'h500; /* dst */
	 wbmL[i] = 32'h0;

      end
   endtask // do_ssadma

   task check_job_101;
      begin
	 check_reg("ctl_adr0 ", 5'h14, 32'h1000);
	 check_reg("ctl_adr1 ", 5'h15, 32'h2100);
	 check_reg("next_desc", 5'h16, 32'h1100);
      end
   endtask // check_job_100

   task pre_job_102;
      begin
	 /* [31:0] next_desc
	  * [31:0] ctl_addr
	  * [31:0] dc_fc
	  * [31:0] u0
	  * [31:0] src_desc
	  * [31:0] u1
	  * [31:0] dst_desc
	  * [31:0] u2
	  */
	 i = 'h0;
	 wbmH[i] = {16'h10, 3'b000}; /* next desc */
	 wbmL[i] = 32'h1000;          /* ctrl addr */
	 i = i + 1;
	 wbmH[i] = {8'h41, 8'h2};   /* READ with CONT */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = {16'h40, 3'b000}; /* src */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = 32'h500; /* dst */
	 wbmL[i] = 32'h0;
	 
	 i = 'h10;
	 wbmH[i] = {16'h20, 3'b000};/* next */
	 wbmL[i] = 32'h2000;        /* ctrl */
	 i = i + 1;
	 wbmH[i] = {8'h41, 8'h2};    /* DC_NULL */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = {16'h40, 3'b000}; /* src */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = 32'h700; /* dst */
	 wbmL[i] = 32'h0;

	 i = 'h20;
	 wbmH[i] = {16'h30, 3'b000}; /* next desc */
	 wbmL[i] = 32'h1000;          /* ctrl addr */
	 i = i + 1;
	 wbmH[i] = {8'h41, 8'h2};   /* DC_NULL with CONT */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = {16'h40, 3'b000}; /* src */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = 32'h500; /* dst */
	 wbmL[i] = 32'h0;

	 i = 'h30;
	 wbmH[i] = 32'h1100; /* next desc */
	 wbmL[i] = 32'h2100;          /* ctrl addr */
	 i = i + 1;
	 wbmH[i] = {8'h01, 8'h2};   /* DC_NULL with CONT */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = {16'h40, 3'b000}; /* src */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = 32'h500; /* dst */
	 wbmL[i] = 32'h0;

	 i = 'h40;
	 wbmH[i] = 'h000040;             /* LAST with 0x80 */
	 wbmL[i] = {16'h500,  3'b000};    /* address */
	 i = i + 1;
	 wbmH[i] = {16'h100, 3'b000};    /* Next */
	 wbmL[i] = 0;

	 i = 'h100;
	 wbmH[i] = 'h100040;
	 wbmL[i] = {16'h520,  3'b000};
	 i = i + 1;
	 wbmH[i] = 0;
	 wbmL[i] = 0;

	 i = 'h500;
	 t = 0;
	 for (j = i; j < i + 100; j = j + 1) begin
	    wbmH[j] = t;
	    t = t + 1;
	    wbmL[j] = t;
	    t = t + 1;
	 end
      end
   endtask // do_ssadma

   task check_job_102;
      begin
	 check_reg("ctl_adr0 ", 5'h14, 32'h1000);
	 check_reg("ctl_adr1 ", 5'h15, 32'h2100);
	 check_reg("next_desc", 5'h16, 32'h1100);
      end
   endtask // check_job_100
   
   task pre_job_103;
      begin
	 /* [31:0] next_desc
	  * [31:0] ctl_addr
	  * [31:0] dc_fc
	  * [31:0] u0
	  * [31:0] src_desc
	  * [31:0] u1
	  * [31:0] dst_desc
	  * [31:0] u2
	  */
	 i = 'h0;
	 wbmH[i] = {16'h10, 3'b000}; /* next desc */
	 wbmL[i] = 32'h1000;          /* ctrl addr */
	 i = i + 1;
	 wbmH[i] = {8'h01, 8'h40, 8'hc};   /* 01 FILL with CONT */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = 32'h0; /* src */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = {16'h40, 3'b000}; /* dst */
	 wbmL[i] = 32'h0;
	 
	 i = 'h10;
	 wbmH[i] = {16'h20, 3'b000};/* next */
	 wbmL[i] = 32'h2000;        /* ctrl */
	 i = i + 1;
	 wbmH[i] = {8'h02, 8'h40, 8'hc};    /* 02 FILL with CONT */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = 32'h0;
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = {16'h140, 3'b000}; /* dst */
	 wbmL[i] = 32'h0;

	 i = 'h20;
	 wbmH[i] = {16'h30, 3'b000}; /* next desc */
	 wbmL[i] = 32'h1000;          /* ctrl addr */
	 i = i + 1;
	 wbmH[i] = {8'h03, 8'h40, 8'hc};   /* 03 FILL with CONT */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = 32'h0;
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = {16'h40, 3'b000}; /* dst */
	 wbmL[i] = 32'h0;

	 i = 'h30;
	 wbmH[i] = 32'h1100; /* next desc */
	 wbmL[i] = 32'h2100;          /* ctrl addr */
	 i = i + 1;
	 wbmH[i] = {8'h04, 8'h0, 8'hc};   /* 04 FILL without CONT */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = 32'h0;
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = {16'h140, 3'b000}; /* dst */
	 wbmL[i] = 32'h0;

	 i = 'h40;
	 wbmH[i] = 'h000040;             /* LAST with 0x80 */
	 wbmL[i] = {16'h500,  3'b000};    /* address */
	 i = i + 1;
	 wbmH[i] = {16'h100, 3'b000};    /* Next */
	 wbmL[i] = 0;

	 i = 'h100;
	 wbmH[i] = 'h100040;
	 wbmL[i] = {16'h520,  3'b000};
	 i = i + 1;
	 wbmH[i] = 0;
	 wbmL[i] = 0;

	 i = 'h140;
	 wbmH[i] = 'h000040;             /* LAST with 0x80 */
	 wbmL[i] = {16'h600,  3'b000};    /* address */
	 i = i + 1;
	 wbmH[i] = {16'h200, 3'b000};    /* Next */
	 wbmL[i] = 0;

	 i = 'h200;
	 wbmH[i] = 'h100040;
	 wbmL[i] = {16'h620,  3'b000};
	 i = i + 1;
	 wbmH[i] = 0;
	 wbmL[i] = 0;

	 i = 'h500;
	 t = 0;
	 for (j = i; j < i + 100; j = j + 1) begin
	    wbmH[j] = t;
	    t = t + 1;
	    wbmL[j] = t;
	    t = t + 1;
	 end
      end
   endtask // do_ssadma

   task check_job_103;
      integer d1, d2;
      begin
	 check_reg("ctl_adr0 ", 5'h14, 32'h1000);
	 check_reg("ctl_adr1 ", 5'h15, 32'h2100);
	 check_reg("next_desc", 5'h16, 32'h1100);
	 d1 = 'h500;
	 d2 = 'h520;
	 for (i = d1; i < d1 + 'h8; i = i + 1) begin
	    check_val("memory", 32'h03030303, wbmH[i]);
	    check_val("memory", 32'h03030303, wbmL[i]);
	 end
	 for (i = d2; i < d2 + 'h8; i = i + 1) begin
	    check_val("memory", 32'h03030303, wbmH[i]);
	    check_val("memory", 32'h03030303, wbmL[i]);
	 end
	 d1 = 'h600;
	 d2 = 'h620;
	 for (i = d1; i < d1 + 'h8; i = i + 1) begin
	    check_val("memory", 32'h04040404, wbmH[i]);
	    check_val("memory", 32'h04040404, wbmL[i]);
	 end
	 for (i = d2; i < d2 + 'h8; i = i + 1) begin
	    check_val("memory", 32'h04040404, wbmH[i]);
	    check_val("memory", 32'h04040404, wbmL[i]);
	 end
      end
   endtask // check_job_100

   task pre_job_104;
      begin
	 /* [31:0] next_desc
	  * [31:0] ctl_addr
	  * [31:0] dc_fc
	  * [31:0] u0
	  * [31:0] src_desc
	  * [31:0] u1
	  * [31:0] dst_desc
	  * [31:0] u2
	  */
	 i = 'h0;
	 wbmH[i] = {16'h10, 3'b000}; /* next desc */
	 wbmL[i] = 32'h1000;          /* ctrl addr */
	 i = i + 1;
	 wbmH[i] = {8'h40, 8'h16};   /* memcpy with CONT */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = {16'h40,  3'b000}; /* src */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = {16'h1100, 3'b000}; /* dst */
	 wbmL[i] = 32'h0;
	 
	 i = 'h10;
	 wbmH[i] = {16'h20, 3'b000};/* next */
	 wbmL[i] = 32'h2000;        /* ctrl */
	 i = i + 1;
	 wbmH[i] = {8'h40, 8'h16};    /* memcpy with CONT */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = {16'h40,  3'b000};
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = {16'h1200, 3'b000}; /* dst */
	 wbmL[i] = 32'h0;

	 i = 'h20;
	 wbmH[i] = {16'h30, 3'b000}; /* next desc */
	 wbmL[i] = 32'h3000;          /* ctrl addr */
	 i = i + 1;
	 wbmH[i] = {8'h40, 8'h16};   /* memcpy with CONT */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = {16'h40,  3'b000};
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = {16'h1300, 3'b000}; /* dst */
	 wbmL[i] = 32'h0;

	 i = 'h30;
	 wbmH[i] = 32'h1100; /* next desc */
	 wbmL[i] = 32'h2100;          /* ctrl addr */
	 i = i + 1;
	 wbmH[i] = {8'h0, 8'h16};   /* memcpy without CONT */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = {16'h40, 3'b000};
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = {16'h1400, 3'b000}; /* dst */
	 wbmL[i] = 32'h0;

	 i = 'h40;
	 wbmH[i] = 'h000040;             /* LAST with 0x80 */
	 wbmL[i] = {16'h500,  3'b000};    /* address */
	 i = i + 1;
	 wbmH[i] = {16'h100, 3'b000};    /* Next */
	 wbmL[i] = 0;

	 i = 'h100;
	 wbmH[i] = 'h100040;
	 wbmL[i] = {16'h540,  3'b000};
	 i = i + 1;
	 wbmH[i] = 0;
	 wbmL[i] = 0;

	 i = 'h500;
	 t = 0;
	 for (j = i; j < i + 200; j = j + 1) begin
	    wbmH[j] = t;
	    t = t + 1;
	    wbmL[j] = t;
	    t = t + 1;
	 end

	 i = 'h1100;
	 wbmH[i] = 'h100080;
	 wbmL[i] = {16'h2100, 3'b000};
	 i = i + 1;
	 wbmH[i] = 0;
	 wbmL[i] = 0;

	 i = 'h1200;
	 wbmH[i] = 'h100080;
	 wbmL[i] = {16'h2200, 3'b000};
	 i = i + 1;
	 wbmH[i] = 0;
	 wbmL[i] = 0;

	 
	 i = 'h1300;
	 wbmH[i] = 'h100080;
	 wbmL[i] = {16'h2300, 3'b000};
	 i = i + 1;
	 wbmH[i] = 0;
	 wbmL[i] = 0;

	 i = 'h1400;
	 wbmH[i] = 'h100080;
	 wbmL[i] = {16'h2400, 3'b000};
	 i = i + 1;
	 wbmH[i] = 0;
	 wbmL[i] = 0;
      end
   endtask // do_ssadma

   task check_job_104;
      integer s1, s2, d1;
      begin
	 check_reg("ctl_adr0 ", 5'h14, 32'h3000);
	 check_reg("ctl_adr1 ", 5'h15, 32'h2100);
	 check_reg("next_desc", 5'h16, 32'h1100);
	 s1 = 'h500;
	 s2 = 'h540;
	 d1 = 'h2100;
	 $display("      addr %x -- ", d1);
	 for (i = 'h0; i < 'h8; i = i + 1) begin
	    check_val("memory", wbmH[s1+i], wbmH[d1+i]);
	    check_val("memory", wbmL[s1+i], wbmL[d1+i]);
	 end
	 for (i = 'h0; i < 'h8; i = i + 1) begin
	    check_val("memory", wbmH[s2+i], wbmH[d1+i+8]);
	    check_val("memory", wbmL[s2+i], wbmL[d1+i+8]);
	 end
	 d1 = 'h2200;
	 $display("      addr %x -- ", d1);
	 for (i = 'h0; i < 'h8; i = i + 1) begin
	    check_val("memory", wbmH[s1+i], wbmH[d1+i]);
	    check_val("memory", wbmL[s1+i], wbmL[d1+i]);
	 end
	 for (i = 'h0; i < 'h8; i = i + 1) begin
	    check_val("memory", wbmH[s2+i], wbmH[d1+i+8]);
	    check_val("memory", wbmL[s2+i], wbmL[d1+i+8]);
	 end
	 d1 = 'h2300;
	 $display("      addr %x -- ", d1);
	 for (i = 'h0; i < 'h8; i = i + 1) begin
	    check_val("memory", wbmH[s1+i], wbmH[d1+i]);
	    check_val("memory", wbmL[s1+i], wbmL[d1+i]);
	 end
	 for (i = 'h0; i < 'h8; i = i + 1) begin
	    check_val("memory", wbmH[s2+i], wbmH[d1+i+8]);
	    check_val("memory", wbmL[s2+i], wbmL[d1+i+8]);
	 end
	 d1 = 'h2400;
	 $display("      addr %x -- ", d1);
	 for (i = 'h0; i < 'h8; i = i + 1) begin
	    check_val("memory", wbmH[s1+i], wbmH[d1+i]);
	    check_val("memory", wbmL[s1+i], wbmL[d1+i]);
	 end
	 for (i = 'h0; i < 'h8; i = i + 1) begin
	    check_val("memory", wbmH[s2+i], wbmH[d1+i+8]);
	    check_val("memory", wbmL[s2+i], wbmL[d1+i+8]);
	 end
      end
   endtask // check_job_100

   task pre_job_105;
      begin
	 /* [31:0] next_desc
	  * [31:0] ctl_addr
	  * [31:0] dc_fc
	  * [31:0] u0
	  * [31:0] src_desc
	  * [31:0] u1
	  * [31:0] dst_desc
	  * [31:0] u2
	  */
	 i = 'h0;
	 wbmH[i] = {16'h10, 3'b000}; /* next desc */
	 wbmL[i] = 32'h1000;          /* ctrl addr */
	 i = i + 1;
	 wbmH[i] = {8'h40, 8'h16};   /* memcpy with CONT */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = {16'h40,  3'b000}; /* src */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = {16'h1100, 3'b000}; /* dst */
	 wbmL[i] = 32'h0;
	 
	 i = 'h10;
	 wbmH[i] = {16'h20, 3'b000};/* next */
	 wbmL[i] = 32'h2000;        /* ctrl */
	 i = i + 1;
	 wbmH[i] = {8'h40, 8'h16};    /* memcpy with CONT */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = {16'h40,  3'b000};
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = {16'h1200, 3'b000}; /* dst */
	 wbmL[i] = 32'h0;

	 i = 'h20;
	 wbmH[i] = {16'h30, 3'b000}; /* next desc */
	 wbmL[i] = 32'h3000;          /* ctrl addr */
	 i = i + 1;
	 wbmH[i] = {8'h40, 8'h16};   /* memcpy with CONT */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = {16'h40,  3'b000};
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = {16'h1300, 3'b000}; /* dst */
	 wbmL[i] = 32'h0;

	 i = 'h30;
	 wbmH[i] = 32'h1100; /* next desc */
	 wbmL[i] = 32'h2100;          /* ctrl addr */
	 i = i + 1;
	 wbmH[i] = {8'h0, 8'h16};   /* memcpy without CONT */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = {16'h40, 3'b000};
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = {16'h1400, 3'b000}; /* dst */
	 wbmL[i] = 32'h0;

	 i = 'h40;
	 wbmH[i] = 'h000040;             /* LAST with 0x80 */
	 wbmL[i] = {16'h500,  3'b000};    /* address */
	 i = i + 1;
	 wbmH[i] = {16'h100, 3'b000};    /* Next */
	 wbmL[i] = 0;

	 i = 'h100;
	 wbmH[i] = 'h102000;
	 wbmL[i] = {16'h540,  3'b000};
	 i = i + 1;
	 wbmH[i] = 0;
	 wbmL[i] = 0;

	 i = 'h500;
	 t = 0;
	 for (j = i; j < i + 16384; j = j + 1) begin
	    wbmH[j] = t;
	    t = t + 1;
	    wbmL[j] = t;
	    t = t + 1;
	 end

	 i = 'h110000;
	 wbmH[i] = 'h102040;
	 wbmL[i] = {16'h2100, 3'b000};
	 i = i + 1;
	 wbmH[i] = 0;
	 wbmL[i] = 0;

	 i = 'h120000;
	 wbmH[i] = 'h102040;
	 wbmL[i] = {16'h2200, 3'b000};
	 i = i + 1;
	 wbmH[i] = 0;
	 wbmL[i] = 0;

	 
	 i = 'h130000;
	 wbmH[i] = 'h102040;
	 wbmL[i] = {16'h2300, 3'b000};
	 i = i + 1;
	 wbmH[i] = 0;
	 wbmL[i] = 0;

	 i = 'h140000;
	 wbmH[i] = 'h102040;
	 wbmL[i] = {16'h2400, 3'b000};
	 i = i + 1;
	 wbmH[i] = 0;
	 wbmL[i] = 0;
      end
   endtask // do_ssadma

   task check_job_105;
      integer s1, s2, d1;
      begin
	 check_reg("ctl_adr0 ", 5'h14, 32'h3000);
	 check_reg("ctl_adr1 ", 5'h15, 32'h2100);
	 check_reg("next_desc", 5'h16, 32'h1100);
	 s1 = 'h500;
	 s2 = 'h540;
	 d1 = 'h210000;
	 for (i = 'h0; i < 'h8; i = i + 1) begin
	    check_val("memory", wbmH[s1+i], wbmH[d1+i]);
	    check_val("memory", wbmL[s1+i], wbmL[d1+i]);
	 end
	 for (i = 'h0; i < 'h400; i = i + 1) begin
	    check_val("memory", wbmH[s2+i], wbmH[d1+i+8]);
	    check_val("memory", wbmL[s2+i], wbmL[d1+i+8]);
	 end
	 d1 = 'h220000;
	 for (i = 'h0; i < 'h8; i = i + 1) begin
	    check_val("memory", wbmH[s1+i], wbmH[d1+i]);
	    check_val("memory", wbmL[s1+i], wbmL[d1+i]);
	 end
	 for (i = 'h0; i < 'h400; i = i + 1) begin
	    check_val("memory", wbmH[s2+i], wbmH[d1+i+8]);
	    check_val("memory", wbmL[s2+i], wbmL[d1+i+8]);
	 end
	 d1 = 'h230000;
	 for (i = 'h0; i < 'h8; i = i + 1) begin
	    check_val("memory", wbmH[s1+i], wbmH[d1+i]);
	    check_val("memory", wbmL[s1+i], wbmL[d1+i]);
	 end
	 for (i = 'h0; i < 'h400; i = i + 1) begin
	    check_val("memory", wbmH[s2+i], wbmH[d1+i+8]);
	    check_val("memory", wbmL[s2+i], wbmL[d1+i+8]);
	 end
	 d1 = 'h240000;
	 for (i = 'h0; i < 'h8; i = i + 1) begin
	    check_val("memory", wbmH[s1+i], wbmH[d1+i]);
	    check_val("memory", wbmL[s1+i], wbmL[d1+i]);
	 end
	 for (i = 'h0; i < 'h400; i = i + 1) begin
	    check_val("memory", wbmH[s2+i], wbmH[d1+i+8]);
	    check_val("memory", wbmL[s2+i], wbmL[d1+i+8]);
	 end
      end
   endtask // check_job_100

   task pre_job_200;
      input [7:0] w;
      begin
	 i = 'h0;
	 wbmH[i] = 0;
	 wbmL[i] = 32'h1000;
	 i = i + 1;
	 wbmH[i] = {8'h0, 8'h1};
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = 32'h400;
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = 32'h300;
	 wbmL[i] = 32'h0;

	 queue_job;
	 for (i = 0; i < w; i = i+1) begin
	    @(posedge wb_clk_i);
	 end
	 
	 i = 'h20;
	 wbmH[i] = 32'h1100;        /* next desc */
	 wbmL[i] = 32'h2100;        /* ctrl addr */
	 i = i + 1;
	 wbmH[i] = {8'h0, 8'h01};   /* NULL without CONT */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = {16'h40,   3'b000};
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = {16'h1400, 3'b000}; /* dst */
	 wbmL[i] = 32'h0;

	 wbmH[0] = {8'h20, 3'b000};
	 wbmH[1] = {8'h40, 8'h1};
	 //queue_job;
	 append_job;
	 wait_job(500);
      end
   endtask // pre_job_200

   task check_job_200;
      begin
	 /* after resume the last job desc reading twice */
	 check_reg("ctl_adr0 ", 5'h14, 32'h2100);
	 check_reg("ctl_adr1 ", 5'h15, 32'h2100);
	 check_reg("next_desc", 5'h16, 32'h1100);
      end
   endtask // pre_job_200

   task pre_job_300;
      begin
	 i = 'h0;
	 wbmH[i] = 32'h300; /* next desc */
	 wbmL[i] = 32'h200; /* ctrl addr */
	 i = i + 1;
	 wbmH[i] = {8'h80, 8'h01};   /* DC_NULL with intr */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = 32'h400; /* src */
	 wbmL[i] = 32'h0;
	 i = i + 1;
	 wbmH[i] = 32'h500; /* dst */
	 wbmL[i] = 32'h0;

	 queue_job;
	 wait_job(50);
	 if (wb_int_o == 0) begin
	    err = err + 1;
	    $display("    INTR0 FAILED, %d" , $time);
	 end else begin
	    cor = cor + 1;
	    
	    ack_intr;

	    if (wb_int_o == 1) begin
	       $display("    INTR1 FAILED, %d", $time);
	    end else begin
	       $display("    INTR PASSED");
	    end
	 end
      end
   endtask // pre_job_300

   task wait_job;
      input [31:0] w;
      begin
	 @(negedge wb_clk_i);
	 @(negedge wb_clk_i);
	 @(negedge wb_clk_i);

	 i = w;
	 while (i > 0) begin
	    @(negedge wb_clk_i);
	    if (ctrl_state == 0) begin
	       i = 0;
	    end else begin
	       i = i - 1;
	    end		
	 end
	 if (ctrl_state != 0) begin
	    $write("********** job failed *************\n");
	 end
	 @(negedge wb_clk_i);
	 @(negedge wb_clk_i);
	 @(negedge wb_clk_i);

	 /* disable DMA */
	 wbs_cyc_i = 1'b1;
	 wbs_adr_i = 4'h0; /* ccr */
	 wbs_we_i  = 1'b1;
	 wbs_dat_i = 32'h0;
	 @(posedge wbs_ack_o);
	 wbs_cyc_i = 1'b0;
	 @(negedge wb_clk_i);
	 @(negedge wbs_ack_o);
	 
	 @(negedge wb_clk_i);
	 @(negedge wb_clk_i);
	 @(negedge wb_clk_i);
      end
   endtask // wait_job

   task queue_job;
      begin
	 wbs_cyc_i = 1'b1;

	 wbs_we_i  = 1'b1;
	 wbs_stb_i = 1'b1;
	 wbs_sel_i = 4'b1111;
	 wbs_cab_i = 1'b0;
	 
	 wbs_cyc_i = 1'b1;
	 wbs_adr_i = 4'h0; /* ccr */
	 wbs_dat_i = 2'b00;
	 @(posedge wbs_ack_o);
	 wbs_cyc_i = 1'b0;
	 @(negedge wb_clk_i);
	 @(negedge wbs_ack_o);

	 wbs_cyc_i = 1'b1;
	 wbs_adr_i = 4'hc; /* ndar */	 
	 wbs_dat_i = 32'h0;
	 @(posedge wbs_ack_o);
	 wbs_cyc_i = 1'b0;
	 @(negedge wb_clk_i);
	 @(negedge wbs_ack_o);
	 
	 wbs_cyc_i = 1'b1;
	 wbs_adr_i = 4'h0; /* ccr */
	 wbs_dat_i = 2'b10;
	 @(posedge wbs_ack_o);
	 wbs_cyc_i = 1'b0;
	 @(negedge wb_clk_i);
	 @(negedge wbs_ack_o);
      end
   endtask // queue_job

   task append_job;
      begin
	 wbs_we_i  = 1'b1;
	 wbs_stb_i = 1'b1;
	 wbs_sel_i = 4'b1111;
	 wbs_cab_i = 1'b0;

	 wbs_cyc_i = 1'b1;
	 wbs_adr_i = 4'h0; /* ccr */
	 wbs_dat_i = 2'b11;/* append with resume */
	 @(posedge wbs_ack_o);
	 wbs_cyc_i = 1'b0;
	 @(negedge wb_clk_i);
	 @(negedge wbs_ack_o);
      end
   endtask // queue_job
   
   task ack_intr;
      begin
	 wbs_we_i  = 1'b1;
	 wbs_stb_i = 1'b1;
	 wbs_sel_i = 4'b1111;
	 wbs_cab_i = 1'b0;

	 wbs_cyc_i = 1'b1;
	 wbs_adr_i = 4'h0; /* ccr */
	 wbs_dat_i = 3'b110;/* intr ack with enable */
	 @(posedge wbs_ack_o);
	 wbs_cyc_i = 1'b0;
	 @(negedge wb_clk_i);
	 @(negedge wbs_ack_o);
      end
   endtask // queue_job

   initial begin
      wb_clk_i = 1;
      wb_rst_i = 0;
      inc      = 0;
      err      = 0;
      cor      = 0;
      
      do_reset;

      /* making the register are right 
       * check the base adma works 
       */
      $display("job 0, %d", $time);
      pre_job_0;
      queue_job;
      wait_job(500);
      check_job_0;

      /* doing memory read
       */
      $display("job 1, %d", $time);
      pre_job_1;
      queue_job;
      wait_job(500);
      check_job_1;

      /*
       * doing memory read with chain.
       */
      $display("job 2, %d", $time);
      pre_job_2;
      queue_job;
      wait_job(500);
      check_job_2;

      /*
       * doing memory fill with chain.
       */
      $display("job 10, %d", $time);
      pre_job_10;
      queue_job;
      wait_job(5000);
      check_job_10;

      /*
       * doing memory copy with chain.
       */
      $display("job 20, %d", $time);
      pre_job_20;
      queue_job;
      wait_job(500);
      check_job_20;

      //$write("time %d\n", $time);
      /*
       * doing null with chain with 2 job 
       */
      $display("job 100, %d", $time);
      pre_job_100;
      queue_job;
      wait_job(500);
      check_job_100;

      /*
       * doing null with chain with 4 job 
       */
      $display("job 101, %d", $time);
      pre_job_101;
      queue_job;
      wait_job(500);
      check_job_101;

      /*
       * doing read with chain with 4 job 
       */
      $display("job 102, %d", $time);
      pre_job_102;
      queue_job;
      wait_job(500);
      check_job_102;

      /*
       * doing fill with chain with 4 job 
       */
      $display("job 103, %d", $time);
      pre_job_103;
      queue_job;
      wait_job(500);
      check_job_103;

      /*
       * doing memory copy with chain with 4 job
       */
      $display("job 104, %d", $time);
      pre_job_104;
      queue_job;
      wait_job(500);
      check_job_104;

      /*
       * doing large memory copy 
       */
      //$display("job 105, %d", $time);
      //pre_job_105;
      //queue_job;
      //wait_job(500000);
      //check_job_105;

      /*
       * testing the append operation 
       */
      $display("job 200, %d", $time);
      pre_job_200(1);
      check_job_200;
      pre_job_200(2);
      check_job_200;
      pre_job_200(3);
      check_job_200;
      pre_job_200(4);
      check_job_200;

      /*
       * interrupt test
       */
      $display("job 300, %d", $time);
      pre_job_300;
      
      $display("PASSED %d", cor);
      $display("FAILED %d", err);
      
      $finish;
   end
   
endmodule // ben_adma
