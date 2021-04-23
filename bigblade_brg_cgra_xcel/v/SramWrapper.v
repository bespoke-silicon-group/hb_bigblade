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

  // sram_1024_32 brg_sram_1024_32
  //    (
  //     .CLK         (clk),
  //     .CEN         (CSB1),
  //     .RDWEN       (WEB1),
  //     .A           (A1),
  //     .D           (I1),
  //     .BW          (32'h0000),
  //     .T_LOGIC     (1'b0),
  //     .T_Q_RST     (1'b0),
  //     .MA_SAWL     (1'b0),
  //     .MA_WL       (1'b0),
  //     .MA_VD1      (1'b0),
  //     .MA_VD0      (1'b0),
  //     .MA_WRT      (1'b0),
  //     .Q           (dout),
  //     .OBSV_CTL    ()
  //    );

  always_comb begin : comb_logic
    if ( ~OEB1 ) begin
      O1 = dout;
    end
    else
      O1 = 32'd0;
  end

endmodule
