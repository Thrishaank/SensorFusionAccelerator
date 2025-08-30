# ==================================
# Vivado/XSIM Simulation TCL Script
# For: Fusion RTL Simulation
# ==================================

# === Setup ===
set proj_name fusion_sim
set work_dir sim_workspace
file mkdir -force $work_dir
cd $work_dir

# === Compile RTL Modules ===
read_verilog ../rtl/imu_fifo.sv
read_verilog ../rtl/lidar_fifo.sv
read_verilog ../rtl/matrix_mult.sv
read_verilog ../rtl/kalman_core.sv
read_verilog ../rtl/fusion_top.sv

# === Compile Testbench ===
read_verilog ../tb/tb_fusion.sv

# === Elaborate Design ===
elaborate tb_fusion -top tb_fusion

# === Open log file for storing simulation results ===
set output_file [open "../results/fusion_sim_output.txt" "w"]
puts $output_file "=== Simulation Output Log ==="
flush $output_file

# === Run Simulation ===
# Run until $finish in testbench
simulate -run all

# === Save Waveform ===
log_wave -recursive *
write_vcd ../waveforms/fusion_chain.vcd

# === Close Output File ===
puts $output_file "\n=== Simulation Completed Successfully ==="
close $output_file

# === Exit ===
exit
