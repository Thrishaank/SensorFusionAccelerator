`timescale 1ns/1ps

module sensor_fusion_top #(
    parameter DATA_WIDTH   = 16,
    parameter STATE_WIDTH  = 2,     // [position, velocity]
    parameter AXI_ADDR_W   = 4,
    parameter AXI_DATA_W   = 32
)(
    input  logic                       clk,
    input  logic                       rst_n,

    // AXI4-Lite slave interface
    input  logic                       s_axi_aclk,
    input  logic                       s_axi_aresetn,
    input  logic                       s_axi_awvalid,
    input  logic [AXI_ADDR_W-1:0]      s_axi_awaddr,
    output logic                       s_axi_awready,
    input  logic                       s_axi_wvalid,
    input  logic [AXI_DATA_W-1:0]      s_axi_wdata,
    output logic                       s_axi_wready,
    output logic                       s_axi_bvalid,
    input  logic                       s_axi_bready,
    input  logic                       s_axi_arvalid,
    input  logic [AXI_ADDR_W-1:0]      s_axi_araddr,
    output logic                       s_axi_arready,
    output logic [AXI_DATA_W-1:0]      s_axi_rdata,
    output logic                       s_axi_rvalid,
    input  logic                       s_axi_rready,

    // Sensor inputs
    input  logic [DATA_WIDTH-1:0]      imu_in,
    input  logic                       imu_valid,
    input  logic [DATA_WIDTH-1:0]      lidar_in,
    input  logic                       lidar_valid
);

    // ======================
    // AXI4-Lite Registers
    // ======================
    logic [AXI_DATA_W-1:0] ctrl_reg, status_reg;
    logic [AXI_DATA_W-1:0] state_out_0, state_out_1;
    logic                  axi_read_en, axi_write_en;

    assign s_axi_awready = 1'b1;
    assign s_axi_wready  = 1'b1;
    assign s_axi_bvalid  = s_axi_awvalid && s_axi_wvalid;
    assign s_axi_arready = 1'b1;
    assign s_axi_rvalid  = s_axi_arvalid;

    // Write logic
    always_ff @(posedge s_axi_aclk or negedge s_axi_aresetn) begin
        if (!s_axi_aresetn) begin
            ctrl_reg <= 32'd0;
        end else if (s_axi_awvalid && s_axi_wvalid) begin
            case (s_axi_awaddr)
                4'h0: ctrl_reg <= s_axi_wdata;
            endcase
        end
    end

    // Read logic
    always_ff @(posedge s_axi_aclk or negedge s_axi_aresetn) begin
        if (!s_axi_aresetn) begin
            s_axi_rdata <= 32'd0;
        end else if (s_axi_arvalid) begin
            case (s_axi_araddr)
                4'h4: s_axi_rdata <= {31'd0, done};
                4'h8: s_axi_rdata <= state_out_0;
                4'hC: s_axi_rdata <= state_out_1;
                default: s_axi_rdata <= 32'd0;
            endcase
        end
    end

    // ======================
    // FSM: start → compute → done
    // ======================
    typedef enum logic [1:0] {
        IDLE,
        WAIT_DATA,
        COMPUTE,
        DONE
    } fsm_state_t;

    fsm_state_t state, next_state;
    logic start, done;

    assign start = ctrl_reg[0];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE:      if (start) next_state = WAIT_DATA;
            WAIT_DATA: if (imu_ready && lidar_ready) next_state = COMPUTE;
            COMPUTE:   if (kf_valid) next_state = DONE;
            DONE:      next_state = IDLE;
        endcase
    end

    // ======================
    // Internal Wires
    // ======================
    logic [DATA_WIDTH-1:0] imu_data, lidar_data;
    logic imu_ready, lidar_ready;

    logic [DATA_WIDTH-1:0] matrix_out;
    logic matrix_valid;

    logic [DATA_WIDTH-1:0] kf_out [STATE_WIDTH-1:0];
    logic kf_valid;

    // ======================
    // Submodule Instances
    // ======================

    imu_fifo imu_fifo_inst (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(imu_in),
        .valid_in(imu_valid),
        .data_out(imu_data),
        .ready_out(imu_ready)
    );

    lidar_fifo lidar_fifo_inst (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(lidar_in),
        .valid_in(lidar_valid),
        .data_out(lidar_data),
        .ready_out(lidar_ready)
    );

    matrix_mult matrix_mult_inst (
        .clk(clk),
        .rst_n(rst_n),
        .a(imu_data),
        .b(lidar_data),
        .product(matrix_out),
        .valid_out(matrix_valid)
    );

    kalman_core kalman_core_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start(state == COMPUTE),
        .z(matrix_out),
        .valid_in(matrix_valid),
        .state_out(kf_out),
        .valid_out(kf_valid)
    );

    // ======================
    // Output Registers
    // ======================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            done <= 1'b0;
            state_out_0 <= 32'd0;
            state_out_1 <= 32'd0;
        end else if (kf_valid) begin
            state_out_0 <= kf_out[0];
            state_out_1 <= kf_out[1];
            done <= 1'b1;
        end else if (state == IDLE) begin
            done <= 1'b0;
        end
    end

endmodule
