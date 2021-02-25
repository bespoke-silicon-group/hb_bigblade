
module bsg_link_osdr_phy_phase_align

  (input clk_i,input reset_i,output clk_o);

  wire reset_i_inv, clk_r_p, clk_r_n, clk_r_p_inv, clk_r_n_inv;

  SC7P5T_AO22X1_A_SSC16R clk_o_xor
  (.A1(clk_r_p),.A2(clk_r_n_inv),.B1(clk_r_p_inv),.B2(clk_r_n),.Z(clk_o));

  SC7P5T_CKINVX1_SSC16R reset_inv (.CLK(reset_i),.Z(reset_i_inv));
  SC7P5T_DFFRQX1_SSC16R clk_dff_p
  (.D(clk_r_p_inv),.CLK(clk_i),.RESET(reset_i_inv),.Q(clk_r_p));
  SC7P5T_DFFNRQX1_SSC16R clk_dff_n
  (.D(clk_r_n_inv),.CLK(clk_i),.RESET(reset_i_inv),.Q(clk_r_n));

  SC7P5T_CKINVX1_SSC16R clk_r_inv_p (.CLK(clk_r_p),.Z(clk_r_p_inv));
  SC7P5T_CKINVX1_SSC16R clk_r_inv_n (.CLK(clk_r_n),.Z(clk_r_n_inv));

endmodule
