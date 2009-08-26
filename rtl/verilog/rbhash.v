/************************************************************************
 *     File Name  : copy.v
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
module rbhash(/*AUTOARG*/
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
   wire 	 endn;

   wire 	 pop;
   wire [63:0] 	 dout;
   wire 	 dout_valid;
   wire [7:0] 	 din;

   rabin rabin (
		// Outputs
		.pop			(pop),
		.dout			(dout[63:0]),
		.dout_valid		(dout_valid),
		// Inputs
		.clk			(wb_clk_i),
		.resetn			(m_enable),
		.din			(din[7:0]),
		.empty			(m_src_empty));

   reg 		 getn_reg;
   
   reg 		 rb_putn;
   reg [63:0] 	 rb_hash;
   
   assign 	 m_src_getn = dc[8] ? getn_reg   :  1'bz;
   assign 	 m_dst_putn = dc[8] ? rb_putn    :  1'bz;
   assign 	 m_dst      = dc[8] ? rb_hash    : 64'hz;
   
   assign 	 m_endn     = dc[8] ? (!endn)    :  1'bz;
   assign 	 m_dst_last = dc[8] ? m_src_last :  1'bz;
   
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

   reg getn_next;
   always @(posedge wb_clk_i or posedge wb_rst_i)
     begin
	if (wb_rst_i) begin
	   getn_reg <= #1 1'b1;
	end else begin
	   getn_reg <= #1 getn_next;
	end
     end

   reg data_valid_next;
   reg [2:0] iidxL;
   always @(posedge wb_clk_i or posedge wb_rst_i)
     begin
	if (wb_rst_i) begin
	   iidxL <= #1 3'h0;
	end else if (data_valid_next) begin
	   iidxL <= #1 iidxL + 1'b1;
	end
     end
   
   always @(/*AS*/dc or iidxL or m_dst_full or m_enable
	    or m_src_almost_empty or m_src_empty
	    or m_src_last or pop or state)
     begin
	state_n = state;
	
	getn_next = 1'b1;
	data_valid_next = 1'b0;
	
	case (state)
	  S_IDLE: begin
	     if (m_enable && dc[8] && (!m_dst_full) && (!m_src_empty)) begin
		state_n = S_RUN;
	     end
	  end
	  
	  S_RUN:  begin
	     if (m_src_last) begin
		state_n = S_END;
		data_valid_next = pop;
	     end else if (m_src_empty || m_src_almost_empty) begin
		state_n = S_WAIT;
	     end else if (iidxL == 3'b110 && pop) begin
		getn_next = 0;
		data_valid_next = pop;
	     end else begin
		data_valid_next = pop;
	     end
	  end
	  
	  S_WAIT: begin
	     if ((!m_dst_full) && (!m_src_empty)) begin
		state_n = S_RUN;
	     end 
	  end
	  
	  S_END:  begin
	  end
	  
	endcase
     end

   assign din  = iidxL == 3'h0 ? m_src[07:00] :
		 iidxL == 3'h1 ? m_src[15:08] :
		 iidxL == 3'h2 ? m_src[23:16] :
		 iidxL == 3'h3 ? m_src[31:24] :
		 iidxL == 3'h4 ? m_src[39:32] :
		 iidxL == 3'h5 ? m_src[47:40] :
		 iidxL == 3'h6 ? m_src[55:48] :	 m_src[63:56];
   assign endn = state == S_END;
   
   reg [19:0] buf_cnt;
   always @(posedge wb_clk_i or posedge wb_rst_i)
     begin
	if (wb_rst_i) begin
	   buf_cnt <= #1 12'h0;
	end else if (dout_valid) begin
	   buf_cnt <= #1 buf_cnt + 1'b1;
	end
     end
   wire [12:0] rb_cnt = buf_cnt;
   reg 	       rb_d1;
   
   reg [10:0]  rb_min;
   always @(posedge wb_clk_i or posedge wb_rst_i)
     begin
	if (wb_rst_i) begin
	   rb_min <= #1 11'h0;
	end else if (rb_d1) begin
	   rb_min <= #1 11'h0;
	end else if (dout_valid) begin
	   rb_min <= #1 rb_min + 1'b1;
	end
     end

   reg rb_min_passed;
   always @(posedge wb_clk_i)
     begin
	if (wb_rst_i) begin
	   rb_min_passed <= #1 1'b0;
	end else if (rb_d1) begin
	   rb_min_passed <= #1 1'b0;
	end else if (&rb_min & dout_valid) begin
	   rb_min_passed <= #1 1'b1;
	end 
     end
   /* 1) buffer == block size
      2) buffer > min block size and last 12 bit is magic number
    */
   wire case0 = &rb_cnt;
   wire case1 = (~rb_min_passed && (&rb_min)) | rb_min_passed;
   wire case2 = dout[11:0] == 12'h78;
   always @(posedge wb_clk_i)
     begin
	if (state != S_END & dout_valid & 
	    (case0 | (case1 & case2))) begin
	   rb_putn <= #1 1'b0;
	   rb_d1   <= #1 1'b1;
	   rb_hash <= #1 dout;
	end else if (rb_d1) begin
	   rb_putn <= #1 1'b0;
	   rb_hash <= #1 buf_cnt;
	   rb_d1   <= #1 1'b0;
	end else if (m_src_last) begin // fake last
	   rb_putn <= #1 1'b0;
	   rb_hash <= #1 buf_cnt;
	   rb_d1   <= #1 1'b0;
	end else begin
	   rb_d1   <= #1 1'b0;
	   rb_putn <= #1 1'b1;
	end
     end
   
endmodule // fill
// Local Variables:
// verilog-library-directories:("." "/p/hw/systemc_rabinpoly/rtl/verilog")
// verilog-library-files:("/some/path/technology.v" "/some/path/tech2.v")
// verilog-library-extensions:(".v" ".h")
// End:
