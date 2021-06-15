
module bsg_tag_boot_rom

 #(parameter width_p      = "inv"
  ,parameter addr_width_p = "inv"
  ,parameter max_trace_p  = 2**24
  )

  (input  [addr_width_p-1:0] addr_i
  ,output [width_p-1:0]      data_o
  );

  logic [width_p-1:0] trace [max_trace_p-1:0];
  assign data_o = trace[addr_i];

  integer status;
  string trace_file;
  initial begin
    status = $value$plusargs("trace_file=%s", trace_file);
    $display ("[BSG-info] Tag trace file name status %d", status);
    if (status == 0) trace_file = "bsg_tag_boot.tr";
    $display ("[BSG-info] Reading tag trace from %s", trace_file);
    $readmemb(trace_file, trace);
  end

endmodule
