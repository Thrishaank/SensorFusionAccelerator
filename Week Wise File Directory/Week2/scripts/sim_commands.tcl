# ----------------------------------------------
# TCL Script: sim_commands.tcl
# Purpose: Simulation command batch for Vivado XSIM
# ----------------------------------------------

# Enable full waveform dumping for all hierarchies
log_wave -r /*

# Run the simulation for sufficient time
run 1000ns

# Optionally: print a completion message
puts "Simulation complete. Waveform dump saved to waveforms/fusion_uvm.vcd"

# Exit simulation
quit
