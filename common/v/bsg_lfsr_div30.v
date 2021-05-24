
module bsg_lfsr_div30

  (input  clk_i
  ,input  reset_i
  ,output clk_div_o
  );

  logic [3:0] data_r;
  logic out_r;
  assign clk_div_o = out_r;

  always_ff @(posedge clk_i)
  begin
    data_r[0] <= data_r[1];
    data_r[1] <= reset_i | data_r[2];
    data_r[2] <= data_r[0] ^ data_r[3];
    data_r[3] <= data_r[0];
    out_r     <= ~reset_i & (~(| data_r[2:0]) ^ out_r);
  end

endmodule
