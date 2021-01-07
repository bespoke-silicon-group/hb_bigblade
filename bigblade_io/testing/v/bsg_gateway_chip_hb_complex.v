
module bsg_gateway_chip_hb_complex

 import bsg_chip_pkg::*;
 import bsg_manycore_pkg::*;

  (input                      clk_i
  ,input bsg_chip_tag_lines_s tag_lines_i
  ,input                      tag_trace_done_i

  ,input  bsg_chip_io_link_sif_s [3:0][io_ct_num_in_gp-1:0] io_links_i
  ,output bsg_chip_io_link_sif_s [3:0][io_ct_num_in_gp-1:0] io_links_o

  ,input  bsg_chip_mem_link_sif_s [15:0] mem_links_i
  ,output bsg_chip_mem_link_sif_s [15:0] mem_links_o
  );

  //////////////////////////////////////////////////
  //
  // BSG Tag Client Instance
  //

  // Tag payload for hb control signals
  typedef struct packed { 
      logic padding;
      logic reset;
  } hb_tag_payload_s;

  hb_tag_payload_s hb_tag_data_lo;
  logic            hb_tag_new_data_lo;

  bsg_tag_client #(.width_p( $bits(hb_tag_data_lo) ), .default_p( 0 ))
    btc_hb
      (.bsg_tag_i     ( tag_lines_i.hb_reset )
      ,.recv_clk_i    ( clk_i )
      ,.recv_reset_i  ( 1'b0 )
      ,.recv_new_r_o  ( hb_tag_new_data_lo )
      ,.recv_data_r_o ( hb_tag_data_lo )
      );


  //////////////////////////////////////////////////
  //
  // Loopback Test Node
  //
  logic node_en_lo;
  
  logic [3:0][io_ct_num_in_gp-1:0] io_error_r;
  logic [3:0][io_ct_num_in_gp-1:0][31:0] io_sent_r, io_received_r;

  for (genvar i = 0; i < 4; i++)
  begin: io_node
    for (genvar j = 0; j < io_ct_num_in_gp; j++)
      begin: ch
        bsg_fifo_1r1w_small_hardened_test_node
       #(.num_channels_p(io_ct_width_gp/io_link_channel_width_gp)
        ,.channel_width_p(io_link_channel_width_gp)
        ,.is_client_node_p(0)
        ) node
        (.node_clk_i  (clk_i)
        ,.node_reset_i(hb_tag_data_lo.reset)
        ,.node_en_i   (node_en_lo)
        
        ,.error_o   (io_error_r[i][j])
        ,.sent_o    (io_sent_r[i][j])
        ,.received_o(io_received_r[i][j])
         
        ,.clk_i   (clk_i)
        ,.reset_i (hb_tag_data_lo.reset)
        
        ,.link_i(io_links_i[i][j])
        ,.link_o(io_links_o[i][j])
        );
      end
  end
  
  logic [15:0] mem_error_r;
  logic [15:0][31:0] mem_sent_r, mem_received_r;

  for (genvar i = 0; i < 16; i++)
  begin: mem_node
    bsg_fifo_1r1w_small_hardened_test_node
   #(.num_channels_p(mem_link_width_gp/mem_link_channel_width_gp)
    ,.channel_width_p(mem_link_channel_width_gp)
    ,.is_client_node_p(0)
    ) node
    (.node_clk_i  (clk_i)
    ,.node_reset_i(hb_tag_data_lo.reset)
    ,.node_en_i   (node_en_lo)
    
    ,.error_o   (mem_error_r[i])
    ,.sent_o    (mem_sent_r[i])
    ,.received_o(mem_received_r[i])
     
    ,.clk_i   (clk_i)
    ,.reset_i (hb_tag_data_lo.reset)
    
    ,.link_i(mem_links_i[i])
    ,.link_o(mem_links_o[i])
    );
  end

  initial
  begin
    // Init
    node_en_lo = 0;
    #100000
    
    // Wait for bsg_tag initialization
    @(posedge tag_trace_done_i); #1;

    // node enable
    @(posedge clk_i); #1;
    node_en_lo = 1;
    $display("node enable HIGH");
    
    $display("running tests...");
    #50000000
    $display("finished running tests");
    
    // node disable
    @(posedge clk_i); #1;
    node_en_lo = 0;
    $display("node enable LOW");
    
    #5000000

    // verification
    for (integer i = 0; i < 4; i++)
      begin
        for (integer j = 0; j < io_ct_num_in_gp; j++)
          begin
            assert(io_error_r[i][j] == 0)
            else 
              begin
                $error("\nFAIL... Error in loopback IO node[%0d][%0d]", i, j);
                $finish;
              end
            assert(io_sent_r[i][j] == io_received_r[i][j])
            else 
              begin
                $error("\nFAIL... Loopback IO node[%0d][%0d] sent %0d packets but received only %0d", i, j, io_sent_r[i][j], io_received_r[i][j]);
                $finish;
              end
            $display("Loopback IO node[%0d][%0d] sent and received %0d packets", i, j, io_sent_r[i][j]);
          end
      end
      
    for (integer i = 0; i < 16; i++)
      begin
        assert(mem_error_r[i] == 0)
        else 
          begin
            $error("\nFAIL... Error in loopback MEM node[%0d]", i);
            $finish;
          end
        assert(mem_sent_r[i] == mem_received_r[i])
        else 
          begin
            $error("\nFAIL... Loopback MEM node[%0d] sent %0d packets but received only %0d", i, mem_sent_r[i], mem_received_r[i]);
            $finish;
          end
        $display("Loopback MEM node[%0d] sent and received %0d packets", i, mem_sent_r[i]);
      end

    $display("\nPASS!\n");
    $finish;
  end


  //////////////////////////////////////////////////
  //
  // Manycore Adapter
  //



  //////////////////////////////////////////////////
  //
  // Manycore Testbench
  //

endmodule