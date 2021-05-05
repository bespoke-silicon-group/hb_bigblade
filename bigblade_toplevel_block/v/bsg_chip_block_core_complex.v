
module bsg_chip_block_core_complex

 import bsg_chip_pkg::*;
 import bsg_noc_pkg::*;
 import bsg_tag_pkg::*;
 import bsg_manycore_pkg::*;

 #(parameter mc_fwd_width_lp =
    `bsg_manycore_packet_width(hb_addr_width_gp,hb_data_width_gp,hb_x_cord_width_gp,hb_y_cord_width_gp)
  ,parameter mc_rev_width_lp =
    `bsg_manycore_return_packet_width(hb_x_cord_width_gp,hb_y_cord_width_gp,hb_data_width_gp)
  ,parameter total_num_tiles_x_lp = (hb_num_pods_x_gp*hb_num_tiles_x_gp)
  )

  (input  [hb_num_pods_y_gp-1:0]   mc_clk_i
  ,input                           tag_clk_i
  ,input                           tag_data_i

  ,output                          mc_fwd_link_clk_o
  ,output [mc_fwd_width_lp-1:0]    mc_fwd_link_data_o
  ,output                          mc_fwd_link_v_o
  ,input                           mc_fwd_link_token_i

  ,input                           mc_fwd_link_clk_i
  ,input  [mc_fwd_width_lp-1:0]    mc_fwd_link_data_i
  ,input                           mc_fwd_link_v_i
  ,output                          mc_fwd_link_token_o

  ,output                          mc_rev_link_clk_o
  ,output [mc_rev_width_lp-1:0]    mc_rev_link_data_o
  ,output                          mc_rev_link_v_o
  ,input                           mc_rev_link_token_i

  ,input                           mc_rev_link_clk_i
  ,input  [mc_rev_width_lp-1:0]    mc_rev_link_data_i
  ,input                           mc_rev_link_v_i
  ,output                          mc_rev_link_token_o

  ,output [mem_link_conc_num_gp-1:0][S:N][wh_ruche_factor_gp-1:0]                       wh_link_clk_o
  ,output [mem_link_conc_num_gp-1:0][S:N][wh_ruche_factor_gp-1:0][wh_flit_width_gp-1:0] wh_link_data_o
  ,output [mem_link_conc_num_gp-1:0][S:N][wh_ruche_factor_gp-1:0]                       wh_link_v_o
  ,input  [mem_link_conc_num_gp-1:0][S:N][wh_ruche_factor_gp-1:0]                       wh_link_token_i

  ,input  [mem_link_conc_num_gp-1:0][S:N][wh_ruche_factor_gp-1:0]                       wh_link_clk_i
  ,input  [mem_link_conc_num_gp-1:0][S:N][wh_ruche_factor_gp-1:0][wh_flit_width_gp-1:0] wh_link_data_i
  ,input  [mem_link_conc_num_gp-1:0][S:N][wh_ruche_factor_gp-1:0]                       wh_link_v_i
  ,output [mem_link_conc_num_gp-1:0][S:N][wh_ruche_factor_gp-1:0]                       wh_link_token_o
  );


  wire [hb_num_pods_y_gp-1:0][hb_num_pods_x_gp-1:0][tag_lg_els_gp-1:0] pod_tag_node_id_offset_li;
  wire [hb_num_pods_y_gp-1:0][3:0][tag_lg_els_gp-1:0] async_reset_tag_node_id_offset_li;

  wire [hb_num_pods_y_gp-1:0][2+total_num_tiles_x_lp-1:0][hb_x_cord_width_gp-1:0] global_x_li;
  wire [hb_num_pods_y_gp-1:0][2+total_num_tiles_x_lp-1:0][hb_y_cord_width_gp-1:0] global_y_li;

  wire [hb_num_pods_y_gp-1:0][S:N][2+total_num_tiles_x_lp-1:0]                      ver_io_fwd_link_clk_lo, ver_io_fwd_link_v_lo, ver_io_fwd_link_token_li;
  wire [hb_num_pods_y_gp-1:0][S:N][2+total_num_tiles_x_lp-1:0][mc_fwd_width_lp-1:0] ver_io_fwd_link_data_lo;
  wire [hb_num_pods_y_gp-1:0][S:N][2+total_num_tiles_x_lp-1:0]                      ver_io_fwd_link_clk_li, ver_io_fwd_link_v_li, ver_io_fwd_link_token_lo;
  wire [hb_num_pods_y_gp-1:0][S:N][2+total_num_tiles_x_lp-1:0][mc_fwd_width_lp-1:0] ver_io_fwd_link_data_li;

  wire [hb_num_pods_y_gp-1:0][S:N][2+total_num_tiles_x_lp-1:0]                      ver_io_rev_link_clk_lo, ver_io_rev_link_v_lo, ver_io_rev_link_token_li;
  wire [hb_num_pods_y_gp-1:0][S:N][2+total_num_tiles_x_lp-1:0][mc_rev_width_lp-1:0] ver_io_rev_link_data_lo;
  wire [hb_num_pods_y_gp-1:0][S:N][2+total_num_tiles_x_lp-1:0]                      ver_io_rev_link_clk_li, ver_io_rev_link_v_li, ver_io_rev_link_token_lo;
  wire [hb_num_pods_y_gp-1:0][S:N][2+total_num_tiles_x_lp-1:0][mc_rev_width_lp-1:0] ver_io_rev_link_data_li;

  wire [hb_num_pods_y_gp-1:0][E:W][hb_num_tiles_y_gp-1:0]                      hor_io_fwd_link_clk_lo, hor_io_fwd_link_v_lo, hor_io_fwd_link_token_li;
  wire [hb_num_pods_y_gp-1:0][E:W][hb_num_tiles_y_gp-1:0][mc_fwd_width_lp-1:0] hor_io_fwd_link_data_lo;
  wire [hb_num_pods_y_gp-1:0][E:W][hb_num_tiles_y_gp-1:0]                      hor_io_fwd_link_clk_li, hor_io_fwd_link_v_li, hor_io_fwd_link_token_lo;
  wire [hb_num_pods_y_gp-1:0][E:W][hb_num_tiles_y_gp-1:0][mc_fwd_width_lp-1:0] hor_io_fwd_link_data_li;

  wire [hb_num_pods_y_gp-1:0][E:W][hb_num_tiles_y_gp-1:0]                      hor_io_rev_link_clk_lo, hor_io_rev_link_v_lo, hor_io_rev_link_token_li;
  wire [hb_num_pods_y_gp-1:0][E:W][hb_num_tiles_y_gp-1:0][mc_rev_width_lp-1:0] hor_io_rev_link_data_lo;
  wire [hb_num_pods_y_gp-1:0][E:W][hb_num_tiles_y_gp-1:0]                      hor_io_rev_link_clk_li, hor_io_rev_link_v_li, hor_io_rev_link_token_lo;
  wire [hb_num_pods_y_gp-1:0][E:W][hb_num_tiles_y_gp-1:0][mc_rev_width_lp-1:0] hor_io_rev_link_data_li;


  for (genvar i = 0; i < hb_num_pods_y_gp; i++)
  begin: core

    bsg_manycore_pod_row_sdr podrow

    (.ext_clk_i                       (mc_clk_i                         [i])
    ,.pod_tag_clk_i                   ({(hb_num_pods_x_gp){tag_clk_i}}     )
    ,.pod_tag_data_i                  ({(hb_num_pods_x_gp){tag_data_i}}    )
    ,.pod_tag_node_id_offset_i        (pod_tag_node_id_offset_li        [i])

    ,.async_reset_tag_clk_i           ({(4){tag_clk_i}}                    )
    ,.async_reset_tag_data_i          ({(4){tag_data_i}}                   )
    ,.async_reset_tag_node_id_offset_i(async_reset_tag_node_id_offset_li[i])

    ,.global_x_i                      (global_x_li             [i])
    ,.global_y_i                      (global_y_li             [i])

    ,.ver_io_fwd_link_clk_o           (ver_io_fwd_link_clk_lo  [i])
    ,.ver_io_fwd_link_data_o          (ver_io_fwd_link_data_lo [i])
    ,.ver_io_fwd_link_v_o             (ver_io_fwd_link_v_lo    [i])
    ,.ver_io_fwd_link_token_i         (ver_io_fwd_link_token_li[i])

    ,.ver_io_fwd_link_clk_i           (ver_io_fwd_link_clk_li  [i])
    ,.ver_io_fwd_link_data_i          (ver_io_fwd_link_data_li [i])
    ,.ver_io_fwd_link_v_i             (ver_io_fwd_link_v_li    [i])
    ,.ver_io_fwd_link_token_o         (ver_io_fwd_link_token_lo[i])

    ,.ver_io_rev_link_clk_o           (ver_io_rev_link_clk_lo  [i])
    ,.ver_io_rev_link_data_o          (ver_io_rev_link_data_lo [i])
    ,.ver_io_rev_link_v_o             (ver_io_rev_link_v_lo    [i])
    ,.ver_io_rev_link_token_i         (ver_io_rev_link_token_li[i])

    ,.ver_io_rev_link_clk_i           (ver_io_rev_link_clk_li  [i])
    ,.ver_io_rev_link_data_i          (ver_io_rev_link_data_li [i])
    ,.ver_io_rev_link_v_i             (ver_io_rev_link_v_li    [i])
    ,.ver_io_rev_link_token_o         (ver_io_rev_link_token_lo[i])

    ,.hor_io_fwd_link_clk_o           (hor_io_fwd_link_clk_lo  [i])
    ,.hor_io_fwd_link_data_o          (hor_io_fwd_link_data_lo [i])
    ,.hor_io_fwd_link_v_o             (hor_io_fwd_link_v_lo    [i])
    ,.hor_io_fwd_link_token_i         (hor_io_fwd_link_token_li[i])

    ,.hor_io_fwd_link_clk_i           (hor_io_fwd_link_clk_li  [i])
    ,.hor_io_fwd_link_data_i          (hor_io_fwd_link_data_li [i])
    ,.hor_io_fwd_link_v_i             (hor_io_fwd_link_v_li    [i])
    ,.hor_io_fwd_link_token_o         (hor_io_fwd_link_token_lo[i])

    ,.hor_io_rev_link_clk_o           (hor_io_rev_link_clk_lo  [i])
    ,.hor_io_rev_link_data_o          (hor_io_rev_link_data_lo [i])
    ,.hor_io_rev_link_v_o             (hor_io_rev_link_v_lo    [i])
    ,.hor_io_rev_link_token_i         (hor_io_rev_link_token_li[i])

    ,.hor_io_rev_link_clk_i           (hor_io_rev_link_clk_li  [i])
    ,.hor_io_rev_link_data_i          (hor_io_rev_link_data_li [i])
    ,.hor_io_rev_link_v_i             (hor_io_rev_link_v_li    [i])
    ,.hor_io_rev_link_token_o         (hor_io_rev_link_token_lo[i])

    ,.io_wh_link_clk_o    ({wh_link_clk_o  [i+hb_num_pods_y_gp], wh_link_clk_o  [i]})
    ,.io_wh_link_data_o   ({wh_link_data_o [i+hb_num_pods_y_gp], wh_link_data_o [i]})
    ,.io_wh_link_v_o      ({wh_link_v_o    [i+hb_num_pods_y_gp], wh_link_v_o    [i]})
    ,.io_wh_link_token_i  ({wh_link_token_i[i+hb_num_pods_y_gp], wh_link_token_i[i]})

    ,.io_wh_link_clk_i    ({wh_link_clk_i  [i+hb_num_pods_y_gp], wh_link_clk_i  [i]})
    ,.io_wh_link_data_i   ({wh_link_data_i [i+hb_num_pods_y_gp], wh_link_data_i [i]})
    ,.io_wh_link_v_i      ({wh_link_v_i    [i+hb_num_pods_y_gp], wh_link_v_i    [i]})
    ,.io_wh_link_token_o  ({wh_link_token_o[i+hb_num_pods_y_gp], wh_link_token_o[i]})
    );

  end

  // hard-wire constants
  for (genvar i = 0; i < hb_num_pods_y_gp; i++)
  begin
    // assign async reset tag offset, 4 corners in total
    for (genvar j = 0; j < 4; j++)
        assign async_reset_tag_node_id_offset_li[i][j] = (tag_lg_els_gp)'(tag_mc_sdr_offset_gp+(i*4+j)*tag_sdr_local_els_gp);

    // assign pod tag offset
    for (genvar j = 0; j < hb_num_pods_x_gp; j++)
        assign pod_tag_node_id_offset_li[i][j] = (tag_lg_els_gp)'(tag_mc_reset_offset_gp+(i*hb_num_pods_x_gp+j)*1);

    // assign global x coordinates
    assign global_x_li[i][0] = {(hb_pod_x_cord_width_gp)'(0), (hb_x_subcord_width_gp)'((1<<hb_x_subcord_width_gp)-1)};
    for (genvar j = 0; j < total_num_tiles_x_lp; j++)
        assign global_x_li[i][j+1] = {(hb_pod_x_cord_width_gp)'((j/hb_num_tiles_x_gp)+1), (hb_x_subcord_width_gp)'(j%hb_num_tiles_x_gp)};
    assign global_x_li[i][2+total_num_tiles_x_lp-1] = {(hb_pod_x_cord_width_gp)'(hb_num_pods_x_gp+1), (hb_x_subcord_width_gp)'(0)};
    
    // assign global y coordinates
    assign global_y_li[i][0] = {(hb_pod_y_cord_width_gp)'(i*2), (hb_y_subcord_width_gp)'((1<<hb_y_subcord_width_gp)-1)};
    for (genvar j = 0; j < total_num_tiles_x_lp; j++)
        assign global_y_li[i][j+1] = {(hb_pod_y_cord_width_gp)'(i*2), (hb_y_subcord_width_gp)'((1<<hb_y_subcord_width_gp)-2)};
    assign global_y_li[i][2+total_num_tiles_x_lp-1] = {(hb_pod_y_cord_width_gp)'(i*2), (hb_y_subcord_width_gp)'((1<<hb_y_subcord_width_gp)-1)};
  end

  // TODO: fix temporary sdr input clock tieoff internally

  // tieoff hor links
  for (genvar i = 0 ; i < hb_num_pods_y_gp; i++)
  begin
    for (genvar j = W ; j <= E; j++)
      begin
        for (genvar k = 0 ; k < hb_num_tiles_y_gp; k++)
          begin
            // Attach side io links, requests from host to chip
            if ((i == 0) && (j == W) && (k == 0))
              begin
                assign hor_io_fwd_link_clk_li  [i][j][k] = mc_fwd_link_clk_i;
                assign hor_io_fwd_link_data_li [i][j][k] = mc_fwd_link_data_i;
                assign hor_io_fwd_link_v_li    [i][j][k] = mc_fwd_link_v_i;
                assign mc_fwd_link_token_o = hor_io_fwd_link_token_lo[i][j][k];

                assign mc_rev_link_clk_o   = hor_io_rev_link_clk_lo  [i][j][k];
                assign mc_rev_link_data_o  = hor_io_rev_link_data_lo [i][j][k];
                assign mc_rev_link_v_o     = hor_io_rev_link_v_lo    [i][j][k];
                assign hor_io_rev_link_token_li[i][j][k] = mc_rev_link_token_i;
              end
            else
              begin
                assign hor_io_fwd_link_clk_li  [i][j][k] = hor_io_fwd_link_clk_lo[i][j][k];
                assign hor_io_fwd_link_data_li [i][j][k] = '0;
                assign hor_io_fwd_link_v_li    [i][j][k] = '0;
                assign hor_io_rev_link_token_li[i][j][k] = '0;
              end
            assign hor_io_rev_link_clk_li  [i][j][k] = hor_io_rev_link_clk_lo[i][j][k];
            assign hor_io_rev_link_data_li [i][j][k] = '0;
            assign hor_io_rev_link_v_li    [i][j][k] = '0;
            assign hor_io_fwd_link_token_li[i][j][k] = '0;
          end
      end
  end

  // tieoff ver links
  for (genvar j = N ; j <= S; j++)
  begin
    localparam i = (j == N)? 0 : hb_num_pods_y_gp-1;
    for (genvar k = 0 ; k < 2+total_num_tiles_x_lp; k++)
      begin
        // Attach top io links, requests from chip to host
        if ((j == N) && (k == hb_num_tiles_x_gp+1-1))
          begin
            assign ver_io_rev_link_clk_li  [i][j][k] = mc_rev_link_clk_i;
            assign ver_io_rev_link_data_li [i][j][k] = mc_rev_link_data_i;
            assign ver_io_rev_link_v_li    [i][j][k] = mc_rev_link_v_i;
            assign mc_rev_link_token_o = ver_io_rev_link_token_lo[i][j][k];

            assign mc_fwd_link_clk_o   = ver_io_fwd_link_clk_lo  [i][j][k];
            assign mc_fwd_link_data_o  = ver_io_fwd_link_data_lo [i][j][k];
            assign mc_fwd_link_v_o     = ver_io_fwd_link_v_lo    [i][j][k];
            assign ver_io_fwd_link_token_li[i][j][k] = mc_fwd_link_token_i;
          end
        else
          begin
            assign ver_io_rev_link_clk_li  [i][j][k] = ver_io_rev_link_clk_lo[i][j][k];
            assign ver_io_rev_link_data_li [i][j][k] = '0;
            assign ver_io_rev_link_v_li    [i][j][k] = '0;
            assign ver_io_fwd_link_token_li[i][j][k] = '0;
          end
        assign ver_io_fwd_link_clk_li  [i][j][k] = ver_io_fwd_link_clk_lo[i][j][k];
        assign ver_io_fwd_link_data_li [i][j][k] = '0;
        assign ver_io_fwd_link_v_li    [i][j][k] = '0;
        assign ver_io_rev_link_token_li[i][j][k] = '0;
      end
  end

  // stitch ver links
  for (genvar i = 1; i < hb_num_pods_y_gp; i++)
  begin
    assign ver_io_fwd_link_clk_li  [i-1][S] = ver_io_fwd_link_clk_lo  [i][N];
    assign ver_io_fwd_link_data_li [i-1][S] = ver_io_fwd_link_data_lo [i][N];
    assign ver_io_fwd_link_v_li    [i-1][S] = ver_io_fwd_link_v_lo    [i][N];
    assign ver_io_fwd_link_token_li[i-1][S] = ver_io_fwd_link_token_lo[i][N];
    assign ver_io_rev_link_clk_li  [i-1][S] = ver_io_rev_link_clk_lo  [i][N];
    assign ver_io_rev_link_data_li [i-1][S] = ver_io_rev_link_data_lo [i][N];
    assign ver_io_rev_link_v_li    [i-1][S] = ver_io_rev_link_v_lo    [i][N];
    assign ver_io_rev_link_token_li[i-1][S] = ver_io_rev_link_token_lo[i][N];

    assign ver_io_fwd_link_clk_li  [i][N] = ver_io_fwd_link_clk_lo  [i-1][S];
    assign ver_io_fwd_link_data_li [i][N] = ver_io_fwd_link_data_lo [i-1][S];
    assign ver_io_fwd_link_v_li    [i][N] = ver_io_fwd_link_v_lo    [i-1][S];
    assign ver_io_fwd_link_token_li[i][N] = ver_io_fwd_link_token_lo[i-1][S];
    assign ver_io_rev_link_clk_li  [i][N] = ver_io_rev_link_clk_lo  [i-1][S];
    assign ver_io_rev_link_data_li [i][N] = ver_io_rev_link_data_lo [i-1][S];
    assign ver_io_rev_link_v_li    [i][N] = ver_io_rev_link_v_lo    [i-1][S];
    assign ver_io_rev_link_token_li[i][N] = ver_io_rev_link_token_lo[i-1][S];
  end

endmodule
