/*
  Tracer for the BP <--> Manycore Bridge
*/

`include "bp_common_defines.svh"

module bp_cce_to_mc_bridge_tracer
  import bsg_chip_pkg::*;
  import bp_common_pkg::*;
  import bsg_manycore_pkg::*;
  #(parameter bp_params_e bp_params_p = e_bp_bigblade_unicore_cfg
  `declare_bp_proc_params(bp_params_p)
  `declare_bp_bedrock_mem_if_widths(paddr_width_p, word_width_gp, lce_id_width_p, lce_assoc_p, cce)
  
  , parameter trace_file_p = "host"
  , parameter host_enable_p = 0
  , parameter mc_x_cord_width_p = mc_x_cord_width_gp
  , parameter mc_y_cord_width_p = mc_y_cord_width_gp
  , parameter mc_data_width_p = mc_data_width_gp
  , parameter mc_addr_width_p = mc_addr_width_gp
  
  , localparam out_packet_width_lp = `bsg_manycore_packet_width(mc_addr_width_p, mc_data_width_p, mc_x_cord_width_p, mc_y_cord_width_p)
  , localparam return_packet_width_lp = `bsg_manycore_return_packet_width(mc_x_cord_width_p, mc_y_cord_width_p, mc_data_width_p)
  )
  ( input clk_i
  , input reset_i

  , input trace_en_i
  
  // BP --> Bridge commands
  , input                                  io_cmd_v_i
  , input [cce_mem_msg_width_lp-1:0]       io_cmd_i
  , input logic                            io_cmd_ready_o

  // Bridge --> BP responses
  , input logic                            io_resp_v_o
  , input logic [cce_mem_msg_width_lp-1:0] io_resp_o
  , input                                  io_resp_yumi_i
  
  // Bridge --> BP commands
  , input logic                            io_cmd_v_o
  , input logic [cce_mem_msg_width_lp-1:0] io_cmd_o
  , input                                  io_cmd_yumi_i
  
  // BP --> Bridge responses
  , input                                 io_resp_v_i
  , input [cce_mem_msg_width_lp-1:0]      io_resp_i
  , input logic                           io_resp_ready_o

  // Bridge --> Manycore commands
  , input logic                           out_v_li
  , input logic [out_packet_width_lp-1:0] out_packet_li
  , input logic                           out_ready_lo

  // Manycore --> Bridge responses
  , input logic [mc_data_width_p-1:0]              returned_data_r_lo
  , input logic [bsg_manycore_reg_id_width_gp-1:0] returned_reg_id_r_lo
  , input logic                                    returned_v_r_lo
  , input logic                                    returned_yumi_li
  , input bsg_manycore_return_packet_type_e        returned_pkt_type_r_lo
  , input logic                                    returned_fifo_full_lo
  , input logic                                    returned_credit_v_r_lo
  , input logic [bsg_manycore_reg_id_width_gp-1:0] returned_credit_reg_id_r_lo

  // Manycore --> Bridge commands
  , input logic                            in_v_lo
  , input logic [mc_data_width_p-1:0]      in_data_lo
  , input logic [(mc_data_width_p>>3)-1:0] in_mask_lo
  , input logic [mc_addr_width_p-1:0]      in_addr_lo
  , input logic                            in_we_lo
  , input bsg_manycore_load_info_s         in_load_info_lo
  , input logic [mc_x_cord_width_p-1:0]    in_src_x_cord_lo
  , input logic [mc_y_cord_width_p-1:0]    in_src_y_cord_lo
  , input logic                            in_yumi_li

  // Bridge --> Manycore responses
  , input logic [mc_data_width_p-1:0] returning_data_li
  , input logic                       returning_v_li
  );

  `declare_bp_bedrock_mem_if(paddr_width_p, word_width_gp, lce_id_width_p, lce_assoc_p, cce);
  `declare_bp_memory_map(paddr_width_p, caddr_width_p);
  `declare_bsg_manycore_packet_s(mc_addr_width_p, mc_data_width_p, mc_x_cord_width_p, mc_y_cord_width_p);
  `bp_cast_i(bp_bedrock_cce_mem_msg_s, io_cmd);
  `bp_cast_i(bp_bedrock_cce_mem_msg_s, io_resp);
  
  bp_bedrock_cce_mem_msg_s io_cmd_cast_o, io_resp_cast_o;
  assign io_cmd_cast_o = io_cmd_o;
  assign io_resp_cast_o = io_resp_o;

  bsg_manycore_packet_s out_packet_cast_i;
  assign out_packet_cast_i = out_packet_li;

  string file_name;
  integer file;
  always_ff @(negedge reset_i)
    begin
      file_name = $sformatf("%s.trace", trace_file_p);
      file      = $fopen(file_name, "w");
      $fwrite(file, "All sizes are in bytes\n");
    end

  function string bp_msg_type (bp_bedrock_mem_type_e t);
    case (t)
      e_bedrock_mem_rd, e_bedrock_mem_uc_rd:
        bp_msg_type = "[load      ]";
      default:
        bp_msg_type = "[store     ]";
    endcase
  endfunction

  // I/O Message type definitions
  string in_io_cmd_msg_type, in_io_resp_msg_type, out_io_cmd_msg_type, out_io_resp_msg_type;
  always_comb
    begin
      in_io_cmd_msg_type   = bp_msg_type(io_cmd_cast_i.header.msg_type.mem);
      in_io_resp_msg_type  = bp_msg_type(io_resp_cast_i.header.msg_type.mem);
      out_io_cmd_msg_type  = bp_msg_type(io_cmd_cast_o.header.msg_type.mem);
      out_io_resp_msg_type = bp_msg_type(io_resp_cast_o.header.msg_type.mem);
    end

    //// I/O Size definitions
    integer in_io_cmd_size, in_io_resp_size, out_io_cmd_size, out_io_resp_size;
    always_comb
    begin
      in_io_cmd_size   = 2**io_cmd_cast_i.header.size;
      in_io_resp_size  = 2**io_resp_cast_i.header.size;
      out_io_cmd_size  = 2**io_cmd_cast_o.header.size;
      out_io_resp_size = 2**io_resp_cast_o.header.size;
    end

  // Outgoing request packet op
  string out_pkt_op;
  always_comb
    case (out_packet_cast_i.op_v2)
      e_remote_load   : out_pkt_op  = "[load      ]";
      e_remote_store  : out_pkt_op  = "[store     ]";
      e_remote_sw     : out_pkt_op  = "[store word]";
      e_cache_op      : out_pkt_op  = "[cache     ]";
      e_remote_amoswap
      ,e_remote_amoadd
      ,e_remote_amoor : out_pkt_op  = "[amo       ]";
      default         : out_pkt_op  = "[unknown   ]";
    endcase

  string rtn_pkt_op;
  always_comb
    case (returned_pkt_type_r_lo)
      e_return_credit  : rtn_pkt_op = "[credit    ]";
      e_return_ifetch  : rtn_pkt_op = "[ifetch    ]";
      e_return_int_wb  : rtn_pkt_op = "[int wb    ]";
      e_return_float_wb: rtn_pkt_op = "[float wb  ]";
      default          : rtn_pkt_op = "[unknown   ]";
    endcase

  string req_pkt_op;
  always_comb
    if (in_we_lo)
      req_pkt_op = "[store     ]";
    else if (in_load_info_lo.is_byte_op & in_load_info_lo.is_unsigned_op)
      req_pkt_op = "[lbu       ]";
    else if (in_load_info_lo.is_byte_op & ~in_load_info_lo.is_unsigned_op)
      req_pkt_op = "[lb        ]";
    else if (in_load_info_lo.is_hex_op & in_load_info_lo.is_unsigned_op)
      req_pkt_op = "[lh        ]";
    else if (in_load_info_lo.is_hex_op & ~in_load_info_lo.is_unsigned_op)
      req_pkt_op = "[lhu       ]";
    else
      req_pkt_op = "[lw        ]";

  always_ff @(negedge clk_i)
    if (trace_en_i)
      begin
        // BP --> Manycore request
        if (io_cmd_v_i & io_cmd_ready_o)
          $fwrite(file, "%t [BP->Bridge req ] %s data: %x addr: %x size: %x \n", $time, in_io_cmd_msg_type, io_cmd_cast_i.data, io_cmd_cast_i.header.addr, in_io_cmd_size);

        if (out_v_li & out_ready_lo)
          $fwrite(file, "%t [Bridge->MC req ] %s data: %x addr: %x reg_id: %x dst x: %x dst y: %x \n", $time, out_pkt_op, out_packet_cast_i.payload, out_packet_cast_i.addr, out_packet_cast_i.reg_id, out_packet_cast_i.x_cord, out_packet_cast_i.y_cord);

        // Manycore --> BP response
        if (returned_v_r_lo & returned_yumi_li)
          $fwrite(file, "%t [MC->Bridge resp] %s data: %x reg_id: %x \n", $time, rtn_pkt_op, returned_data_r_lo, returned_reg_id_r_lo);

        if (returned_credit_v_r_lo & ~returned_v_r_lo)
          $fwrite(file, "%t [MC->Bridge resp] %s data: %x reg_id: %x \n", $time, rtn_pkt_op, 32'b0, returned_credit_reg_id_r_lo);

        if (io_resp_v_o & io_resp_yumi_i)
          $fwrite(file, "%t [Bridge->BP resp] %s data: %x addr: %x size: %x \n", $time, out_io_resp_msg_type, io_resp_cast_o.data, io_resp_cast_o.header.addr, out_io_resp_size);

        // Manycore --> BP request
        if (in_v_lo & in_yumi_li)
          $fwrite(file, "%t [MC->Bridge req ] %s data: %x addr: %x mask: %b src x: %x src y: %x \n", $time, req_pkt_op, in_data_lo, in_addr_lo, in_mask_lo, in_src_x_cord_lo, in_src_y_cord_lo);

        if (io_cmd_v_o & io_cmd_yumi_i)
          $fwrite(file, "%t [Bridge->BP req ] %s data: %x addr: %x size: %x \n", $time, out_io_cmd_msg_type, io_cmd_cast_o.data, io_cmd_cast_o.header.addr, out_io_cmd_size);

        // BP --> Manycore response
        if (io_resp_v_i & io_resp_ready_o)
          $fwrite(file, "%t [BP->Bridge resp] %s data: %x addr: %x size: %x \n", $time, in_io_resp_msg_type, io_resp_cast_i.data, io_resp_cast_i.header.addr, in_io_resp_size);

        if (returning_v_li)
          $fwrite(file, "%t [Bridge->MC resp] [return    ] data: %x \n", $time, returning_data_li);
      end

endmodule

