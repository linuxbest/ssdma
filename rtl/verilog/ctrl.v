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
/*
 *  本模块是 DMA 控制的核心部分，面临这样一些问题。
 * 1: 保证两个通道按照设计规范工作。
 * 2: ndir dirty 处理。
 * 3: resume 处理。
 * 4: 只有一个 job 的处理。
 * 
 * S_IDLE: 只能进入 S_CMD0 状态，有两种情况，
 *        1: ndar_dirty  
 *        2: append      set append mode to 1, into S_CMD0
 *         
 * S_CMD0: 读取 job desc，进入 S_NEXT0 状态
 * 
 * S_NEXT0:判断 dc0[14]，为 1 进入 S_CMD0 或者 S_CMD1, 否则进入 S_WAIT0
 *         
 * S_CMD1: 读取 job desc, 进入 S_WAIT0
 * 
 * S_WAIT0:等待 c0 c1 结束，如果需要处理 ctl 进入 CTL0， 
 *         否则 进入 S_TR0
 * 
 * S_CTL0: 写入 ctl 信息，进入 S_TR0
 * 
 * S_TR0:  依据 dc0[14] 进入 S_WAIT1 或者 S_IDLE
 * 
 * S_WAIT1: 等待 c2 c3 结束， 如果需要处理 ctl 进入 CTL1，
 *          否则进入 S_TR1
 * 
 * S_CTL1: 写入 ctl 信息，进入 S_NEXT1 或者 S_IDLE
 *  
 * S_TR1:  依据 dc1[14] 进入 S_NEXT1 或者 S_IDLE
 * 
 * S_NEXT1: 进入 S_CMD0 
 * 
 */
module ctrl(/*AUTOARG*/
   // Outputs
   wbs_cyc4, wbs_stb4, wbs_we4, wbs_cab4, wbs_sel4,
   wbs_adr4, wbs_dat_i4, wbs_dat64_i4, ss_we0, ss_we1,
   ss_we2, ss_we3, ss_done0, ss_done1, ss_done2, ss_done3,
   ss_dat0, ss_dat1, ss_dat2, ss_dat3, ss_adr0, ss_adr1,
   ss_adr2, ss_adr3, ss_dc0, ss_dc1, ss_dc2, ss_dc3,
   wb_int_o, dar, csr, ndar_dirty_clear, busy, append_clear,
   dc0, dc1, ctl_adr0, ctl_adr1, next_desc, m_reset0,
   m_reset1, ctrl_state,
   // Inputs
   wb_clk_i, wb_rst_i, wbs_dat_o4, wbs_dat64_o4, wbs_ack4,
   wbs_err4, wbs_rty4, c_done0, c_done1, c_done2, c_done3,
   ndar_dirty, ndar, wb_int_clear, append, enable
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
   output [23:0] ss_dc0,
		 ss_dc1,
		 ss_dc2,
		 ss_dc3;
   output 	 wb_int_o;
   
   output [31:0] dar;
   output [7:0]  csr;
   
   input 	 ndar_dirty;
   output 	 ndar_dirty_clear;
   input [31:3]  ndar;
   
   input 	 wb_int_clear;
   input 	 append, enable;
   output 	 busy;
   
   output 	 append_clear;
   output [23:0] dc0, dc1;
   output [31:3] ctl_adr0,
		 ctl_adr1,
		 next_desc;
   
   output 	 m_reset0;
   output 	 m_reset1;

   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg			append_clear;
   reg [7:0]		csr;
   reg [31:0]		dar;
   reg			m_reset0;
   reg			m_reset1;
   reg			ndar_dirty_clear;
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
		S_CMD0   = 4'h1,
		S_NEXT0  = 4'h2,
		S_CMD1   = 4'h3,
		S_WAIT0  = 4'h4,
		S_CTL0   = 4'h5,
		S_TR0    = 4'h6,
		S_WAIT1  = 4'h7,
		S_CTL1   = 4'h8,
		S_TR1    = 4'h9,
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

   reg append_clear_n;
   always @(posedge wb_clk_i or posedge wb_rst_i)
     begin
	if (wb_rst_i) begin
	   append_clear <= #1 0;
	end else begin
	   append_clear <= #1 append_clear_n;
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
   
   reg append_mode, append_mode_n;
   always @(posedge wb_clk_i or posedge wb_rst_i)
     begin
	if (wb_rst_i) begin
	   wbs_cyc4    <= #1 0;
	   append_mode <= #1 0;
	end else begin
	   wbs_cyc4    <= #1 wbs_cyc4_n;
	   append_mode <= #1 append_mode_n;
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

   assign ss_we0  = state == S_CMD0 && wbs_ack4 && append_mode == 0;
   assign ss_we1  = state == S_CMD0 && wbs_ack4 && append_mode == 0;
   assign ss_we2  = state == S_CMD1 && wbs_ack4;
   assign ss_we3  = state == S_CMD1 && wbs_ack4;

   assign ss_dat0 = wbs_dat64_o4;
   assign ss_dat1 = wbs_dat64_o4;
   assign ss_dat2 = wbs_dat64_o4;
   assign ss_dat3 = wbs_dat64_o4;

   assign ss_done0= state == S_TR0;
   assign ss_done1= state == S_TR0;
   assign ss_done2= state == S_TR1;
   assign ss_done3= state == S_TR1;
   
   assign busy    = state != S_IDLE;
   
   reg [31:3] cdar, dar_r, dar_n;
   always @(/*AS*/dar_r)
     dar = {dar_r, 3'b000};
   always @(posedge wb_clk_i or posedge wb_rst_i)
     begin
	if (wb_rst_i)
	  dar_r <= #1 29'h0;
	else 
	  dar_r <= #1 dar_n;
     end

   reg [31:3] ctl_adr0, 
	      ctl_adr1, 
	      next_desc;
   reg [23:0] dc0, 
	      dc1;
   always @(posedge wb_clk_i)
     begin
	if (state == S_CMD0 && wbs_ack4) begin
	   case (inc)
	     2'b00: begin
		next_desc <= #1 wbs_dat64_o4[31:3];
		cdar      <= #1 wbs_adr4_r;
		ctl_adr0  <= #1 wbs_dat_o4[31:3];
	     end
	     2'b01: begin
		dc0       <= #1 wbs_dat64_o4[23:0];
	     end 
	   endcase
	end else if (state == S_CMD1 && wbs_ack4) begin
	   case (inc)
	     2'b00: begin
		next_desc <= #1 wbs_dat64_o4[31:3];
		cdar      <= #1 wbs_adr4_r;
		ctl_adr1  <= #1 wbs_dat_o4[31:3];
	     end
	     2'b01: begin
		dc1       <= #1 wbs_dat64_o4[23:0];
	     end 
	   endcase
	end else if (m_reset0) begin // if (state == S_CMD1 && wbs_ack4)
	   dc0 <= #1 0;
	end else if (m_reset1) begin
	   dc1 <= #1 0;
	end
     end // always @ (posedge wb_clk_i)
   assign ss_dc0 = dc0;
   assign ss_dc1 = dc0;
   assign ss_dc2 = dc1;
   assign ss_dc3 = dc1;
   
   reg wb_int_next, wb_int_set;
   always @(posedge wb_clk_i or posedge wb_rst_i)
     begin
	if (wb_rst_i)
	  wb_int_o <= #1 1'b0;
	else
	  wb_int_o <= #1 wb_int_next;
     end
   always @(/*AS*/wb_int_clear or wb_int_o or wb_int_set)
     begin
	wb_int_next = wb_int_o;
	case ({wb_int_clear, wb_int_set})
	  2'b00: ;
	  2'b01: wb_int_next = 1;
	  2'b10: wb_int_next = 0;
	  2'b11: ;
	endcase
     end
   
   always @(/*AS*/append or append_mode or c_done0
	    or c_done1 or c_done2 or c_done3 or cdar
	    or ctl_adr0 or ctl_adr1 or dar or dar_r or dc0
	    or dc1 or enable or inc or ndar or ndar_dirty
	    or next_desc or state or wbs_ack4 or wbs_cab4
	    or wbs_cyc4 or wbs_err4 or wbs_rty4 or wbs_sel4
	    or wbs_stb4 or wbs_we4)
     begin
	state_n = state;
	append_clear_n = 0;
	append_mode_n  = append_mode;

	/* WB signal */
	wbs_adr4_n = 0;
	wbs_cyc4_n = wbs_cyc4;
	wbs_stb4_n = wbs_stb4;
	wbs_we4_n  = wbs_we4;
	wbs_cab4_n = wbs_cab4;
	wbs_sel4_n = wbs_sel4;

	inc_reset  = 0;
	inc_active = 0;

	dar_n      = dar_r;
	wb_int_set = 0;
	ndar_dirty_clear_n = 0;
	
	case (state)
	  S_IDLE:   begin
	     if (enable && ndar_dirty) begin
		ndar_dirty_clear_n = 1;
		wbs_adr4_n = ndar;
		
		wbs_cyc4_n = 1'b1;
		wbs_stb4_n = 1'b1;
		wbs_we4_n  = 1'b0;
		wbs_cab4_n = 1'b1;
		wbs_sel4_n = 4'b1111;
		state_n    = S_CMD0;
		inc_reset  = 1;
	     end if (enable && append) begin
		append_mode_n = 1;
		wbs_adr4_n = dar_r;
		
		wbs_cyc4_n = 1'b1;
		wbs_stb4_n = 1'b1;
		wbs_we4_n  = 1'b0;
		wbs_cab4_n = 1'b1;
		wbs_sel4_n = 4'b1111;
		state_n    = S_CMD0;
		inc_reset  = 1;
	     end // if (append)
	  end
	  
	  S_CMD0:   begin
	     case ({wbs_ack4, wbs_rty4, wbs_err4})
	       3'b100: begin
		  inc_active = 1;
		  case (inc)
		    2'b00: ;
		    2'b01: ;
		    2'b10: ;
		    2'b11: begin
		       wbs_cyc4_n = 0;
		       state_n    = S_NEXT0;
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
	     if (dc0[14]) begin
		wbs_adr4_n = next_desc;
		
		wbs_cyc4_n = 1'b1;
		wbs_stb4_n = 1'b1;
		wbs_we4_n  = 1'b0;
		wbs_cab4_n = 1'b1;
		wbs_sel4_n = 4'b1111;

		state_n    = append_mode ? S_CMD0 : S_CMD1;
		inc_reset  = 1;
	     end else begin
		state_n    = S_WAIT0;
	     end // else: !if(dc0[14])
	     if (append_mode) begin
		append_clear_n= 1'b1;
		append_mode_n = 1'b0;
	     end
	  end
	  
	  S_CMD1:   begin
	     case ({wbs_ack4, wbs_rty4, wbs_err4})
	       3'b100: begin
		  inc_active = 1;
		  case (inc)
		    2'b00: ;
		    2'b01: ;
		    2'b10: ;
		    2'b11: begin
		       wbs_cyc4_n = 0;
		       state_n    = S_WAIT0;
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
		   
		   inc_reset  = 1;
		   state_n    = S_CTL0;
		end else begin
		   state_n    = S_TR0;
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
		       state_n    = S_TR0;
		    end
		  endcase // case(inc)
	       end
	       3'b010: begin
	       end
	       3'b001: begin
	       end
	     endcase // case({wbs_ack4, wbs_rty4, wbs_err4})
	  end // case: S_CTL0

	  S_TR0:   begin
	     if (dc0[14]) begin
		state_n = S_WAIT1;
	     end else begin
		state_n = S_IDLE;
	     end
	     dar_n = cdar;
	     wb_int_set = dc0[15];
	  end
	  
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
		   state_n   = S_CTL1;
		end else begin
		   state_n   = S_TR1;
		end
	     end
	  end // case: S_WAIT1
	  
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
		       state_n    = S_TR1;
		    end
		  endcase // case(inc)
	       end
	       3'b010: begin
	       end
	       3'b001: begin
	       end
	     endcase // case({wbs_ack4, wbs_rty4, wbs_err4})
	  end // case: S_CTL1
	  
	  S_TR1:    begin
	     if (dc1[14]) 
	       state_n = S_NEXT1;
	     else
	       state_n = S_IDLE;
	     dar_n = cdar;
	     wb_int_set = dc1[15];
	  end
	  
	  S_NEXT1:  begin
	     wbs_adr4_n = next_desc;
	     
	     wbs_cyc4_n = 1'b1;
	     wbs_stb4_n = 1'b1;
	     wbs_we4_n  = 1'b0;
	     wbs_cab4_n = 1'b1;
	     wbs_sel4_n = 4'b1111;
	     state_n    = S_CMD0;
	     inc_reset  = 1;
	  end // case: S_NEXT1
	  
	endcase // case(state)
     end // always @ (...
  
   /* DEBUG */
   output [7:0] ctrl_state;
   assign 	ctrl_state = state;

   always @(posedge wb_clk_i or posedge wb_rst_i)
     if (wb_rst_i) 
       m_reset0 <= #1 1;
     else if (state == S_TR0)
       m_reset0 <= #1 1;
     else
       m_reset0 <= #1 0;

   always @(posedge wb_clk_i or posedge wb_rst_i)
     if (wb_rst_i) 
       m_reset1 <= #1 1;
     else if (state == S_TR1)
       m_reset1 <= #1 1;
     else
       m_reset1 <= #1 0;
   
endmodule // ctrl

  