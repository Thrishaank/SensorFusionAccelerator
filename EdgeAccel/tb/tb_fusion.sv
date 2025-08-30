`timescale 1ns/1ps

module tb_fusion;

  // Clock and reset
  logic clk;
  logic rst_n;

  // DUT inputs/outputs
  logic [15:0] imu_data, lidar_data;
  logic        imu_valid, lidar_valid;
  logic        kalman_valid;
  logic [15:0] kalman_out;

  // Stimulus control
  logic imu_enable, lidar_enable;

  // Clock generation
  always #5 clk = ~clk;

  // DUT instantiation
  fusion_top dut (
    .clk(clk),
    .rst_n(rst_n),
    .imu_data(imu_data),
    .imu_valid(imu_valid),
    .lidar_data(lidar_data),
    .lidar_valid(lidar_valid),
    .kalman_data(kalman_out),
    .kalman_valid(kalman_valid)
  );

  // IMU/LiDAR stimulus
  imu_seq imu_gen (
    .clk(clk),
    .rst_n(rst_n),
    .enable(imu_enable),
    .imu_data(imu_data),
    .valid(imu_valid)
  );

  lidar_seq lidar_gen (
    .clk(clk),
    .rst_n(rst_n),
    .enable(lidar_enable),
    .lidar_data(lidar_data),
    .valid(lidar_valid)
  );

  // Monitoring
  imu_mon imu_monitor (
    .clk(clk),
    .rst_n(rst_n),
    .imu_data(imu_data),
    .valid(imu_valid)
  );

  lidar_mon lidar_monitor (
    .clk(clk),
    .rst_n(rst_n),
    .lidar_data(lidar_data),
    .valid(lidar_valid)
  );

  // Scoreboard
  fusion_sb #(
    .DATA_WIDTH(16),
    .SEQ_LEN(16),
    .MEM_FILE("expected_output.mem")
  ) fusion_scoreboard (
    .clk(clk),
    .rst_n(rst_n),
    .valid(kalman_valid),
    .kalman_out(kalman_out)
  );

  // VCD dump
  initial begin
    $dumpfile("fusion_wave.vcd");
    $dumpvars(0, tb_fusion);
  end

  // Test sequence
  initial begin
    clk = 0;
    rst_n = 0;
    imu_enable = 0;
    lidar_enable = 0;
    #20;
    rst_n = 1;
    #20;
    imu_enable = 1;
    lidar_enable = 1;

    // Run simulation long enough to capture all output
    #1000;
    $display("Testbench completed.");
    $finish;
  end

initial begin
  $dumpfile("waveforms1/fusion_uvm.vcd");
  $dumpvars(0, tb_fusion);  // or fusion_test_top
end

endmodule
