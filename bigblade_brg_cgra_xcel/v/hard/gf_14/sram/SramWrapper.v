module SramGenericPRTL__data_nbits_32__num_entries_1024
(
  input  logic [9:0] A1 ,
  input  logic [0:0] CE1 ,
  input  logic [0:0] CSB1 ,
  input  logic [31:0] I1 ,
  output logic [31:0] O1 ,
  input  logic [0:0] OEB1 ,
  input  logic [0:0] WEB1 ,
  input  logic [0:0] clk ,
  input  logic [0:0] reset
);

  logic [31:0] dout;

  gf14_1rw_d1024_w32_m4_byte brg_rf_1024_32(
    .CLK         (clk),
    .CEN         (CSB1),
    .GWEN        (WEB1),
    .A           (A1),
    .D           (I1),
    .WEN         (32'h0000),
    .STOV        (1'd0),
    .EMA         (3'd2),
    .EMAW        (2'd1),
    .EMAS        (1'd0),
    .RET1N       (1'd1),
    .Q           (dout)
  );

  always_comb begin : comb_logic
    if ( ~OEB1 ) begin
      O1 = dout;
    end
    else
      O1 = 32'd0;
  end

endmodule
