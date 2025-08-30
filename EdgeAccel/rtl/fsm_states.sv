typedef enum logic [1:0] {
    IDLE,
    WAIT_DATA,
    COMPUTE,
    DONE
} fsm_state_t;
