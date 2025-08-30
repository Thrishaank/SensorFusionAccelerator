module imu_fifo #(
    parameter DATA_WIDTH = 16,
    parameter DEPTH = 16,              // FIFO depth (default: 16 entries)
    parameter ADDR_WIDTH = $clog2(DEPTH)
)(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic [DATA_WIDTH-1:0] data_in,
    input  logic                  valid_in,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic                  ready_out
);

    // === Internal FIFO Storage ===
    logic [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];
    logic [ADDR_WIDTH-1:0] wr_ptr, rd_ptr;
    logic                  full, empty;

    // === FIFO Full and Empty Flags ===
    assign full  = (wr_ptr + 1 == rd_ptr);
    assign empty = (wr_ptr == rd_ptr);

    // === Ready to Accept New Data? ===
    assign ready_out = !empty;

    // === Read Logic ===
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= 0;
            data_out <= '0;
        end else if (!empty) begin
            data_out <= fifo_mem[rd_ptr];
            if (!full && valid_in)
                rd_ptr <= rd_ptr + 1; // concurrent read/write
            else if (!valid_in)
                rd_ptr <= rd_ptr + 1;
        end
    end

    // === Write Logic ===
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
        end else if (valid_in && !full) begin
            fifo_mem[wr_ptr] <= data_in;
            wr_ptr <= wr_ptr + 1;
        end
    end

endmodule
