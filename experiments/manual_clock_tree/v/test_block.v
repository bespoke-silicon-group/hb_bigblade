module test_block
  #( parameter width_p=2
     , parameter depth_p=8
  )
  (
    input clk_i
    ,input [width_p-1:0] data_i
    ,output [width_p-1:0] data_o
  );

  logic [depth_p-1:0][width_p-1:0] data_r;

  for (genvar i = 0; i < depth_p; i++) begin
    if (i == 0) begin
      always_ff @ (posedge clk_i) begin
        data_r[i] <= data_i;
      end
    end
    else begin
      always_ff @ (posedge clk_i) begin
        data_r[i] <= data_r[i-1];
      end
    end
  end

  assign data_o = data_r[depth_p-1];

endmodule
