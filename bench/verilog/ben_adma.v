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

   task check_val ;
      input [255:0] s;
      input [31:0] v;
      input [31:0] c;
      begin
	 $write("%s         ", s);
	 if (v == c) begin
	    $write("passed\n");
	 end else begin
	    $write("failed\n");
	 end
      end
   endtask // check_val
   
   reg [31:0] 	 wbmH[1048575:0];
   reg [31:0] 	 wbmL[1048575:0];
   reg [31:0] 	 inc;
   always @(/*AS*/wbm_adr_o or wbm_dat64_o or wbm_dat_o
	    or wbm_we_o)
     begin
	if (wbm_we_o) begin
	   wbmL[wbm_adr_o[31:3]] = wbm_dat_o;
	   wbmH[wbm_adr_o[31:3]] = wbm_dat64_o;
	end
	wbm_dat_i   = wbmL[wbm_adr_o[31:3]];
	wbm_dat64_i = wbmH[wbm_adr_o[31:3]];
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
	 wbs_cyc_i = 1'b1;
	 wbs_adr_i = {5'h14, 2'b00}; /* ctl_adr0 */
	 wbs_we_i  = 1'b0;
	 @(posedge wbs_ack_o);
	 check_val("check ctl_adr0 ", wbs_dat_o, 32'h200);
	 wbs_cyc_i = 1'b0;
	 @(posedge wb_clk_i);

	 wbs_cyc_i = 1'b1;
	 wbs_adr_i = {5'h16, 2'b00}; /* ctl */
	 wbs_we_i  = 1'b0;
	 @(posedge wbs_ack_o);
	 check_val("check next_desc ", wbs_dat_o, 32'h300);
	 wbs_cyc_i = 1'b0;
	 @(posedge wb_clk_i);
	 @(posedge wb_clk_i);
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
	 wbs_cyc_i = 1'b1;
	 wbs_adr_i = {5'h14, 2'b00}; /* ctl_adr0 */
	 wbs_we_i  = 1'b0;
	 @(posedge wbs_ack_o);
	 check_val("check ctl_adr0 ", wbs_dat_o, 32'h200);
	 wbs_cyc_i = 1'b0;
	 @(posedge wb_clk_i);

	 wbs_cyc_i = 1'b1;
	 wbs_adr_i = {5'h16, 2'b00}; /* ctl */
	 wbs_we_i  = 1'b0;
	 @(posedge wbs_ack_o);
	 check_val("check next_desc ", wbs_dat_o, 32'h100);
	 wbs_cyc_i = 1'b0;
	 @(posedge wb_clk_i);
	 @(posedge wb_clk_i);
      end
   endtask

   task pre_job_2;
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
	 wbs_cyc_i = 1'b1;
	 wbs_adr_i = {5'h14, 2'b00}; /* ctl_adr0 */
	 wbs_we_i  = 1'b0;
	 @(posedge wbs_ack_o);
	 check_val("check ctl_adr0 ", wbs_dat_o, 32'h200);
	 wbs_cyc_i = 1'b0;
	 @(posedge wb_clk_i);

	 wbs_cyc_i = 1'b1;
	 wbs_adr_i = {5'h16, 2'b00}; /* ctl */
	 wbs_we_i  = 1'b0;
	 @(posedge wbs_ack_o);
	 check_val("check next_desc ", wbs_dat_o, 32'h100);
	 wbs_cyc_i = 1'b0;
	 @(posedge wb_clk_i);
	 @(posedge wb_clk_i);
      end
   endtask

   task pre_job_10;
      begin
	 i = 'h0;
	 wbmH[i] = 32'h1000;  /* next */
	 wbmL[i] = 32'h2000;  /* ctl */
	 i = i + 1;
	 wbmH[i] = {8'ha, 16'b00001101}; /* FILL */
	 wbmL[i] = 32'h0;   /* u0 */
	 i = i + 1;
	 wbmH[i] = 32'h0;   /* src */
	 wbmL[i] = 32'h0;   /* u1  */
	 i = i + 1;
	 wbmH[i] = {16'h40, 3'b000};   /* dst */
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

   task check_job_10;
      begin
	 wbs_cyc_i = 1'b1;
	 wbs_adr_i = {5'h14, 2'b00}; /* ctl_adr0 */
	 wbs_we_i  = 1'b0;
	 @(posedge wbs_ack_o);
	 check_val("check ctl_adr0 ", wbs_dat_o, 32'h2000);
	 wbs_cyc_i = 1'b0;
	 @(posedge wb_clk_i);

	 wbs_cyc_i = 1'b1;
	 wbs_adr_i = {5'h16, 2'b00}; /* ctl */
	 wbs_we_i  = 1'b0;
	 @(posedge wbs_ack_o);
	 check_val("check next_desc ", wbs_dat_o, 32'h1000);
	 wbs_cyc_i = 1'b0;
	 @(posedge wb_clk_i);
	 @(posedge wb_clk_i);
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
	 wbmH[i] = {16'h40, 3'b000}; /* src */
	 wbmL[i] = 32'h0;   /* u1  */
	 i = i + 1;
	 wbmH[i] = {16'h20, 3'b000}; /* dst */
	 wbmL[i] = 32'h0;   /* u2  */
	 
	 i = 'h40;
	 wbmH[i] = 'h100080;             /* LAST with 0x40 */
	 wbmL[i] = {16'h500,  3'b000};    /* address */
	 i = i + 1;
	 wbmH[i] = 0;                   
	 wbmL[i] = 0;

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
	 i = 'h500;
	 t = 0;
	 for (j = i; j < i + 100; j = j + 1) begin
	    wbmH[j] = t;
	    t = t + 1;
	    wbmL[j] = t;
	    t = t + 1;
	 end
      end
   endtask // pre_job_2

   task check_job_20;
      begin
	 wbs_cyc_i = 1'b1;
	 wbs_adr_i = {5'h14, 2'b00}; /* ctl_adr0 */
	 wbs_we_i  = 1'b0;
	 @(posedge wbs_ack_o);
	 check_val("check ctl_adr0 ", wbs_dat_o, 32'h200);
	 wbs_cyc_i = 1'b0;
	 @(posedge wb_clk_i);

	 wbs_cyc_i = 1'b1;
	 wbs_adr_i = {5'h16, 2'b00}; /* ctl */
	 wbs_we_i  = 1'b0;
	 @(posedge wbs_ack_o);
	 check_val("check next_desc ", wbs_dat_o, 32'h100);
	 wbs_cyc_i = 1'b0;
	 @(posedge wb_clk_i);
	 @(posedge wb_clk_i);
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
	 wbs_cyc_i = 1'b1;
	 wbs_adr_i = {5'h14, 2'b00}; /* ctl_adr0 */
	 wbs_we_i  = 1'b0;
	 @(posedge wbs_ack_o);
	 check_val("check ctl_adr0 ", wbs_dat_o, 32'h1000);
	 wbs_cyc_i = 1'b0;
	 @(posedge wb_clk_i);

	 wbs_cyc_i = 1'b1;
	 wbs_adr_i = {5'h15, 2'b00}; /* ctl */
	 wbs_we_i  = 1'b0;
	 @(posedge wbs_ack_o);
	 check_val("check ctl_adr1 ", wbs_dat_o, 32'h2000);
	 wbs_cyc_i = 1'b0;
	 @(posedge wb_clk_i);

	 wbs_cyc_i = 1'b1;
	 wbs_adr_i = {5'h16, 2'b00}; /* ctl */
	 wbs_we_i  = 1'b0;
	 @(posedge wbs_ack_o);
	 check_val("check next_desc ", wbs_dat_o, 32'h100);
	 wbs_cyc_i = 1'b0;
	 @(posedge wb_clk_i);
	 
	 @(posedge wb_clk_i);
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
	 wbs_cyc_i = 1'b1;
	 wbs_adr_i = {5'h14, 2'b00}; /* ctl_adr0 */
	 wbs_we_i  = 1'b0;
	 @(posedge wbs_ack_o);
	 check_val("check ctl_adr0 ", wbs_dat_o, 32'h1000);
	 wbs_cyc_i = 1'b0;
	 @(posedge wb_clk_i);

	 wbs_cyc_i = 1'b1;
	 wbs_adr_i = {5'h15, 2'b00}; /* ctl */
	 wbs_we_i  = 1'b0;
	 @(posedge wbs_ack_o);
	 check_val("check ctl_adr1 ", wbs_dat_o, 32'h2100);
	 wbs_cyc_i = 1'b0;
	 @(posedge wb_clk_i);

	 wbs_cyc_i = 1'b1;
	 wbs_adr_i = {5'h16, 2'b00}; /* ctl */
	 wbs_we_i  = 1'b0;
	 @(posedge wbs_ack_o);
	 check_val("check next_desc ", wbs_dat_o, 32'h1100);
	 wbs_cyc_i = 1'b0;
	 @(posedge wb_clk_i);
	 
	 @(posedge wb_clk_i);
      end
   endtask // check_job_100
   
   task wait_job;
      begin
	 @(negedge wb_clk_i);
	 @(negedge wb_clk_i);
	 @(negedge wb_clk_i);

	 i = 500;
	 while (i > 0) begin
	    @(negedge wb_clk_i);
	    if (ctrl_state == 0) begin
	       i = 0;
	    end else begin
	       i = i - 1;
	    end		
	 end
	 if (ctrl_state != 0) begin
	    $write("job failed\n");
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
	 wbs_adr_i = 4'hc; /* ndar */
	 wbs_we_i  = 1'b1;
	 wbs_stb_i = 1'b1;
	 wbs_sel_i = 4'b1111;
	 wbs_cab_i = 1'b0;
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
   
   initial begin
      wb_clk_i = 1;
      wb_rst_i = 0;
      inc      = 0;

      do_reset;

      /* making the register are right 
       * check the base adma works 
       */
      pre_job_0;
      queue_job;
      wait_job;
      check_job_0;

      /* doing memory read
       */
      pre_job_1;
      queue_job;
      wait_job;
      check_job_1;

      /*
       * doing memory read with chain.
       */
      pre_job_2;
      queue_job;
      wait_job;
      check_job_2;

      /*
       * doing memory fill with chain.
       */
      pre_job_10;
      queue_job;
      wait_job;
      check_job_10;

      /*
       * doing memory copy with chain.
       */
      pre_job_20;
      queue_job;
      wait_job;
      check_job_20;

      //$write("time %d\n", $time);
      /*
       * doing null with chain with 2 job 
       */
      pre_job_100;
      queue_job;
      wait_job;
      check_job_100;

      /*
       * doing null with chain with 4 job 
       */
      pre_job_101;
      queue_job;
      wait_job;
      check_job_101;
      
      $finish;
   end
   
endmodule // ben_adma
