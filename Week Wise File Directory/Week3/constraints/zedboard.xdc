# === Clock Signal ===
set_property PACKAGE_PIN E3 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

# === Reset Signal (Active Low) ===
set_property PACKAGE_PIN F15 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

# === IMU Data Inputs ===
set_property PACKAGE_PIN T1 [get_ports imu_data_valid]
set_property IOSTANDARD LVCMOS33 [get_ports imu_data_valid]

set_property PACKAGE_PIN U1 [get_ports imu_ax]
set_property IOSTANDARD LVCMOS33 [get_ports imu_ax]

set_property PACKAGE_PIN V1 [get_ports imu_az]
set_property IOSTANDARD LVCMOS33 [get_ports imu_az]

# === LiDAR Data Inputs ===
set_property PACKAGE_PIN W1 [get_ports lidar_data_valid]
set_property IOSTANDARD LVCMOS33 [get_ports lidar_data_valid]

set_property PACKAGE_PIN Y1 [get_ports lidar_range]
set_property IOSTANDARD LVCMOS33 [get_ports lidar_range]

# === Fusion Output ===
set_property PACKAGE_PIN T2 [get_ports fused_result]
set_property IOSTANDARD LVCMOS33 [get_ports fused_result]

set_property PACKAGE_PIN U2 [get_ports fused_valid]
set_property IOSTANDARD LVCMOS33 [get_ports fused_valid]

# === Optional Debug Signals ===
#set_property PACKAGE_PIN V2 [get_ports debug_signal]
#set_property IOSTANDARD LVCMOS33 [get_ports debug_signal]
