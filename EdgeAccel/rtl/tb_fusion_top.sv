module tb_fusion_top;

  logic clk;
  logic rst_n;
  logic [15:0] ax_in;
  logic [15:0] az_in;
  logic        valid_in;
  logic [15:0] fusion_out;
  logic        valid_out;

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;  // 100 MHz

  // DUT instantiation (updated port names)
  fusion_top dut (
    .clk        (clk),
    .rst_n      (rst_n),
    .ax_in      (ax_in),
    .az_in      (az_in),
    .valid_in   (valid_in),
    .fusion_out (fusion_out),
    .valid_out  (valid_out)
  );

  // Stimulus
  initial begin
    rst_n = 0;
    ax_in = 0;
    az_in = 0;
    valid_in = 0;
    #20;

    rst_n = 1;
    #10;

    // Send test samples
    repeat (10) begin
      @(posedge clk);
      ax_in = $random;
      az_in = $random;
      valid_in = 1;
    end

    @(posedge clk);
    valid_in = 0;

    #100;
    $finish;
  end

endmodule
