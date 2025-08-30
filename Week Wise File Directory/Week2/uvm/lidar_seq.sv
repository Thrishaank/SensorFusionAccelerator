module lidar_seq #(
    parameter DATA_WIDTH = 16,
    parameter SEQ_LEN = 16
)(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  enable,
    output logic [DATA_WIDTH-1:0] lidar_data,
    output logic                  valid
);

    logic [$clog2(SEQ_LEN)-1:0] idx;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            idx        <= 0;
            valid      <= 0;
            lidar_data <= 0;
        end else if (enable) begin
            if (idx < SEQ_LEN) begin
                lidar_data <= 16'd120 + idx * 3;  // Example LiDAR pattern
                valid      <= 1;
                idx        <= idx + 1;
            end else begin
                valid <= 0;
            end
        end else begin
            valid <= 0;
        end
    end

endmodule
