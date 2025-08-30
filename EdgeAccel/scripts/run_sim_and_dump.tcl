# -------------------------------------------------------------------
# TCL Script: run_sim_and_dump.tcl
# Purpose   : Run behavioral simulation, dump waveform, and store logs
# Project   : fusion_top RTL Simulation
# -------------------------------------------------------------------

# Set paths
set proj_path "C:/Users/thris/EdgeAccelerator/SET2/project_1/project_1.xpr"
set sim_dir   "C:/Users/thris/EdgeAccelerator/TestingLayout/sim_output"
set sim_waveform "$sim_dir/fusion_waveform.wdb"
set sim_log     "$sim_dir/simulation_log.txt"
set tb_file     "C:/Users/thris/EdgeAccelerator/TestingLayout/rtl/tb_fusion_top.sv"

# Create output directory
file mkdir $sim_dir

# Open project
if {[get_projects] eq ""} {
    puts "📂 Opening Vivado Project..."
    open_project $proj_path
} else {
    puts "📂 Project already open: [current_project]"
}

# Add testbench file if not already present
if {[lsearch [get_files] $tb_file] < 0} {
    puts "➕ Adding testbench file: $tb_file"
    add_files -fileset sim_1 $tb_file
} else {
    puts "✅ Testbench already present"
}

# Set top module for simulation
puts "🔧 Setting simulation top to: tb_fusion_top"
set_property top tb_fusion_top [get_filesets sim_1]

# Launch simulation
puts "🚀 Launching behavioral simulation..."
launch_simulation -mode behavioral

# Run full simulation
puts "⏳ Running simulation..."
run all

# Dump waveform
puts "💾 Saving waveform to: $sim_waveform"
write_waveform $sim_waveform

# Log simulation output
puts "📝 Writing simulation log to: $sim_log"
set fp [open $sim_log "w"]
puts $fp "RTL Simulation Log"
puts $fp "=================="
puts $fp "Project: project_1"
puts $fp "Date: [clock format [clock seconds] -format {%Y-%m-%d %H:%M:%S}]"
puts $fp "Waveform: $sim_waveform"
puts $fp "Top Module: tb_fusion_top"
puts $fp "Status: ✅ Completed"
close $fp

puts "\n✅ DONE: Simulation complete. Waveform and logs saved."
