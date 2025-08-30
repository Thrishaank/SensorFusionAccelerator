package fusion_test_pkg;

  // Global parameters
  parameter int DATA_WIDTH    = 16;
  parameter int STATE_WIDTH   = 2;
  parameter int VECTOR_LENGTH = 2;

  // AXI-lite register interface placeholder
  typedef struct packed {
    logic [DATA_WIDTH-1:0] ctrl_reg;
    logic [DATA_WIDTH-1:0] status_reg;
  } ctrl_if_t;

  // Input sensor struct
  typedef struct packed {
    logic [DATA_WIDTH-1:0] imu_data;
    logic [DATA_WIDTH-1:0] lidar_data;
    logic                  valid;
  } sensor_input_t;

  // Output state struct
  typedef struct packed {
    logic [DATA_WIDTH-1:0] state_0;
    logic [DATA_WIDTH-1:0] state_1;
    logic                  valid;
  } fusion_output_t;

  // Task: display state
  task automatic print_state(fusion_output_t s);
    $display("[STATE] x = %0d, p = %0d, valid = %b", s.state_0, s.state_1, s.valid);
  endtask

endpackage
