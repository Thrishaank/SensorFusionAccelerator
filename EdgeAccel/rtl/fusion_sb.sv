module fusion_sb #(
    parameter DATA_WIDTH = 16,
    parameter SEQ_LEN     = 16,
    parameter MEM_FILE    = "expected_output.mem"
)(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  valid,
    input  logic [DATA_WIDTH-1:0] kalman_out
);

    logic [DATA_WIDTH-1:0] golden_mem [0:SEQ_LEN-1];
    integer sample_count;
    logic [DATA_WIDTH-1:0] expected;

    initial begin
        $readmemh(MEM_FILE, golden_mem);
        $display("[SB] Loaded expected output from %s", MEM_FILE);
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            sample_count <= 0;
        end else if (valid) begin
            expected = golden_mem[sample_count];
            if (kalman_out !== expected) begin
                $display("[SB][ERROR] Sample %0d mismatch: Expected = %0d, Got = %0d",
                         sample_count, expected, kalman_out);
            end else begin
                $display("[SB][OK] Sample %0d matched: %0d", sample_count, kalman_out);
            end
            sample_count <= sample_count + 1;
        end
    end

endmodule
