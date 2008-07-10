/************************************************************************
 *     File Name  : ctrl.v
 *        Version :
 *           Date : 
 *    Description : 
 *   Dependencies :
 *
 *        Company : Beijing Soul Tech.
 *
 *   Copyright (C) 2008 Beijing Soul tech.
 *
 ***********************************************************************/
module ctrl(/*AUTOARG*/
   // Outputs
   wbs_cyc4, wbs_stb4, wbs_we4, wbs_cab4, wbs_sel4,
   wbs_adr4, wbs_dat_i4, wbs_dat64_i4, ss_we0, ss_we1,
   ss_we2, ss_we3, ss_done0, ss_done1, ss_done2, ss_done3,
   ss_dat0, ss_dat1, ss_dat2, ss_dat3, ss_adr0, ss_adr1,
   ss_adr2, ss_adr3, wb_int_o, dar, csr, ndar_dirty_clear,
   int_ack_clear, busy, resume_clear,
   // Inputs
   wb_clk_i, wb_rst_i, wbs_dat_o4, wbs_dat64_o4, wbs_ack4,
   wbs_err4, wbs_rty4, c_done0, c_done1, c_done2, c_done3,
   ndar_dirty, ndar, int_ack, resume, enable
   );

   input wb_clk_i;
   input wb_rst_i;

   /* WB interface */
   output wbs_cyc4, 		// cycle signal
	  wbs_stb4, 		// strobe 
	  wbs_we4, 		// we 
	  wbs_cab4;		// 
   output [3:0] wbs_sel4;	// byte select
   output [31:0] wbs_adr4, 	// address 
		 wbs_dat_i4, 	// data output
		 wbs_dat64_i4;	// data output high 64
   input [31:0]  wbs_dat_o4,	// data input
		 wbs_dat64_o4;	// data input high 64
   input 	 wbs_ack4, 	// acknowledge
		 wbs_err4, 	// error report
		 wbs_rty4;	// retry report

   output 	 ss_we0,
		 ss_we1,
		 ss_we2,
		 ss_we3;
   
   output 	 ss_done0,
		 ss_done1,
		 ss_done2,
		 ss_done3;
   
   output [31:0] ss_dat0,
		 ss_dat1,
		 ss_dat2,
		 ss_dat3;
   
   output [1:0]  ss_adr0,
		 ss_adr1,
		 ss_adr2,
		 ss_adr3;
   input 	 c_done0, 
		 c_done1,
		 c_done2,
		 c_done3;
   
   output 	 wb_int_o;
   
   output [31:0] dar;
   output [7:0]  csr;
   
   input 	 ndar_dirty;
   output 	 ndar_dirty_clear;
   input [31:3]  ndar;
   
   input 	 int_ack;
   output 	 int_ack_clear;
   input 	 resume, enable;
   output 	 busy;
   
   output 	 resume_clear;

   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg			busy;
   reg [7:0]		csr;
   reg [31:0]		dar;
   reg			int_ack_clear;
   reg			ndar_dirty_clear;
   reg			resume_clear;
   reg			ss_done0;
   reg			ss_done1;
   reg			ss_done2;
   reg			ss_done3;
   reg			wb_int_o;
   reg [31:0]		wbs_adr4;
   reg			wbs_cab4;
   reg			wbs_cyc4;
   reg [31:0]		wbs_dat64_i4;
   reg [31:0]		wbs_dat_i4;
   reg [3:0]		wbs_sel4;
   reg			wbs_stb4;
   reg			wbs_we4;
   // End of automatics

   parameter [3:0]
		S_IDLE   = 4'h0,
		S_RESUME = 4'h1,
		S_NDAR   = 4'h2,
		S_CMD0   = 4'h3,
		S_NEXT0  = 4'h4,
		S_CMD1   = 4'h5,
		S_WAIT0  = 4'h6,
		S_CTL0   = 4'h7,
		S_WAIT1  = 4'h8,
		S_CTL1   = 4'h9,
		S_NEXT1  = 4'ha;
   reg [3:0]
	    state, state_n;

   always @(posedge wb_clk_i or posedge wb_rst_i)
     begin
	if (wb_rst_i)
	  state <= #1 S_IDLE;
	else
	  state <= #1 state_n;
     end

   reg resume_clear_n;
   always @(posedge wb_clk_i or posedge wb_rst_i)
     begin
	if (wb_rst_i) begin
	   resume_clear <= #1 0;
	end else begin
	   resume_clear <= #1 resume_clear_n;
	end
     end

   reg 	      wbs_cyc4_n,
	      wbs_stb4_n,
	      wbs_we4_n,
	      wbs_cab4_n;
   reg [3:0]  wbs_sel4_n;
   always @(posedge wb_clk_i)
     begin
	wbs_stb4 <= #1 wbs_stb4_n;
	wbs_we4  <= #1 wbs_we4_n;
	wbs_cab4 <= #1 wbs_cab4_n;
	wbs_sel4 <= #1 wbs_sel4_n;
     end
   
   reg inc_reset, inc_active;
   reg [31:3] wbs_adr4_r, wbs_adr4_n;
   always @(posedge wb_clk_i)
     begin
	if (inc_reset)
	  wbs_adr4_r <= #1 wbs_adr4_n;
	else if (inc_active)
	  wbs_adr4_r <= #1 wbs_adr4_r + 1;
     end
   always @(/*AS*/wbs_adr4_r)
     wbs_adr4 = {wbs_adr4_r, 3'b000};
   
   reg resume_mode, resume_mode_n;
   always @(posedge wb_clk_i or posedge wb_rst_i)
     begin
	if (wb_rst_i) begin
	   wbs_cyc4    <= #1 0;
	   resume_mode <= #1 0;
	end else begin
	   wbs_cyc4    <= #1 wbs_cyc4_n;
	   resume_mode <= #1 resume_mode_n;
	end
     end

   reg ndar_dirty_clear_n;
   always @(posedge wb_clk_i or posedge wb_rst_i)
     begin
	if (wb_rst_i) begin
	   ndar_dirty_clear <= #1 0;
	end else begin
	   ndar_dirty_clear <= #1 ndar_dirty_clear_n;
	end
     end

   reg [1:0] inc;
   always @(posedge wb_clk_i)
     begin
	if (inc_reset)
	  inc <= #1 2'b00;
	else if (inc_active)
	  inc <= #1 inc + 1'b1;
     end
   assign ss_adr0 = inc;
   assign ss_adr1 = inc;
   assign ss_adr2 = inc;
   assign ss_adr3 = inc;

   assign ss_we0  = state == S_CMD0 && wbs_ack4;
   assign ss_we1  = state == S_CMD0 && wbs_ack4;
   assign ss_we2  = state == S_CMD1 && wbs_ack4;
   assign ss_we3  = state == S_CMD1 && wbs_ack4;

   assign ss_dat0 = wbs_dat_o4;
   assign ss_dat1 = wbs_dat_o4;
   assign ss_dat2 = wbs_dat_o4;
   assign ss_dat3 = wbs_dat_o4;

   reg [31:3] cdar, cdar_n, dar_r, dar_n;
   always @(posedge wb_clk_i)
     begin
	cdar <= #1 cdar_n;
     end

   always @(posedge wb_clk_i)
     begin
	dar_r <= #1 dar_n;
     end
   always @(/*AS*/dar_r)
     dar = {dar_r, 3'b000};
   
   reg [31:3] next_desc, next_desc_n;
   reg [15:0] dc0, dc1;
   reg [31:3] ctl_adr0, ctl_adr1;
   
   always @(/*AS*/c_done0 or c_done1 or c_done2 or c_done3
	    or cdar or ctl_adr0 or ctl_adr1 or dar or dar_r
	    or dc0 or dc1 or inc or ndar or ndar_dirty
	    or next_desc or resume or resume_mode or state
	    or wbs_ack4 or wbs_adr4_r or wbs_cab4
	    or wbs_cyc4 or wbs_err4 or wbs_rty4 or wbs_sel4
	    or wbs_stb4 or wbs_we4)
     begin
	state_n = state;
	resume_clear_n = 0;
	resume_mode_n  = resume_mode;

	/* WB signal */
	wbs_adr4_n = 0;
	wbs_cyc4_n = wbs_cyc4;
	wbs_stb4_n = wbs_stb4;
	wbs_we4_n  = wbs_we4;
	wbs_cab4_n = wbs_cab4;
	wbs_sel4_n = wbs_sel4;

	inc_reset  = 0;
	inc_active = 0;

	cdar_n     = cdar;
	dar_n      = dar_r;
	
	case (state)
	  S_IDLE:   begin
	     if (ndar_dirty) begin
		ndar_dirty_clear_n = 1;
		wbs_adr4_n = ndar;
		
		wbs_cyc4_n = 1'b1;
		wbs_stb4_n = 1'b1;
		wbs_we4_n  = 1'b0;
		wbs_cab4_n = 1'b1;
		wbs_sel4_n = 4'b1111;
		state_n = S_CMD0;
		inc_reset = 1;
	     end if (resume) begin
		resume_mode_n = 1;
		wbs_adr4_n = dar;
		
		wbs_cyc4_n = 1'b1;
		wbs_stb4_n = 1'b1;
		wbs_we4_n  = 1'b0;
		wbs_cab4_n = 1'b1;
		wbs_sel4_n = 4'b1111;
		state_n = S_CMD0;
		inc_reset = 1;
	     end // if (resume)
	  end
	  
	  S_CMD0:   begin
	     case ({wbs_ack4, wbs_rty4, wbs_err4})
	       3'b100: begin
		  inc_active = 1;
		  case (inc)
		    2'b00: begin
		       cdar_n = wbs_adr4_r;
		    end
		    2'b01: ;
		    2'b10: ;
		    2'b11: begin
		       wbs_cyc4_n = 0;
		       state_n = S_NEXT0;
		    end
		  endcase // case(inc)
	       end
	       3'b010: begin
	       end
	       3'b001: begin
	       end
	     endcase // case({wbs_ack4, wbs_rty4, wbs_err4})
	  end
	  
	  S_NEXT0:  begin
	     if (resume_mode) begin
		dar_n = cdar;
		state_n = S_CMD0;
	     end else if (dc0[14]) begin
		wbs_adr4_n = next_desc;
		
		wbs_cyc4_n = 1'b1;
		wbs_stb4_n = 1'b1;
		wbs_we4_n  = 1'b0;
		wbs_cab4_n = 1'b1;
		wbs_sel4_n = 4'b1111;
		state_n = S_CMD1;
		inc_reset = 1;
	     end else begin
		state_n = S_WAIT0;
	     end
	  end
	  
	  S_CMD1:   begin
	     case ({wbs_ack4, wbs_rty4, wbs_err4})
	       3'b100: begin
		  inc_active = 1;
		  case (inc)
		    2'b00: begin
		       cdar_n = wbs_adr4_r;
		    end
		    2'b01: ;
		    2'b10: ;
		    2'b11: begin
		       wbs_cyc4_n = 0;
		       state_n = S_WAIT0;
		    end
		  endcase // case(inc)
	       end
	       3'b010: begin
	       end
	       3'b001: begin
	       end
	     endcase // case({wbs_ack4, wbs_rty4, wbs_err4})
	  end
	  
	  S_WAIT0:   begin
	     if (c_done0 && c_done1) begin
		if (dc0[7]) begin
		   wbs_adr4_n = ctl_adr0;
		   
		   wbs_cyc4_n = 1'b1;
		   wbs_stb4_n = 1'b1;
		   wbs_we4_n  = 1'b1;
		   wbs_cab4_n = 1'b1;
		   wbs_sel4_n = 4'b1111;
		   
		   inc_reset = 1;
		   state_n = S_CTL0;
		end // if (dc0[7])
		else if (dc0[14]) begin
		   state_n = S_WAIT1;
		end
		else begin
		   state_n = S_IDLE;
		end
	     end // if (c0_done && c1_done)
	  end // case: S_WAIT0
	  	  
	  S_CTL0:  begin
	     case ({wbs_ack4, wbs_rty4, wbs_err4})
	       3'b100: begin
		  inc_active = 1;
		  case (inc)
		    2'b00: ;
		    2'b01: ;
		    2'b10: ;
		    2'b11: begin
		       wbs_cyc4_n = 0;
		       if (dc0[14]) begin
			  state_n = S_WAIT1;
		       end else begin
			  state_n = S_IDLE;
		       end
		    end
		  endcase // case(inc)
	       end
	       3'b010: begin
	       end
	       3'b001: begin
	       end
	     endcase // case({wbs_ack4, wbs_rty4, wbs_err4})
	  end // case: S_CTL0
	  
	  S_WAIT1:  begin
	     if (c_done2 && c_done3) begin
		if (dc1[7]) begin
		   wbs_adr4_n = ctl_adr1;
		   
		   wbs_cyc4_n = 1'b1;
		   wbs_stb4_n = 1'b1;
		   wbs_we4_n  = 1'b1;
		   wbs_cab4_n = 1'b1;
		   wbs_sel4_n = 4'b1111;
		   
		   inc_reset = 1;
		   state_n = S_CTL1;
		end // if (dc0[7])
		else if (dc0[14]) begin
		   state_n = S_NEXT1;
		end
		else begin
		   state_n = S_IDLE;
		end
	     end
	  end
	  
	  S_CTL1:   begin
	     case ({wbs_ack4, wbs_rty4, wbs_err4})
	       3'b100: begin
		  inc_active = 1;
		  case (inc)
		    2'b00: ;
		    2'b01: ;
		    2'b10: ;
		    2'b11: begin
		       wbs_cyc4_n = 0;
		       state_n = S_NEXT1;
		    end
		  endcase // case(inc)
	       end
	       3'b010: begin
	       end
	       3'b001: begin
	       end
	     endcase // case({wbs_ack4, wbs_rty4, wbs_err4})
	  end
	  
	  S_NEXT1:  begin
	     if (dc1[14]) begin
		wbs_adr4_n = next_desc;
		
		wbs_cyc4_n = 1'b1;
		wbs_stb4_n = 1'b1;
		wbs_we4_n  = 1'b0;
		wbs_cab4_n = 1'b1;
		wbs_sel4_n = 4'b1111;
		state_n = S_CMD0;
		inc_reset = 1;
	     end else begin
		state_n = S_IDLE;
	     end
	  end // case: S_NEXT1
	  
	endcase
     end // always @ (...
   
endmodule // ctrl

  