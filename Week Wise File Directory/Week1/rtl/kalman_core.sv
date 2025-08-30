module kalman_core (
    input logic clk,
    input logic rst_n,
    input logic valid_in,
    input logic [15:0] imu_data,
    input logic [15:0] lidar_data,
    output logic [15:0] kalman_out,
    output logic valid_out
);

    // Fixed-point parameters
    parameter Q = 16'd1;      // Process noise covariance
    parameter R = 16'd10;     // Measurement noise covariance

    // Internal registers
    logic [15:0] x_est;       // Estimated state
    logic [15:0] P;           // Estimation error covariance
    logic [15:0] K;           // Kalman gain
    logic [15:0] z;           // Measurement
    logic [15:0] y;           // Innovation
    logic [31:0] temp1, temp2;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x_est     <= 16'd0;
            P         <= 16'd1;
            kalman_out <= 16'd0;
            valid_out <= 0;
        end else if (valid_in) begin
            // Prediction step
            P <= P + Q;

            // Measurement update step
            z <= (imu_data + lidar_data) >> 1; // simple fusion
            y <= z - x_est;

            // Kalman gain K = P / (P + R)
            temp1 = P << 16;  // multiply by 2^16 for fixed-point division
            temp2 = P + R;
            K <= temp1 / temp2;

            // Update estimate: x = x + K*y
            x_est <= x_est + ((K * y) >> 16);

            // Update error covariance: P = (1 - K) * P
            P <= ((16'd65536 - K) * P) >> 16;

            kalman_out <= x_est;
            valid_out  <= 1;
        end else begin
            valid_out <= 0;
        end
    end

endmodule
