`timescale 1ns/1ps

module tb_axi_lite_fusion;

  logic clk;
  logic rst_n;

  // AXI-Lite signals
  logic [3:0]   awaddr;
  logic         awvalid;
  logic         awready;
  logic [31:0]  wdata;
  logic [3:0]   wstrb;
  logic         wvalid;
  logic         wready;
  logic [1:0]   bresp;
  logic         bvalid;
  logic         bready;
  logic [3:0]   araddr;
  logic         arvalid;
  logic         arready;
  logic [31:0]  rdata;
  logic [1:0]   rresp;
  logic         rvalid;
  logic         rready;

  // Other fusion_top I/Os (kept constant for AXI test)
  logic [15:0] imu_data = 16'h0000;
  logic imu_valid = 1'b0;
  logic [15:0] lidar_data = 16'h0000;
  logic lidar_valid = 1'b0;
  logic [15:0] kalman_data;
  logic kalman_valid;

  // Instantiate DUT
  fusion_top dut (
    .clk(clk),
    .rst_n(rst_n),
    .s_axi_awaddr(awaddr),
    .s_axi_awvalid(awvalid),
    .s_axi_awready(awready),
    .s_axi_wdata(wdata),
    .s_axi_wstrb(wstrb),
    .s_axi_wvalid(wvalid),
    .s_axi_wready(wready),
    .s_axi_bresp(bresp),
    .s_axi_bvalid(bvalid),
    .s_axi_bready(bready),
    .s_axi_araddr(araddr),
    .s_axi_arvalid(arvalid),
    .s_axi_arready(arready),
    .s_axi_rdata(rdata),
    .s_axi_rresp(rresp),
    .s_axi_rvalid(rvalid),
    .s_axi_rready(rready),
    .imu_data(imu_data),
    .imu_valid(imu_valid),
    .lidar_data(lidar_data),
    .lidar_valid(lidar_valid),
    .kalman_data(kalman_data),
    .kalman_valid(kalman_valid)
  );

  // Clock generation
  always #5 clk = ~clk;

  // AXI write task
  task axi_write(input [3:0] addr, input [31:0] data);
    begin
      @(posedge clk);
      awaddr  <= addr;
      awvalid <= 1;
      wdata   <= data;
      wstrb   <= 4'hF;
      wvalid  <= 1;
      bready  <= 1;

      // Wait for handshake
      wait (awready && wready);
      @(posedge clk);
      awvalid <= 0;
      wvalid  <= 0;

      wait (bvalid);
      @(posedge clk);
      bready <= 0;
    end
  endtask

  // AXI read task
  task axi_read(input [3:0] addr);
    begin
      @(posedge clk);
      araddr  <= addr;
      arvalid <= 1;
      rready  <= 1;

      wait (arready);
      @(posedge clk);
      arvalid <= 0;

      wait (rvalid);
      @(posedge clk);
      $display("Read from 0x%0h = 0x%0h", addr, rdata);
      rready <= 0;
    end
  endtask

  // Test sequence
  initial begin
    clk = 0;
    rst_n = 0;
    #20 rst_n = 1;
    #20;

    // Write enable to IMU (0x0) and LiDAR (0x4)
    axi_write(4'h0, 32'h0000_0001); // imu_enable = 1
    axi_write(4'h4, 32'h0000_0001); // lidar_enable = 1

    // Read back to verify
    axi_read(4'h0); // Should print 1
    axi_read(4'h4); // Should print 1

    // Write 0 to disable IMU
    axi_write(4'h0, 32'h0000_0000); // imu_enable = 0

    // Read back to verify
    axi_read(4'h0); // Should print 0

    #50;
    $display("AXI test complete");
    $finish;
  end
  
initial begin
  $dumpfile("waveforms/fusion_uvm.vcd");
  $dumpvars(0, tb_axi_lite_fusion);  // or fusion_test_top
end

endmodule
