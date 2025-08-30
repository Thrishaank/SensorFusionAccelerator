module lidar_mon (
  input  logic        clk,
  input  logic        rst_n,
  input  logic [15:0] lidar_data,
  input  logic        valid
);

  int sample_count;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sample_count <= 0;
    end else if (valid) begin
      $display("[LiDAR MON] Time: %0t | Sample %0d | Data: %0d", $time, sample_count, lidar_data);
      sample_count <= sample_count + 1;
    end
  end

endmodule
