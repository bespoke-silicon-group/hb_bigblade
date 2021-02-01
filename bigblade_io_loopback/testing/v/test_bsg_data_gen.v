
module test_bsg_data_gen 

 #(parameter channel_width_p = "inv"
  ,parameter num_channels_p  = -1
  ,parameter debug_p         = 0
  )
  
  (input clk_i
  ,input reset_i
  ,input yumi_i
  ,output logic [channel_width_p*num_channels_p-1:0] o
  );

  PRBS_ANY
 #(.CHK_MODE   (0)
  ,.INV_PATTERN(1)
  ,.POLY_LENGHT(31)
  ,.POLY_TAP   (28)
  ,.NBITS      (channel_width_p*num_channels_p)
  ) prbs	
  (.RST(reset_i)
  ,.CLK(clk_i)
  ,.DATA_IN('0)
  ,.EN(yumi_i)
  ,.DATA_OUT(o)
  );

endmodule
