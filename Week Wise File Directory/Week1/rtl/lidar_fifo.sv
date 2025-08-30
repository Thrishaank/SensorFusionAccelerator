module lidar_fifo #(
    parameter DATA_WIDTH = 16
)(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic [DATA_WIDTH-1:0] data_in,
    input  logic                  valid_in,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic                  ready_out
);
    // TODO: Add FIFO buffer logic here
endmodule
