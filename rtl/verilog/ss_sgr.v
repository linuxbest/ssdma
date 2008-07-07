/************************************************************************
 *     File Name  : ss_sgr.v
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

module ss_sgr(/*AUTOARG*/
   // Outputs
   wbs_cyc, wbs_stb, wbs_we, wbs_cab, wbs_sel, wbs_adr,
   wbs_dat_i, wbs_dat64_i, sg_state, sg_desc, sg_addr,
   sg_next,
   // Inputs
   wb_clk_i, wb_rst_i, wbs_dat_o, wbs_dat64_o, wbs_ack,
   wbs_err, wbs_rty, wbs_gnt, ss_dat, ss_we, ss_adr,
   ss_done, fifo_half_empty
   );
   /*AUTOOUTPUT*/
   /*AUTOINPUT*/
   /*AUTOWIRE*/

   input wb_clk_i;
   input wb_rst_i;
   
   /* WB interface */
   output wbs_cyc, wbs_stb, wbs_we, wbs_cab;
   output [3:0] wbs_sel;
   output [31:0] wbs_adr, wbs_dat_i, wbs_dat64_i;
   input [31:0]  wbs_dat_o, wbs_dat64_o;
   input 	 wbs_ack, wbs_err, wbs_rty, wbs_gnt;

   input [31:0]  ss_dat;
   input 	 ss_we;
   input [1:0] 	 ss_adr;
   input 	 ss_done;
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
   input 	 fifo_half_empty;
   
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [15:0]		sg_desc;
   reg [7:0]		sg_state;
   reg [31:0]		wbs_dat64_i;
   reg [31:0]		wbs_dat_i;
   // End of automatics
   
   /* wb register */
   reg [31:0] 	 wbs_adr, wbs_adr_n;
   reg 		 wbs_cyc, wbs_cyc_n;
   reg 		 wbs_stb, wbs_stb_n;
   reg 		 wbs_we,  wbs_we_n;
   reg 		 wbs_cab, wbs_cab_n;
   reg [3:0] 	 wbs_sel, wbs_sel_n;
   
   parameter [2:0] 
		S_IDLE   = 3'h0,
		S_CMD    = 3'h1, /* accept command */
		S_D_REQ  = 3'h2, /* request desc   */
		S_B_REQ  = 3'h3, /* request buffer */
		S_B_WAIT = 3'h4, /* wait fifo      */
		S_NEXT   = 3'h5, /* next desc      */
		S_END    = 3'h6, /* done           */
		S_PANIC  = 3'h7;
   
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
   reg [23:0] dc_fc ,dc_fc_n;
   always @(posedge wb_clk_i)
     begin
	err   <= #1 err_n;
	dc_fc <= #1 dc_fc_n;
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
	sg_len  <= #1 sg_len_n;
	sg_addr <= #1 sg_addr_n;
	sg_next <= #1 sg_next_n;
     end
   
   always @(/*AS*/cnt or dc_fc or err or fifo_half_empty
	    or io or sg_addr or sg_last or sg_len or ss_adr
	    or ss_dat or ss_done or ss_we or state
	    or wbs_ack or wbs_adr or wbs_cab or wbs_cyc
	    or wbs_dat64_o or wbs_dat_o or wbs_err
	    or wbs_rty or wbs_sel or wbs_stb or wbs_we)
     begin
	state_n = state;

	dc_fc_n   = dc_fc;
	
	sg_last_n = sg_last;
	sg_len_n  = sg_len;
	sg_addr_n = sg_addr;
	sg_next   = sg_next_n;
	
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
	
	case (state)
	  S_IDLE: begin
	     if (ss_we)
	       state_n = S_CMD;
	  end
	  
	  S_CMD: begin
	     case (ss_adr[1:0]) 
	       2'b00: begin
	       end
	       2'b01: begin 
		  dc_fc_n = ss_dat[23:0];
	       end
	       2'b10: begin 
		  sg_addr_n = ss_dat[31:3];
	       end
	       2'b11: begin
		  state_n = S_NEXT;
	       end
	     endcase // case(ss_adr[1:0])
	  end // case: S_CMD
	  
	  S_D_REQ: begin
	     wbs_adr_n = sg_addr;
	     wbs_cyc_n = 1'b1;
	     wbs_stb_n = 1'b1;
	     wbs_we_n  = 1'b0;
	     wbs_cab_n = 1'b1;
	     wbs_sel_n = 4'h0;
	     
	     case ({wbs_ack, wbs_rty, wbs_err})
	       3'b100: begin
		  if (cnt == 0) begin
		     sg_len_n = wbs_dat64_o[15:0];
		     sg_addr_n = wbs_dat_o[31:3];
		     cnt_n = cnt + 1;
		  end else begin
		     sg_next_n = wbs_dat64_o[31:3];
		     wbs_cyc_n = 0;
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
	     wbs_adr_n = sg_addr;
	     wbs_cyc_n = 1'b1;
	     wbs_stb_n = 1'b1;
	     wbs_we_n  = 1'b0;
	     wbs_cab_n = 1'b1;
	     wbs_sel_n = 4'h0;

	     case ({wbs_ack, wbs_rty, wbs_err})
	       3'b100: begin
		  sg_addr_n = sg_addr + 1; 
		  sg_len_n  = sg_len - 1;
		  if (sg_len_n == 0) begin
		     wbs_cab_n = 1'b0;
		     state_n   = S_NEXT;
		  end
	       end
	       3'b010: begin
		  if (io) begin
		     wbs_cab_n = 1'b0;
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
	     if (fifo_half_empty) begin
		wbs_adr_n = sg_addr;
		wbs_cyc_n = 1'b1;
		wbs_stb_n = 1'b1;
		wbs_we_n  = 1'b0;
		wbs_cab_n = 1'b1;
		wbs_sel_n = 4'h0;
		state_n   = S_B_REQ;
	     end
	  end

	  S_NEXT: begin
	     if (sg_last) begin
	       state_n = S_END;
	     end else begin
		state_n = S_D_REQ;

		wbs_adr_n = sg_addr;
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
   
endmodule // ss_copy