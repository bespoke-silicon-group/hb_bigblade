module bsg_nonsynth_wormhole_test_mem
  #(parameter vcache_data_width_p = "inv"
    , parameter vcache_block_size_in_words_p="inv"
    , parameter vcache_dma_data_width_p="inv"
    
    , parameter num_tiles_x_p = "inv"
    , parameter lg_num_tiles_x_lp = `BSG_SAFE_CLOG2(num_tiles_x_p)
    
    , parameter wh_ruche_factor_p="inv"
    , parameter wh_cid_width_p="inv"
    , parameter wh_flit_width_p="inv"
    , parameter wh_cord_width_p="inv"
    , parameter wh_len_width_p="inv"

    , parameter data_len_lp = (vcache_data_width_p*vcache_block_size_in_words_p/vcache_dma_data_width_p)
    , parameter mem_size_p = "inv"   // size of memory in bytes
    , parameter mem_els_lp = mem_size_p/(vcache_dma_data_width_p/8)
    , parameter mem_addr_width_lp = `BSG_SAFE_CLOG2(mem_els_lp)

    , parameter count_width_lp = `BSG_SAFE_CLOG2(data_len_lp)

    , parameter block_offset_width_lp = `BSG_SAFE_CLOG2((vcache_data_width_p>>3)*vcache_block_size_in_words_p)

    , parameter wh_link_sif_width_lp =
      `bsg_ready_and_link_sif_width(wh_flit_width_p)
  )
  (
    input clk_i
    , input reset_i

    , input  [wh_ruche_factor_p-1:0][wh_link_sif_width_lp-1:0] wh_link_sif_i
    , output [wh_ruche_factor_p-1:0][wh_link_sif_width_lp-1:0] wh_link_sif_o
  );

 
  // memory
  logic mem_we;
  logic [mem_addr_width_lp-1:0] mem_w_addr;
  logic [mem_addr_width_lp-1:0] mem_r_addr;
  logic [vcache_dma_data_width_p-1:0] mem_w_data;
  logic [vcache_dma_data_width_p-1:0] mem_r_data;
  logic [vcache_dma_data_width_p-1:0] mem_r [mem_els_lp-1:0];

  always_ff @ (posedge clk_i) begin
    if (mem_we) begin
      mem_r[mem_w_addr] <= mem_w_data;
    end
  end

  assign mem_r_data = mem_r[mem_r_addr];


  // wormhole concentrator
  `declare_bsg_ready_and_link_sif_s(wh_flit_width_p, wh_link_sif_s);
  wh_link_sif_s wh_conc_link_sif_li;
  wh_link_sif_s wh_conc_link_sif_lo;


  bsg_wormhole_concentrator #(
    .flit_width_p(wh_flit_width_p)
    ,.len_width_p(wh_len_width_p)
    ,.cid_width_p(wh_cid_width_p)
    ,.cord_width_p(wh_cord_width_p)
    ,.num_in_p(wh_ruche_factor_p)
  ) conc (
    .clk_i(clk_i)
    ,.reset_i(reset_i)

    ,.links_i(wh_link_sif_i)
    ,.links_o(wh_link_sif_o)

    ,.concentrated_link_i(wh_conc_link_sif_li)
    ,.concentrated_link_o(wh_conc_link_sif_lo)
  );


  typedef struct packed {
    logic [wh_flit_width_p-(wh_cord_width_p*2)-1-wh_len_width_p-wh_cid_width_p-1:0] unused;
    logic write_not_read;
    logic [wh_cord_width_p-1:0] src_cord;
    logic [wh_cid_width_p-1:0] cid;
    logic [wh_len_width_p-1:0] len;
    logic [wh_cord_width_p-1:0] dest_cord;
  } wh_header_flit_s;

  wh_header_flit_s header_flit_in;
  assign header_flit_in = wh_conc_link_sif_lo.data;

  logic clear_li;
  logic up_li;
  logic [count_width_lp-1:0] count_lo;

  bsg_counter_clear_up #(
    .max_val_p(data_len_lp-1)
    ,.init_val_p(0)
  ) count (
    .clk_i(clk_i)
    ,.reset_i(reset_i)
    ,.clear_i(clear_li)
    ,.up_i(up_li)
    ,.count_o(count_lo)
  );


  typedef enum logic [2:0] {
    RESET
    ,READY
    ,RECV_ADDR
    ,RECV_EVICT_DATA
    ,SEND_FILL_HEADER
    ,SEND_FILL_DATA
  } mem_state_e;

  mem_state_e mem_state_r, mem_state_n;
  logic write_not_read_r, write_not_read_n;
  logic [wh_flit_width_p-1:0] addr_r, addr_n;
  logic [wh_cord_width_p-1:0] src_cord_r, src_cord_n;
  logic [wh_cid_width_p-1:0] cid_r, cid_n;
  
  wh_header_flit_s header_flit_out;
  assign header_flit_out.unused = '0;
  assign header_flit_out.write_not_read = '0; // dont care
  assign header_flit_out.src_cord = '0;   // dont care
  assign header_flit_out.cid = cid_r;
  assign header_flit_out.len = wh_len_width_p'(data_len_lp);
  assign header_flit_out.dest_cord = src_cord_r;

  always_comb begin
    wh_conc_link_sif_li = '0;
    clear_li = 1'b0;
    up_li = 1'b0;

    write_not_read_n = write_not_read_r;
    addr_n = addr_r;
    src_cord_n = src_cord_r;
    cid_n = cid_r;
    mem_state_n = mem_state_r;
 
    mem_we = 1'b0;
    mem_w_data = wh_conc_link_sif_lo.data;
    mem_w_addr = {
      src_cord_r[0+:lg_num_tiles_x_lp],
      addr_r[block_offset_width_lp+:mem_addr_width_lp-lg_num_tiles_x_lp-count_width_lp],
      count_lo
    };

    mem_r_addr = {
      src_cord_r[0+:lg_num_tiles_x_lp],
      addr_r[block_offset_width_lp+:mem_addr_width_lp-lg_num_tiles_x_lp-count_width_lp],
      count_lo
    };

   
    case (mem_state_r)

      RESET: begin
        mem_state_n = READY;
      end

      READY: begin
        wh_conc_link_sif_li.ready_and_rev = 1'b1;
        if (wh_conc_link_sif_lo.v) begin
          write_not_read_n = header_flit_in.write_not_read;
          src_cord_n = header_flit_in.src_cord;
          cid_n = header_flit_in.cid;
          mem_state_n = RECV_ADDR;
        end
      end
      
      RECV_ADDR: begin
        wh_conc_link_sif_li.ready_and_rev = 1'b1;
        if (wh_conc_link_sif_lo.v) begin
          addr_n = wh_conc_link_sif_lo.data;
          mem_state_n = write_not_read_r
            ? RECV_EVICT_DATA
            : SEND_FILL_HEADER;
        end
      end

      RECV_EVICT_DATA: begin
        wh_conc_link_sif_li.ready_and_rev = 1'b1;
        if (wh_conc_link_sif_lo.v) begin
          mem_we = 1'b1;
          up_li = (count_lo != data_len_lp-1);
          clear_li = (count_lo == data_len_lp-1);
          mem_state_n = (count_lo == data_len_lp-1)
            ? READY
            : RECV_EVICT_DATA;
        end
      end

      SEND_FILL_HEADER: begin
        wh_conc_link_sif_li.v = 1'b1;
        wh_conc_link_sif_li.data = header_flit_out;
        if (wh_conc_link_sif_lo.ready_and_rev) begin
          mem_state_n = SEND_FILL_DATA;
        end
      end

      SEND_FILL_DATA: begin
        wh_conc_link_sif_li.v = 1'b1;
        wh_conc_link_sif_li.data = mem_r_data;
        if (wh_conc_link_sif_lo.ready_and_rev) begin
          clear_li = (count_lo == data_len_lp-1);
          up_li = (count_lo != data_len_lp-1);
          mem_state_n = (count_lo == data_len_lp-1)
            ? READY
            : SEND_FILL_DATA;
        end
      end

    endcase


  end




  always_ff @ (posedge clk_i) begin
    if (reset_i) begin
      mem_state_r <= RESET;
      write_not_read_r <= 1'b0;
      src_cord_r <= '0;
      cid_r <= '0;
      addr_r <= '0;
    end
    else begin
      mem_state_r <= mem_state_n;
      write_not_read_r <= write_not_read_n;
      src_cord_r <= src_cord_n;
      cid_r <= cid_n;
      addr_r <= addr_n;
    end
  end

endmodule
