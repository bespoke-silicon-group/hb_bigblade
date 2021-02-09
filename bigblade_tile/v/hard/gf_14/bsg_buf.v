module bsg_buf
  #(parameter width_p="inv"
    , parameter harden_p=0
  ) 
  (
    input [width_p-1:0] i
    , output [width_p-1:0] o
  );


  if (harden_p) begin: hard

    for (genvar j = 0; j < width_p; j++) begin: hard
      SC7P5T_BUFX8_SSC14R hard_buf (
        .A(i[j])
        ,.Z(o[j])
      );
    end

  end
  else begin
    assign o = i;
  end




endmodule
