module imu_mon #(
    parameter DATA_WIDTH = 16,
    parameter SEQ_LEN = 16
)(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic [DATA_WIDTH-1:0] imu_data,
    input  logic                  valid
);

    int sample_count;

    // File output (optional logging)
    integer log_file;

    initial begin
        log_file = $fopen("imu_monitor_log.txt", "w");
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            sample_count <= 0;
        end else if (valid) begin
            sample_count++;
            $display("[IMU_MON] Sample %0d: imu_data = %0d", sample_count, imu_data);
            $fwrite(log_file, "%0d\n", imu_data);
        end
    end

    final begin
        $fclose(log_file);
        $display("[IMU_MON] Monitoring finished. %0d samples logged.", sample_count);
    end

endmodule
