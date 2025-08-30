# ----------------------------------------------
# Vivado TCL Script: run_uvm_sim.tcl
# Purpose: Compile and run AXI-Lite testbench for fusion_top with UVM support
# ----------------------------------------------

# Clean previous simulation artifacts
file delete -force xsim.dir
file delete -force work
file delete -force *.log *.jou *.pb
file delete -force waveforms/fusion_uvm.vcd

# Create output directory if it doesn't exist
if {![file exists waveforms]} {
    file mkdir waveforms
}

# Compile RTL and Testbench sources
xvlog -sv \
  ./rtl/fusion_top.sv \
  ./rtl/imu_fifo.sv \
  ./rtl/lidar_fifo.sv \
  ./rtl/kalman_core.sv \
  ./rtl/matrix_mult.sv \
  ./rtl/fusion_test_pkg.sv \
  ./rtl/imu_seq.sv \
  ./rtl/lidar_seq.sv \
  ./rtl/imu_mon.sv \
  ./rtl/lidar_mon.sv \
  ./rtl/fusion_sb.sv \
  ./rtl/fusion_test_top.sv \
  ./rtl/tb_axi_lite_fusion.sv

# Elaborate the top-level testbench
xelab tb_axi_lite_fusion -L xil_defaultlib -s tb_axi_lite_fusion --debug typical

# Run simulation with commands
xsim tb_axi_lite_fusion -tclbatch sim_commands.tcl
