# --------------------------------------------------
# TCL Script: synth_and_report.tcl
# Purpose   : Run synthesis for fusion_top on ZedBoard
# Target    : Vivado Project - project_1.xpr
# --------------------------------------------------

# Set paths
set proj_path "C:/Users/thris/EdgeAccelerator/SET2/project_1/project_1.xpr"
set rpt_out_path "C:/Users/thris/EdgeAccelerator/SET2/project_1/synthesis/fusion_utilization.rpt"

# Open project if not already open
if {[get_projects] eq ""} {
    puts "📂 Opening Vivado Project..."
    open_project $proj_path
} else {
    puts "⚠️  Project already open: [current_project]"
}

# Run synthesis
puts "🛠️  Launching synthesis..."
launch_runs synth_1
wait_on_run synth_1

# Open synthesized netlist
puts "🔍 Opening synthesized design..."
open_run synth_1

# Generate utilization report
puts "📊 Generating utilization report..."
file mkdir [file dirname $rpt_out_path]
report_utilization -file $rpt_out_path

puts "\n✅ Synthesis complete. Report saved to:"
puts $rpt_out_path
