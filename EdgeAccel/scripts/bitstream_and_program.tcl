# -----------------------------------------------
# TCL Script: bitstream_and_program.tcl
# Purpose : Bitstream Generation and ZedBoard Programming
# Target  : fusion_top for Zynq ZedBoard (xc7z020clg484-1)
# -----------------------------------------------

# Set project path
set proj_path ./fusion_top.xpr
set bit_out_path ./bitstreams/fusion_top.bit
set rpt_out_path ./synthesis/fusion_implementation.rpt
set log_out_path ./results/fpga_programming_log.md

# Open project if not already open
if {[get_projects] eq ""} {
    puts "📂 Opening Vivado Project..."
    open_project $proj_path
} else {
    puts "📁 Project already open: [current_project]"
}

# Run implementation (with reset)
puts "🛠️  Resetting and Running Implementation..."
reset_run impl_1
launch_runs impl_1
wait_on_run impl_1

# Report implementation
puts "📄 Generating Implementation Report..."
report_timing_summary -file $rpt_out_path

# Generate bitstream
puts "🧩 Generating Bitstream..."
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

# Copy bitstream to output folder
puts "📁 Copying Bitstream..."
file copy -force ./fusion_top.runs/impl_1/fusion_top.bit $bit_out_path

# JTAG Programming
puts "⚡ Connecting to hardware and programming ZedBoard..."
open_hw
connect_hw_server
open_hw_target
set device [lindex [get_hw_devices] 0]
current_hw_device $device
refresh_hw_device -update_hw_probes false $device
set_property PROGRAM.FILE $bit_out_path $device
program_hw_devices $device

# Create log directory if needed
file mkdir results

# Write programming log
puts "📝 Writing programming log..."
set fp [open $log_out_path "w"]
puts $fp "# FPGA Programming Log — ZedBoard"
puts $fp "\n**Date**: [clock format [clock seconds] -format {%Y-%m-%d %H:%M:%S}]"
puts $fp "**Project**: fusion_top"
puts $fp "**Bitstream**: $bit_out_path"
puts $fp "**Programming Status**: ✅ Success"
puts $fp "**Mode**: JTAG"
puts $fp "**Board**: Zynq-7000 ZedBoard"
puts $fp "**Clock Source**: On-board 100 MHz"
puts $fp "**Reset Pin**: F15"
close $fp

puts "\n✅ DONE: Bitstream generated and FPGA programmed successfully!"
