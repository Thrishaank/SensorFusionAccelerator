module fusion_top (
  input  logic         clk,
  input  logic         rst_n,

  // AXI4-Lite interface
  input  logic [3:0]   s_axi_awaddr,
  input  logic         s_axi_awvalid,
  output logic         s_axi_awready,
  input  logic [31:0]  s_axi_wdata,
  input  logic [3:0]   s_axi_wstrb,
  input  logic         s_axi_wvalid,
  output logic         s_axi_wready,
  output logic [1:0]   s_axi_bresp,
  output logic         s_axi_bvalid,
  input  logic         s_axi_bready,
  input  logic [3:0]   s_axi_araddr,
  input  logic         s_axi_arvalid,
  output logic         s_axi_arready,
  output logic [31:0]  s_axi_rdata,
  output logic [1:0]   s_axi_rresp,
  output logic         s_axi_rvalid,
  input  logic         s_axi_rready,

  // Sensor interface
  input  logic [15:0]  imu_data,
  input  logic         imu_valid,
  input  logic [15:0]  lidar_data,
  input  logic         lidar_valid,

  // Kalman output
  output logic [15:0]  kalman_data,
  output logic         kalman_valid
);

  // ---------------------------------------------------------
  // AXI-lite register space
  // ---------------------------------------------------------
  typedef enum logic [3:0] {
    REG_IMU_ENABLE_ADDR   = 4'h0,
    REG_LIDAR_ENABLE_ADDR = 4'h4
  } reg_addr_t;

  logic imu_enable_reg, lidar_enable_reg;

  logic axi_awready_r, axi_wready_r, axi_bvalid_r;
  logic axi_arready_r, axi_rvalid_r;
  logic [31:0] axi_rdata_r;
  logic [1:0] axi_bresp_r, axi_rresp_r;

  assign s_axi_awready = axi_awready_r;
  assign s_axi_wready  = axi_wready_r;
  assign s_axi_bvalid  = axi_bvalid_r;
  assign s_axi_bresp   = axi_bresp_r;
  assign s_axi_arready = axi_arready_r;
  assign s_axi_rvalid  = axi_rvalid_r;
  assign s_axi_rdata   = axi_rdata_r;
  assign s_axi_rresp   = axi_rresp_r;

  // ---------------------------------------------------------
  // Write logic
  // ---------------------------------------------------------
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      imu_enable_reg   <= 0;
      lidar_enable_reg <= 0;
      axi_awready_r    <= 0;
      axi_wready_r     <= 0;
      axi_bvalid_r     <= 0;
      axi_bresp_r      <= 2'b00;
    end else begin
      axi_awready_r <= s_axi_awvalid && !axi_awready_r;
      axi_wready_r  <= s_axi_wvalid && !axi_wready_r;

      if (axi_awready_r && s_axi_awvalid && axi_wready_r && s_axi_wvalid) begin
        case (s_axi_awaddr)
          REG_IMU_ENABLE_ADDR:   imu_enable_reg   <= s_axi_wdata[0];
          REG_LIDAR_ENABLE_ADDR: lidar_enable_reg <= s_axi_wdata[0];
        endcase
        axi_bvalid_r <= 1;
        axi_bresp_r  <= 2'b00;
      end else if (s_axi_bready) begin
        axi_bvalid_r <= 0;
      end
    end
  end

  // ---------------------------------------------------------
  // Read logic
  // ---------------------------------------------------------
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      axi_arready_r <= 0;
      axi_rvalid_r  <= 0;
      axi_rdata_r   <= 0;
      axi_rresp_r   <= 2'b00;
    end else begin
      axi_arready_r <= s_axi_arvalid && !axi_arready_r;
      if (axi_arready_r && s_axi_arvalid) begin
        axi_rvalid_r <= 1;
        axi_rresp_r  <= 2'b00;
        case (s_axi_araddr)
          REG_IMU_ENABLE_ADDR:   axi_rdata_r <= imu_enable_reg;
          REG_LIDAR_ENABLE_ADDR: axi_rdata_r <= lidar_enable_reg;
          default:               axi_rdata_r <= 32'hDEADBEEF;
        endcase
      end else if (s_axi_rready) begin
        axi_rvalid_r <= 0;
      end
    end
  end

  // ---------------------------------------------------------
  // Connect to submodules (when implemented)
  // ---------------------------------------------------------
  logic [15:0] kalman_out;
  logic        kalman_out_valid;

  assign kalman_data  = kalman_out;
  assign kalman_valid = kalman_out_valid;

  // TODO: instantiate kalman_core and matrix_mult
  // and connect with imu/lidar gated by enable registers

endmodule
