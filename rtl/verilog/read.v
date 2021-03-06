/************************************************************************
 *     File Name  : read.v
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
module read(/*AUTOARG*/
   // Outputs
   m_src_getn, m_dst_putn, m_dst, m_dst_last, m_endn,
   // Inputs
   wb_clk_i, wb_rst_i, m_enable, dc, m_src, m_src_last,
   m_src_almost_empty, m_src_empty, m_dst_almost_full,
   m_dst_full
   );
   input wb_clk_i;
   input wb_rst_i;
   input m_enable;
   
   input [23:0] dc;
   
   output 	m_src_getn;
   input [63:0] m_src;
   input 	m_src_last;
   input 	m_src_almost_empty;
   input 	m_src_empty;
   
   output 	m_dst_putn;
   output [63:0] m_dst;
   output 	 m_dst_last;
   input 	 m_dst_almost_full;
   input 	 m_dst_full;
   output 	 m_endn;
   
   wire 	 get;
   assign 	 m_src_getn = dc[8] ? (!get) : 1'bz;
   assign 	 m_endn     = dc[8] ? 1'b0   : 1'bz;
   assign 	 m_dst      = dc[8] ? 64'h0  : 64'hz;
   assign 	 m_dst_last = dc[8] ? 1'b0   : 1'bz;
   assign 	 m_dst_putn = dc[9] ? 1'b0   : 1'bz;
   
   parameter [1:0] 
		S_IDLE = 2'b00,
		S_RUN  = 2'b01,
		S_WAIT = 2'b10,
		S_END  = 2'b11;
   reg [1:0] 	   
		  state, state_n;
   always @(posedge wb_clk_i or posedge wb_rst_i)
     begin
	if (wb_rst_i)
	  state <= #1 S_IDLE;
	else
	  state <= #1 state_n;
     end
   
   always @(/*AS*/dc or m_enable or m_src_empty
	    or m_src_last or state)
     begin
	state_n = state;
	case (state)
	  S_IDLE: begin
	     if (m_enable && dc[8] && (!m_src_empty)) begin
		state_n = S_RUN;
	     end
	  end
	  
	  S_RUN:  begin
	     if (m_src_empty) begin
		state_n = S_WAIT;
	     end else if (m_src_last) begin
		state_n = S_END;
	     end
	  end
	  
	  S_WAIT: begin
	     if (m_src_last) begin
		state_n = S_END;
	     end else if (!m_src_empty) begin
		state_n = S_RUN;
	     end
	  end
	  
	  S_END:  begin
	  end
	  
	endcase
     end

   assign get = state == S_RUN;
   
endmodule // read
