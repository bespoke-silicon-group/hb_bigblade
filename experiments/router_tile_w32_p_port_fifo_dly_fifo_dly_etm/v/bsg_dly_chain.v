
module bsg_dly_chain

#(parameter width_p=-1
, parameter depth_p=-1
)

( input [width_p-1:0] i
, output [width_p-1:0] o
);

  logic [depth_p:0][width_p-1:0] dly_lines;

  assign dly_lines[0] = i;

  for (genvar k = 0; k < depth_p; k++) begin:d
    for (genvar j = 0; j < width_p; j++) begin:v
      SC7P5T_DLYX100_SSC14R DLY_DONT_TOUCH
        (.A( dly_lines[k  ][j] )
        ,.Z( dly_lines[k+1][j] )
        );
    end:v
  end:d

  assign o = dly_lines[depth_p];

endmodule

