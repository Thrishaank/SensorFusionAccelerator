`timescale 1ns / 1ps
`include "fusion_test_pkg.sv"

module fusion_test_top;

  import fusion_test_pkg::*;

  // Parameters
  parameter CLK_PERIOD = 10;

  // DUT I/O
  logic clk, rst_n, start, valid_in, valid_out;
  logic [DATA_WIDTH-1:0] imu_data, lidar_data;
  logic [DATA_WIDTH-1:0] kalman_out [STATE_WIDTH-1:0];

  // Clock generation
  initial clk = 0;
  always #(CLK_PERIOD/2) clk = ~clk;

  // DUT instantiation
  fusion_top dut (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .imu_data(imu_data),
    .lidar_data(lidar_data),
    .valid_in(valid_in),
    .kalman_out(kalman_out),
    .valid_out(valid_out)
  );

  // VCD dump
  initial begin
    $dumpfile("fusion_wave.vcd");
    $dumpvars(0, fusion_test_top);
  end

  // Test logic
  initial begin
    // Reset
    rst_n = 0; start = 0; valid_in = 0;
    imu_data = 0; lidar_data = 0;
    repeat (5) @(posedge clk);
    rst_n = 1;

    // Apply sensor inputs
    for (int i = 0; i < 10; i++) begin
      @(posedge clk);
      imu_data = 16'd100 + i;          // synthetic IMU
      lidar_data = 16'd120 + i * 2;    // synthetic LiDAR
      valid_in = 1;
      start = 1;
    end

    // Stop driving input
    @(posedge clk);
    valid_in = 0;
    start = 0;

    // Wait for result
    wait (valid_out);
    $display("Kalman Output: x=%0d, p=%0d", kalman_out[0], kalman_out[1]);

    // End simulation
    repeat (10) @(posedge clk);
    $finish;
  end

endmodule
