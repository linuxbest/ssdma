/************************************************************************
 *     File Name  : bridge.v
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
module bridge(/*AUTOARG*/
   // Outputs
   PCI_SERRn, wbs_dat_i, wbs_adr_i, wbs_sel_i, wbs_we_i,
   wbs_stb_i, wbs_cyc_i, wbs_cab_i, wb_rst_i, wb_clk_i,
   wbm_rty_i, wbm_err_i, wbm_ack_i, wbm_dat_i, wbm_dat64_i,
   // Inouts
   PCI_AD, PCI_AD64, PCI_CBE, PCI_CBE64, PCI_FRAMEn,
   PCI_IRDYn, PCI_TRDYn, PCI_DEVSELn, PCI_STOPn, PCI_LOCKn,
   PCI_REQn, PCI_RSTn, PCI_INTAn, PCI_INTBn, PCI_PERRn,
   PCI_PAR, PCI_REQ64n, PCI_ACK64n, PCI_PAR64,
   // Inputs
   PCI_CLK, PCI_IDSEL, PCI_GNTn, wbs_rty_o, wbs_err_o,
   wbs_ack_o, wbs_dat_o, wb_int_o, wbm_we_o, wbm_stb_o,
   wbm_cyc_o, wbm_cab_o, wbm_pref_o, wbm_sel_o, wbm_dat_o,
   wbm_dat64_o, wbm_adr_o
   );
   inout [31:0] PCI_AD;
   inout [31:0] PCI_AD64;
   inout [3:0] 	PCI_CBE;
   inout [3:0] 	PCI_CBE64;
   input        PCI_CLK;
   input        PCI_IDSEL;
   inout        PCI_FRAMEn;
   inout        PCI_IRDYn;
   inout        PCI_TRDYn;
   inout        PCI_DEVSELn;
   inout        PCI_STOPn;
   inout        PCI_LOCKn;
   input        PCI_GNTn;
   inout        PCI_REQn;
   inout        PCI_RSTn;
   inout        PCI_INTAn;
   inout        PCI_INTBn;
   inout        PCI_PERRn;
   output       PCI_SERRn;
   inout        PCI_PAR;
   inout        PCI_REQ64n;
   inout        PCI_ACK64n;
   inout        PCI_PAR64;

   /* WB slave */
   input wbs_rty_o,
	 wbs_err_o,
	 wbs_ack_o;
   input [31:0] wbs_dat_o;
   output [31:0] wbs_dat_i,
		 wbs_adr_i;
   output [3:0]  wbs_sel_i;
   output 	 wbs_we_i,
		 wbs_stb_i,
		 wbs_cyc_i,
		 wbs_cab_i;/*always 0 */
   
   /* WB */
   input 	 wb_int_o;
   output 	 wb_rst_i;
   output 	 wb_clk_i;
   assign        PCI_INTBn= 1'b1; /* must wire to GND */

   /* WB Master */
   input 	 wbm_we_o,
		 wbm_stb_o,
		 wbm_cyc_o,
		 wbm_cab_o,
		 wbm_pref_o;
   input [3:0] 	 wbm_sel_o;
   input [31:0]  wbm_dat_o,
		 wbm_dat64_o,
		 wbm_adr_o;
   output 	 wbm_rty_i,
		 wbm_err_i,
		 wbm_ack_i;
   output [31:0] wbm_dat_i,
		 wbm_dat64_i;

   wire [31:0] 	 AD_out;
   wire [31:0] 	 AD64_out;
   wire [31:0] 	 AD_en;
   wire [31:0] 	 AD64_en;
   wire [31:0] 	 AD_in   = PCI_AD;
   wire [31:0] 	 AD64_in = PCI_AD64;

   wire [3:0] 	 CBE_out;
   wire [3:0] 	 CBE64_out;
   wire [3:0] 	 CBE_en;
   wire [3:0] 	 CBE64_en;
   wire [3:0] 	 CBE_in  = PCI_CBE;
   wire [3:0] 	 CBE64_in= PCI_CBE64;

   wire 	 RST_in = PCI_RSTn;
   /*wire 	 RST_out,
		 RST_en;*/

   wire 	 INTA_in = PCI_INTAn;
   wire 	 INTA_en;
   wire 	 INTA_out;

   wire 	 REQ_en;
   wire 	 REQ_out;

   wire 	 FRAME_in = PCI_FRAMEn;
   wire 	 FRAME_out,
		 FRAME_en;
   
   wire 	 REQ64_in = PCI_REQ64n;
   wire 	 REQ64_out;
   wire 	 REQ64_en;

   wire 	 ACK64_in = PCI_ACK64n;
   wire 	 ACK64_out,
		 ACK64_en;

   wire 	 IRDY_in = PCI_IRDYn;
   wire 	 IRDY_out,
		 IRDY_en;

   wire 	 DEVSEL_in = PCI_DEVSELn;
   wire 	 DEVSEL_out,
		 DEVSEL_en;

   wire 	 TRDY_in = PCI_TRDYn;
   wire 	 TRDY_out,
		 TRDY_en;

   wire 	 STOP_in = PCI_STOPn;
   wire 	 STOP_out,
		 STOP_en;

   wire 	 PAR_in = PCI_PAR;
   wire 	 PAR_out,
		 PAR_en;

   wire 	 PAR64_in = PCI_PAR64;
   wire 	 PAR64_out,
		 PAR64_en;

   wire 	 PERR_in = PCI_PERRn;
   wire 	 PERR_out,
		 PERR_en;

   wire 	 SERR_out,
		 SERR_en;
   
   pci_bridge32 
     pci_bridge32(/* WB system signal */
		  .wb_clk_i(PCI_CLK),
		  .wb_rst_i(wb_rst_i),
		  .wb_rst_o(),
		  .wb_int_i(wb_int_o),
		  .wb_int_o(),
		  /* WB slave */
		  .wbs_adr_i(wbm_adr_o),
		  .wbs_dat_i(wbm_dat_o),
		  .wbs_dat64_i(wbm_dat64_o),
		  .wbs_dat_o(wbm_dat_i),
		  .wbs_dat64_o(wbm_dat64_i),
		  .wbs_sel_i(wbm_sel_o),
		  .wbs_cyc_i(wbm_cyc_o),
		  .wbs_stb_i(wbm_stb_o),
		  .wbs_we_i (wbm_we_o),
		  .wbs_cab_i(wbm_cab_o),
		  .wbs_pref_i(wbm_pref_o),
		  .wbs_ack_o(wbm_ack_i),
		  .wbs_rty_o(wbm_rty_i),
		  .wbs_err_o(wbm_err_i),
		  /* WB master */
		  .wbm_adr_o(wbs_adr_i),
		  .wbm_dat_i(wbs_dat_o),
		  .wbm_dat_o(wbs_dat_i),
		  .wbm_sel_o(wbs_sel_i),
		  .wbm_cyc_o(wbs_cyc_i),
		  .wbm_stb_o(wbs_stb_i),
		  .wbm_we_o (wbs_we_i),
		  .wbm_ack_i(wbs_ack_o),
		  .wbm_rty_i(wbs_rty_o),
		  .wbm_err_i(wbs_err_o),
		  /* pci interface */
		  .pci_clk_i    ( PCI_CLK ),
		  .pci_rst_i    ( PCI_RSTn ),
		  .pci_rst_o    ( ),
		  .pci_inta_i   ( INTA_in ),
		  .pci_inta_o   ( INTA_out),
		  .pci_rst_oe_o ( ),
		  .pci_inta_oe_o( INTA_en ),
		  /* arbitration pins */
		  .pci_req_o   ( REQ_out ),
		  .pci_req_oe_o( REQ_en ),
		  .pci_gnt_i   ( PCI_GNTn ),
		  
		  /* protocol pins */
		  .pci_frame_i     ( FRAME_in),
		  .pci_frame_o     ( FRAME_out ),
		  .pci_frame_oe_o  ( FRAME_en ),

		  .pci_req64_i     ( REQ64_in),
		  .pci_req64_o     ( REQ64_out ),
		  .pci_req64_oe_o  ( REQ64_en ),
		  
		  .pci_ack64_i     ( ACK64_in),
		  .pci_ack64_o     ( ACK64_out ),
		  .pci_ack64_oe_o  ( ACK64_en ),
		  
		  .pci_irdy_oe_o   ( IRDY_en ),
		  .pci_devsel_oe_o ( DEVSEL_en ),
		  .pci_trdy_oe_o   ( TRDY_en ),
		  .pci_stop_oe_o   ( STOP_en ),
		  .pci_ad_oe_o     ( AD_en ),
		  .pci_ad64_oe_o   ( AD64_en ),
		  .pci_cbe_oe_o    ( CBE_en) ,
		  .pci_cbe64_oe_o  ( CBE64_en) ,

		  .pci_irdy_i      ( IRDY_in ),
		  .pci_irdy_o      ( IRDY_out ),
		  
		  .pci_idsel_i     ( PCI_IDSEL ),
		  
		  .pci_devsel_i    ( DEVSEL_in ),
		  .pci_devsel_o    ( DEVSEL_out ),
		  
		  .pci_trdy_i      ( TRDY_in ),
		  .pci_trdy_o      ( TRDY_out ),
		  
		  .pci_stop_i      ( STOP_in ),
		  .pci_stop_o      ( STOP_out ),

		  /* data transfer pins */
		  .pci_ad_i (AD_in),
		  .pci_ad_o (AD_out),
		  
		  .pci_ad64_i (AD64_in),
		  .pci_ad64_o (AD64_out),
		  
		  .pci_cbe_i( CBE_in ),
		  .pci_cbe_o( CBE_out ),
		  
		  .pci_cbe64_i( CBE64_in ),
		  .pci_cbe64_o( CBE64_out ),

		  /* parity generation and checking pins */
		  .pci_par_i    ( PAR_in ),
		  .pci_par_o    ( PAR_out ),
		  .pci_par_oe_o ( PAR_en ),
		  
		  .pci_par64_i    ( PAR64_in ),
		  .pci_par64_o    ( PAR64_out ),
		  .pci_par64_oe_o ( PAR64_en ),
		  
		  .pci_perr_i   ( PERR_in ),
		  .pci_perr_o   ( PERR_out ),
		  .pci_perr_oe_o( PERR_en ),

		  // system error pin
		  .pci_serr_o   ( SERR_out ),
		  .pci_serr_oe_o( SERR_en ));


   bufif0 AD_buf0   ( PCI_AD[0],  AD_out[0], AD_en[0]);
   bufif0 AD_buf1   ( PCI_AD[1],  AD_out[1], AD_en[1]);
   bufif0 AD_buf2   ( PCI_AD[2],  AD_out[2], AD_en[2]);
   bufif0 AD_buf3   ( PCI_AD[3],  AD_out[3], AD_en[3]);
   bufif0 AD_buf4   ( PCI_AD[4],  AD_out[4], AD_en[4]);
   bufif0 AD_buf5   ( PCI_AD[5],  AD_out[5], AD_en[5]);
   bufif0 AD_buf6   ( PCI_AD[6],  AD_out[6], AD_en[6]);
   bufif0 AD_buf7   ( PCI_AD[7],  AD_out[7], AD_en[7]);
   bufif0 AD_buf8   ( PCI_AD[8],  AD_out[8], AD_en[8]);
   bufif0 AD_buf9   ( PCI_AD[9],  AD_out[9], AD_en[9]);
   bufif0 AD_buf10   ( PCI_AD[10],  AD_out[10], AD_en[10]);
   bufif0 AD_buf11   ( PCI_AD[11],  AD_out[11], AD_en[11]);
   bufif0 AD_buf12   ( PCI_AD[12],  AD_out[12], AD_en[12]);
   bufif0 AD_buf13   ( PCI_AD[13],  AD_out[13], AD_en[13]);
   bufif0 AD_buf14   ( PCI_AD[14],  AD_out[14], AD_en[14]);
   bufif0 AD_buf15   ( PCI_AD[15],  AD_out[15], AD_en[15]);
   bufif0 AD_buf16   ( PCI_AD[16],  AD_out[16], AD_en[16]);
   bufif0 AD_buf17   ( PCI_AD[17],  AD_out[17], AD_en[17]);
   bufif0 AD_buf18   ( PCI_AD[18],  AD_out[18], AD_en[18]);
   bufif0 AD_buf19   ( PCI_AD[19],  AD_out[19], AD_en[19]);
   bufif0 AD_buf20   ( PCI_AD[20],  AD_out[20], AD_en[20]);
   bufif0 AD_buf21   ( PCI_AD[21],  AD_out[21], AD_en[21]);
   bufif0 AD_buf22   ( PCI_AD[22],  AD_out[22], AD_en[22]);
   bufif0 AD_buf23   ( PCI_AD[23],  AD_out[23], AD_en[23]);
   bufif0 AD_buf24   ( PCI_AD[24],  AD_out[24], AD_en[24]);
   bufif0 AD_buf25   ( PCI_AD[25],  AD_out[25], AD_en[25]);
   bufif0 AD_buf26   ( PCI_AD[26],  AD_out[26], AD_en[26]);
   bufif0 AD_buf27   ( PCI_AD[27],  AD_out[27], AD_en[27]);
   bufif0 AD_buf28   ( PCI_AD[28],  AD_out[28], AD_en[28]);
   bufif0 AD_buf29   ( PCI_AD[29],  AD_out[29], AD_en[29]);
   bufif0 AD_buf30   ( PCI_AD[30],  AD_out[30], AD_en[30]);
   bufif0 AD_buf31   ( PCI_AD[31],  AD_out[31], AD_en[31]);
   bufif0 AD64_buf0   ( PCI_AD64[0],  AD64_out[0], AD64_en[0]);
   bufif0 AD64_buf1   ( PCI_AD64[1],  AD64_out[1], AD64_en[1]);
   bufif0 AD64_buf2   ( PCI_AD64[2],  AD64_out[2], AD64_en[2]);
   bufif0 AD64_buf3   ( PCI_AD64[3],  AD64_out[3], AD64_en[3]);
   bufif0 AD64_buf4   ( PCI_AD64[4],  AD64_out[4], AD64_en[4]);
   bufif0 AD64_buf5   ( PCI_AD64[5],  AD64_out[5], AD64_en[5]);
   bufif0 AD64_buf6   ( PCI_AD64[6],  AD64_out[6], AD64_en[6]);
   bufif0 AD64_buf7   ( PCI_AD64[7],  AD64_out[7], AD64_en[7]);
   bufif0 AD64_buf8   ( PCI_AD64[8],  AD64_out[8], AD64_en[8]);
   bufif0 AD64_buf9   ( PCI_AD64[9],  AD64_out[9], AD64_en[9]);
   bufif0 AD64_buf10   ( PCI_AD64[10],  AD64_out[10], AD64_en[10]);
   bufif0 AD64_buf11   ( PCI_AD64[11],  AD64_out[11], AD64_en[11]);
   bufif0 AD64_buf12   ( PCI_AD64[12],  AD64_out[12], AD64_en[12]);
   bufif0 AD64_buf13   ( PCI_AD64[13],  AD64_out[13], AD64_en[13]);
   bufif0 AD64_buf14   ( PCI_AD64[14],  AD64_out[14], AD64_en[14]);
   bufif0 AD64_buf15   ( PCI_AD64[15],  AD64_out[15], AD64_en[15]);
   bufif0 AD64_buf16   ( PCI_AD64[16],  AD64_out[16], AD64_en[16]);
   bufif0 AD64_buf17   ( PCI_AD64[17],  AD64_out[17], AD64_en[17]);
   bufif0 AD64_buf18   ( PCI_AD64[18],  AD64_out[18], AD64_en[18]);
   bufif0 AD64_buf19   ( PCI_AD64[19],  AD64_out[19], AD64_en[19]);
   bufif0 AD64_buf20   ( PCI_AD64[20],  AD64_out[20], AD64_en[20]);
   bufif0 AD64_buf21   ( PCI_AD64[21],  AD64_out[21], AD64_en[21]);
   bufif0 AD64_buf22   ( PCI_AD64[22],  AD64_out[22], AD64_en[22]);
   bufif0 AD64_buf23   ( PCI_AD64[23],  AD64_out[23], AD64_en[23]);
   bufif0 AD64_buf24   ( PCI_AD64[24],  AD64_out[24], AD64_en[24]);
   bufif0 AD64_buf25   ( PCI_AD64[25],  AD64_out[25], AD64_en[25]);
   bufif0 AD64_buf26   ( PCI_AD64[26],  AD64_out[26], AD64_en[26]);
   bufif0 AD64_buf27   ( PCI_AD64[27],  AD64_out[27], AD64_en[27]);
   bufif0 AD64_buf28   ( PCI_AD64[28],  AD64_out[28], AD64_en[28]);
   bufif0 AD64_buf29   ( PCI_AD64[29],  AD64_out[29], AD64_en[29]);
   bufif0 AD64_buf30   ( PCI_AD64[30],  AD64_out[30], AD64_en[30]);
   bufif0 AD64_buf31   ( PCI_AD64[31],  AD64_out[31], AD64_en[31]);
   bufif0 CBE_buf0 ( PCI_CBE[0], CBE_out[0], CBE_en[0] ) ;
   bufif0 CBE_buf1 ( PCI_CBE[1], CBE_out[1], CBE_en[1] ) ;
   bufif0 CBE_buf2 ( PCI_CBE[2], CBE_out[2], CBE_en[2] ) ;
   bufif0 CBE_buf3 ( PCI_CBE[3], CBE_out[3], CBE_en[3] ) ;
   
   bufif0 CBE_buf4 ( PCI_CBE64[0], CBE64_out[0], CBE64_en[0] ) ;
   bufif0 CBE_buf5 ( PCI_CBE64[1], CBE64_out[1], CBE64_en[1] ) ;
   bufif0 CBE_buf6 ( PCI_CBE64[2], CBE64_out[2], CBE64_en[2] ) ;
   bufif0 CBE_buf7 ( PCI_CBE64[3], CBE64_out[3], CBE64_en[3] ) ;
   
   bufif0 FRAME_buf    ( PCI_FRAMEn, FRAME_out, FRAME_en ) ;
   bufif0 REQ64n_buf   ( PCI_REQ64n, FRAME_out, FRAME_en ) ;
   
   //bufif0 ACK64n_buf   ( ACK64n, ACK64n_out, ACK64n_en ) ;
   bufif0 IRDY_buf     ( PCI_IRDYn, IRDY_out, IRDY_en ) ;
   bufif0 DEVSEL_buf   ( PCI_DEVSELn, DEVSEL_out, DEVSEL_en ) ;
   bufif0 TRDY_buf     ( PCI_TRDYn, TRDY_out, TRDY_en ) ;
   bufif0 STOP_buf     ( PCI_STOPn, STOP_out, STOP_en ) ;
   
   //bufif0 RST_buf      ( RST, RST_out, RST_en ) ;
   bufif0 INTA_buf     ( PCI_INTAn, INTA_out, INTA_en) ;
   bufif0 REQ_buf      ( PCI_REQn, REQ_out, REQ_en ) ;
   bufif0 PAR_buf      ( PCI_PAR, PAR_out, PAR_en ) ;
   bufif0 PAR64_buf    ( PCI_PAR64, PAR64_out, PAR64_en ) ;
   bufif0 PERR_buf     ( PCI_PERRn, PERR_out, PERR_en ) ;
   bufif0 SERR_buf     ( PCI_SERRn, SERR_out, SERR_en ) ;

   clock clk (/*AUTOINST*/
	      // Outputs
	      .wb_clk_i			(wb_clk_i),
	      .wb_rst_i			(wb_rst_i),
	      // Inputs
	      .PCI_CLK			(PCI_CLK),
	      .PCI_RSTn			(PCI_RSTn));
endmodule // bridege
