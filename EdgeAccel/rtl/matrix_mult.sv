module matrix_mult #(
    parameter DATA_WIDTH = 16,
    parameter ROWS       = 2,
    parameter COLS       = 2
)(
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic                     start,
    input  logic [DATA_WIDTH-1:0]   mat [ROWS-1:0][COLS-1:0],
    input  logic [DATA_WIDTH-1:0]   vec [COLS-1:0],
    output logic [DATA_WIDTH-1:0]   out [ROWS-1:0],
    output logic                    done
);

    // Internal state machine
    typedef enum logic [1:0] {
        IDLE,
        MULTIPLY,
        DONE
    } mm_state_t;

    mm_state_t state, next_state;

    logic [DATA_WIDTH-1:0] acc[ROWS-1:0];
    logic [$clog2(COLS):0] col_cnt;
    logic row_done;

    // FSM - State transition
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    // FSM - Next state logic
    always_comb begin
        next_state = state;
        case (state)
            IDLE: if (start) next_state = MULTIPLY;
            MULTIPLY: if (row_done) next_state = DONE;
            DONE: next_state = IDLE;
        endcase
    end

    // Computation control
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            col_cnt <= 0;
            acc[0] <= 0;
            acc[1] <= 0;
            row_done <= 0;
        end else begin
            case (state)
                IDLE: begin
                    col_cnt <= 0;
                    acc[0] <= 0;
                    acc[1] <= 0;
                    row_done <= 0;
                end

                MULTIPLY: begin
                    acc[0] <= acc[0] + mat[0][col_cnt] * vec[col_cnt];
                    acc[1] <= acc[1] + mat[1][col_cnt] * vec[col_cnt];

                    if (col_cnt == COLS - 1)
                        row_done <= 1;
                    else
                        col_cnt <= col_cnt + 1;
                end

                DONE: begin
                    col_cnt <= 0;
                    row_done <= 0;
                end
            endcase
        end
    end

    // Output logic
    assign out[0] = acc[0];
    assign out[1] = acc[1];
    assign done   = (state == DONE);

endmodule
