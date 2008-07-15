/************************************************************************
 *     File Name  : ss_sg.v
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

module ss_sg(/*AUTOARG*/
   // Outputs
   wbs_cyc, wbs_stb, wbs_we, wbs_cab, wbs_sel, wbs_adr,
   sg_state, sg_desc, sg_addr, sg_next, ss_xfer, ss_last,
   c_done,
   // Inputs
   wb_clk_i, wb_rst_i, rw, wbs_dat_o, wbs_dat64_o, wbs_ack,
   wbs_err, wbs_rty, ss_dat, ss_we, ss_adr, ss_done, ss_dc,
   ss_start, ss_end, ss_stop
   );
   /*AUTOOUTPUT*/
   /*AUTOINPUT*/
   /*AUTOWIRE*/

   input wb_clk_i;		// clock signal
   input wb_rst_i;		// reset signal
   input rw;
   
   /* WB interface */
   output wbs_cyc, 		// cycle signal
	  wbs_stb, 		// strobe 
	  wbs_we, 		// we 
	  wbs_cab;		// 
   output [3:0] wbs_sel;	// byte select
   output [31:0] wbs_adr/*, 	// address 
		 wbs_dat_i, 	// data output
		 wbs_dat64_i*/;	// data output high 64
   input [31:0]  wbs_dat_o,	// data input
		 wbs_dat64_o;	// data input high 64
   input 	 wbs_ack, 	// acknowledge
		 wbs_err, 	// error report
		 wbs_rty;	// retry report

   input [31:0]  ss_dat;	// data from ss_adma
   input 	 ss_we;		// we singla from ss_adma
   input [1:0] 	 ss_adr;	// address from ss_adma
   input 	 ss_done;	// done from ss_adma
   input [23:0]  ss_dc;
   /* 
    * 0: reserved  
    * 1: dc_fc    [31:0] 
    * 2: src_desc [31:3]
    * 3: dst_desc [31:3]
    */
   /*
    * 0: desc     [20][15:0]
    * 1: addr     [31:3]
    * 2: next     [31:3] 
    */
   
   output [7:0]  sg_state; /* 7 is last [6:0] state */
   output [15:0] sg_desc;
   output [31:3] sg_addr;
   output [31:3] sg_next;
   /*
    * registers
    * reg [2:0]  state
    * reg        last
    * reg [15:0] desc
    * reg [31:3] addr
    * reg [31:3] next
    */
   input 	 ss_start; /* ready to start data */
   input 	 ss_end;   /* job end  */
   input 	 ss_stop;  /* stop io transcation */
   output 	 ss_xfer;  /* acknowledge data */
   output 	 ss_last;  /* last */
   
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [15:0]		sg_desc;
   reg [7:0]		sg_state;
   reg			ss_last;
   reg			ss_xfer;
   // End of automatics
   
   /* wb register */
   reg [31:0] 	 wbs_adr, wbs_adr_n;
   reg 		 wbs_cyc, wbs_cyc_n;
   reg 		 wbs_stb, wbs_stb_n;
   reg 		 wbs_we,  wbs_we_n;
   reg 		 wbs_cab, wbs_cab_n;
   reg [3:0] 	 wbs_sel, wbs_sel_n;
   always @(posedge wb_clk_i)
     begin
	wbs_stb <= #1 wbs_stb_n;
	wbs_we  <= #1 wbs_we_n;
	wbs_cab <= #1 wbs_cab_n;
	wbs_sel <= #1 wbs_sel_n;
     end
   always @(posedge wb_clk_i or posedge wb_rst_i)
     begin
	if (wb_rst_i)
	  wbs_cyc <= #1 0;
	else
	  wbs_cyc <= #1 wbs_cyc_n;
     end
   reg [31:3] wbs_adr_r;
   reg wbs_adr_start, wbs_adr_inc;
   always @(posedge wb_clk_i)
     begin
	if (wbs_adr_start)
	  wbs_adr_r <= #1 wbs_adr_n;
	else if (wbs_adr_inc)
	  wbs_adr_r <= #1 wbs_adr_r + 1'b1;
     end
   always @(/*AS*/wbs_adr_r)
     wbs_adr = {wbs_adr_r, 3'b000};
   
   parameter [2:0] 
		S_IDLE   = 3'h0,
		S_CMD    = 3'h1, /* accept command */
		S_D_REQ  = 3'h2, /* request desc   */
		S_B_REQ  = 3'h3, /* request buffer */
		S_B_WAIT = 3'h4, /* wait fifo      */
		S_NEXT   = 3'h5, /* next desc      */
		S_END    = 3'h6, /* done           */
		S_PANIC  = 3'h7; /* error state    */
   
   /* state register */
   reg [2:0] state, state_n;
   always @(posedge wb_clk_i or posedge wb_rst_i)
     begin
	if (wb_rst_i)
	  state <= #1 S_IDLE;
	else
	  state <= #1 state_n;
     end
   
   reg cnt, cnt_n;
   reg io, io_n;
   reg [2:0] err, err_n;
   always @(posedge wb_clk_i)
     begin
	err   <= #1 err_n;
	cnt   <= #1 cnt_n;
	io    <= #1 io_n;
     end

   /* last */
   reg 		 sg_last, sg_last_n;
   reg [15:0] 	 sg_len,  sg_len_n;
   reg [31:3] 	 sg_addr, sg_addr_n;
   reg [31:3] 	 sg_next, sg_next_n;
   always @(posedge wb_clk_i)
     begin
	sg_last <= #1 sg_last_n;
	sg_next <= #1 sg_next_n;
     end

   reg sg_addr_start, sg_addr_inc;
   always @(posedge wb_clk_i)
     begin
	if (sg_addr_start) begin
	   sg_addr <= #1 wbs_dat_o[31:3];
	   sg_len  <= #1 wbs_dat64_o[18:3];
	end else if (sg_addr_inc) begin
	   sg_addr <= #1 sg_addr + 1'b1;
	   sg_len  <= #1 sg_len  - 1'b1;
	end
     end

   always @(/*AS*/cnt or err or io or rw or sg_addr
	    or sg_last or sg_len or sg_next or ss_adr
	    or ss_dat or ss_dc or ss_done or ss_end
	    or ss_start or ss_stop or ss_we or state
	    or wbs_ack or wbs_adr or wbs_cab or wbs_cyc
	    or wbs_dat64_o or wbs_err or wbs_rty or wbs_sel
	    or wbs_stb or wbs_we)
     begin
	state_n   = state;

	sg_last_n = sg_last;
	sg_next_n = sg_next;

	sg_addr_start = 0;
	sg_addr_inc   = 0;

	wbs_adr_start = 0;
	wbs_adr_inc   = 0;
	
	/* wb */
	wbs_adr_n = wbs_adr;
	wbs_cyc_n = wbs_cyc;
	wbs_stb_n = wbs_stb;
	wbs_we_n  = wbs_we;
	wbs_cab_n = wbs_cab;
	wbs_sel_n = wbs_sel;

	/* internal */
	err_n = err;
	cnt_n = cnt;
	io_n  = io;
	ss_xfer = 1'b0;
	ss_last = 1'b0;
	
	case (state)
	  S_IDLE: begin 
	     if (ss_we)
	       state_n = S_CMD;
	  end
	  
	  S_CMD: begin
	     case (ss_adr[1:0]) 
	       2'b00: begin /* next_desc, ctrl_addr */
	       end
	       2'b01: begin /* dc_fc, u0 */
	       end
	       2'b10: begin /* src_desc, u1 */
		  if (rw == 1'b0)
		    sg_next_n = ss_dat[31:3];
	       end
	       2'b11: begin /* dst_desc, u2 */
		  if (rw == 1'b1)
		    sg_next_n = ss_dat[31:3];
		  sg_last_n = 1'b0;
		  if (rw == 1'b1 && ss_dc[2] == 0)
		    state_n = S_IDLE;
		  else if (rw == 1'b0 && ss_dc[1] == 0)
		    state_n = S_IDLE;
		  else 
		    state_n = S_NEXT;
	       end
	     endcase // case(ss_adr[1:0])
	  end // case: S_CMD
	  
	  S_D_REQ: begin
	     wbs_cyc_n = 1'b1;
	     wbs_stb_n = 1'b1;
	     wbs_we_n  = 1'b0;
	     wbs_cab_n = 1'b1;
	     wbs_sel_n = 4'b1111;
	     
	     case ({wbs_ack, wbs_rty, wbs_err})
	       3'b100: begin
		  wbs_adr_inc = 1;
		  if (cnt == 0) begin
		     sg_last_n = wbs_dat64_o[20];
		     sg_addr_start = 1;
		     cnt_n = cnt + 1;
		  end else begin
		     sg_next_n = wbs_dat64_o[31:3];
		     wbs_cyc_n = 1'b0;
		     wbs_we_n  = 1'b0;
		     state_n   = S_B_WAIT;
		  end
	       end // case: 3'b100
	       
	       3'b010: begin
	       end
	       
	       3'b001: begin
		  err_n   = state;
		  state_n = S_PANIC;
	       end 
	     endcase
	  end
	  
	  S_B_REQ: begin
	     wbs_cyc_n = 1'b1;
	     wbs_stb_n = 1'b1;
	     wbs_we_n  = rw;
	     wbs_cab_n = 1'b1;
	     wbs_sel_n = 4'h0;

	     case ({wbs_ack, wbs_rty, wbs_err})
	       3'b100: begin
		  wbs_adr_inc = 1;
		  sg_addr_inc = 1;
		  io_n      = 1'b1;
		  ss_xfer   = 1'b1;
		  if (sg_len == 1) begin
		     wbs_cyc_n = 1'b0;
		     wbs_we_n  = 1'b0;
		     state_n   = S_NEXT;
		     ss_last   = 1'b1;
		  end else if (ss_stop) begin
		     wbs_cyc_n = 1'b0;
		     wbs_we_n  = 1'b0;
		     state_n   = S_B_WAIT;
		  end
	       end
	       3'b010: begin
		  if (io) begin
		     wbs_cyc_n = 1'b0;
		     wbs_we_n  = 1'b0;
		     state_n   = S_B_WAIT;
		  end
	       end
	       3'b001: begin
		  err_n   = state;
		  state_n = S_PANIC;
	       end
	     endcase
	  end

	  S_B_WAIT: begin
	     if (ss_end) begin
		state_n = S_END;
	     end else if (ss_start) begin
		wbs_adr_start = 1;
		wbs_adr_n = sg_addr;
		wbs_cyc_n = 1'b1;
		wbs_stb_n = 1'b1;
		wbs_we_n  = rw;
		wbs_cab_n = 1'b1;
		wbs_sel_n = 4'h0;
		state_n   = S_B_REQ;
		io_n      = 1'b0;
	     end
	  end

	  S_NEXT: begin
	     if (ss_end) begin
		state_n = S_END;
	     end if (sg_last) begin
		state_n = S_END;
	     end else begin
		state_n = S_D_REQ;
		wbs_adr_start = 1;
		wbs_adr_n = sg_next;
		wbs_cyc_n = 1'b1;
		wbs_stb_n = 1'b1;
		wbs_we_n  = 1'b0;
		wbs_cab_n = 1'b1;
		wbs_sel_n = 4'h0;

		cnt_n = 0;
	     end
	  end
	  
	  S_END: begin
	     if (ss_done) begin /* XXXX reset all values */
		state_n = S_IDLE;
	     end
	  end
	  
	endcase // case(state)
     end

   /*output for debug purpose */
   always @(/*AS*/sg_last or state)
     sg_state = {sg_last, 4'h0, state[2:0]};

   always @(/*AS*/sg_len)
     sg_desc = {sg_len};

   output c_done;
   assign c_done = (state == S_END || state == S_IDLE);
   
endmodule // ss_copy