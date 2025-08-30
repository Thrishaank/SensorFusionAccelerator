import csv
import matplotlib.pyplot as plt

# File to read
csv_file = "imu_lidar_data.csv"

# Storage
samples = []
imu_data = []
lidar_data = []
kalman_out = []

# Read CSV
with open(csv_file, newline='') as f:
    reader = csv.DictReader(f)
    for row in reader:
        samples.append(int(row["sample"]))
        imu_data.append(int(row["imu"]))
        lidar_data.append(int(row["lidar"]))
        kalman_out.append(float(row["kalman_estimate"]))

# Plotting
plt.figure(figsize=(10, 6))
plt.plot(samples, imu_data, label="IMU", marker='o', linestyle='--')
plt.plot(samples, lidar_data, label="LiDAR", marker='s', linestyle='--')
plt.plot(samples, kalman_out, label="Kalman Estimate", marker='x', linewidth=2)

plt.title("Sensor Fusion: IMU vs LiDAR vs Kalman Filter Output")
plt.xlabel("Sample #")
plt.ylabel("Sensor Value")
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.savefig("fusion_plot.png")
plt.show()
