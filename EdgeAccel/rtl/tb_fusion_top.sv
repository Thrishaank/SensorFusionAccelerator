module tb_fusion_top;

  logic clk;
  logic rst_n;
  logic [15:0] imu_ax;
  logic [15:0] imu_az;
  logic        valid_in;
  logic [15:0] fusion_result;
  logic        fusion_valid;

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;  // 100 MHz

  // DUT instantiation with correct ports
  fusion_top dut (
    .clk           (clk),
    .rst_n         (rst_n),
    .imu_ax        (imu_ax),
    .imu_az        (imu_az),
    .valid_in      (valid_in),
    .fusion_result (fusion_result),
    .fusion_valid  (fusion_valid)
  );

  // Stimulus
  initial begin
    rst_n = 0;
    imu_ax = 0;
    imu_az = 0;
    valid_in = 0;
    #20;

    rst_n = 1;
    #10;

    // Send test samples
    repeat (10) begin
      @(posedge clk);
      imu_ax = $random;
      imu_az = $random;
      valid_in = 1;
    end

    @(posedge clk);
    valid_in = 0;

    #100;
    $finish;
  end

  // CSV logging
  integer outfile;
  initial begin
    outfile = $fopen("results/rtl_output.csv", "w");
    $fwrite(outfile, "fusion_result\n");  // Header
  end

  always_ff @(posedge clk) begin
    if (fusion_valid)
      $fwrite(outfile, "%0d\n", fusion_result);
  end

  final begin
    $fclose(outfile);
  end

  // VCD dumping
  initial begin
    $dumpfile("waveforms/fusion_waveform.vcd");
    $dumpvars(0, tb_fusion_top);
  end

endmodule
