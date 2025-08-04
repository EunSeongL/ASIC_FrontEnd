`timescale 1ps / 1fs

module tb_fft_gatesim_flat ();

  //──────────────────────────────────────────────────────────────────────────
  // Parameters
  //──────────────────────────────────────────────────────────────────────────
  parameter IN_WIDTH  = 9;      // <3.6 format
  parameter OUT_WIDTH = 10;     // <9.4 format
  parameter NUM       = 16;     // samples per cycle
  parameter N         = 512;    // total samples

  //──────────────────────────────────────────────────────────────────────────
  // File I/O and storage
  //──────────────────────────────────────────────────────────────────────────
  integer file, r, out_file;
  integer i_blk, j_blk;
  integer clk_count;
  logic signed [IN_WIDTH-1:0] din_i_data [0:N-1];
  logic signed [IN_WIDTH-1:0] din_q_data [0:N-1];

  //──────────────────────────────────────────────────────────────────────────
  // DUT I/O as flattened buses
  //──────────────────────────────────────────────────────────────────────────
  logic                   valid_in;
  logic                   valid_out;
  logic [IN_WIDTH*NUM-1:0]  din_i_bus,  din_q_bus;
  logic [OUT_WIDTH*NUM-1:0] dout_i_bus, dout_q_bus;

  // unpacked outputs for printing
  logic signed [OUT_WIDTH-1:0] dout_i [0:NUM-1];
  logic signed [OUT_WIDTH-1:0] dout_q [0:NUM-1];

  //──────────────────────────────────────────────────────────────────────────
  // Clock / Reset / Edge detection
  //──────────────────────────────────────────────────────────────────────────
  logic clk, rstn;
  logic prev_valid_out, falling_edge_detected;

  // 100 MHz clock → 10 ns period
  always #5 clk = ~clk;

  // detect falling edge of valid_out once
  always @(posedge clk) begin
    prev_valid_out <= valid_out;
    if (prev_valid_out && !valid_out)
      falling_edge_detected <= 1;
  end

  //──────────────────────────────────────────────────────────────────────────
  // Stimulus & File writing
  //──────────────────────────────────────────────────────────────────────────
  initial begin
    // read input samples from file
    file = $fopen("data_fixed.txt", "r");
    if (file == 0) $fatal("Cannot open data_fixed.txt");
    for (i_blk = 0; i_blk < N; i_blk = i_blk + 1) begin
      r = $fscanf(file, "%d %d\n",
        din_i_data[i_blk], din_q_data[i_blk]);
      if (r != 2) $fatal("Read error at line %0d", i_blk+1);
    end
    $fclose(file);

    // open output file
    out_file = $fopen("butterfly00_output.txt", "w");
    if (out_file == 0) $fatal("Cannot open fft_output_design.txt");

    // init signals
    clk               = 0;
    rstn              = 0;
    valid_in          = 0;
    falling_edge_detected = 0;
    clk_count         = 0;

    // release reset
    #15 rstn = 1;

    // drive 32 blocks of 16 samples each
    for (i_blk = 0; i_blk < N/NUM; i_blk = i_blk + 1) begin
      // pack 16 samples into the buses
      for (j_blk = 0; j_blk < NUM; j_blk = j_blk + 1) begin
        din_i_bus[j_blk*IN_WIDTH +: IN_WIDTH] = din_i_data[i_blk*NUM + j_blk];
        din_q_bus[j_blk*IN_WIDTH +: IN_WIDTH] = din_q_data[i_blk*NUM + j_blk];
      end
      @(posedge clk);
      valid_in = 1;
    end

     @(posedge clk);
      valid_in = 0;

    // wait for end of output burst
    wait (falling_edge_detected);

    // give DUT time to finish
    #100;
    $fclose(out_file);
    $stop;
  end

  // on each clock, if valid_out, unpack and write outputs
  always @(posedge clk) begin
    clk_count <= clk_count + 1;
    if (valid_out) begin
      for (int j = 0; j < NUM; j = j + 1) begin
        dout_i[j] = $signed(dout_i_bus[j*OUT_WIDTH +: OUT_WIDTH]);
        dout_q[j] = $signed(dout_q_bus[j*OUT_WIDTH +: OUT_WIDTH]);
        $fwrite(out_file, "%0d %0d\n", dout_i[j], dout_q[j]);
      end
    end
  end

  //──────────────────────────────────────────────────────────────────────────
  // DUT instantiation (flattened-port FFT module)
  //──────────────────────────────────────────────────────────────────────────
  butterfly #(
  ) dut (
    .clk       (clk),
    .rstn      (rstn),
    .valid_in  (valid_in),
    .din_i     (din_i_bus),   // 144-bit packed
    .din_q     (din_q_bus),   // 144-bit packed
    .valid_out (valid_out),
    .do1_re    (dout_i_bus),  // 208-bit packed
    .do1_im    (dout_q_bus)   // 208-bit packed
  );

endmodule
