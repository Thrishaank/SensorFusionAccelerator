import numpy as np
import csv
import os

# ----------------------------
# Config
N = 100                           # number of samples
dt = 0.1                          # time step (s)
process_noise_std = 0.2          # Q
measurement_noise_std = 0.5      # R
add_noise = True                 # toggle Gaussian noise
output_dir = "results"
os.makedirs(output_dir, exist_ok=True)
# ----------------------------

# ----------------------------
# 1D Kalman Filter Functions
def kalman_1d(zs, q, r):
    """Basic scalar Kalman Filter for 1D tracking"""
    x = 0.0  # initial state
    p = 1.0  # initial uncertainty

    x_estimates = []

    for z in zs:
        # Prediction
        x_pred = x
        p_pred = p + q

        # Update
        k = p_pred / (p_pred + r)
        x = x_pred + k * (z - x_pred)
        p = (1 - k) * p_pred

        x_estimates.append(x)

    return x_estimates
# ----------------------------

# ----------------------------
# Generate synthetic inputs
true_position = np.linspace(0, 10, N)
imu_measurements = np.gradient(true_position, dt)
lidar_measurements = true_position.copy()

if add_noise:
    imu_measurements += np.random.normal(0, 0.1, N)
    lidar_measurements += np.random.normal(0, 0.3, N)

# Simulated fused input: average of IMU-integrated position and LiDAR
noisy_position = (np.cumsum(imu_measurements * dt) + lidar_measurements) / 2.0

# Apply Kalman Filter
kalman_output = kalman_1d(noisy_position, process_noise_std, measurement_noise_std)
# ----------------------------

# ----------------------------
# Export CSV for reference
csv_path = os.path.join(output_dir, "imu_lidar_data.csv")
with open(csv_path, 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(["Sample", "IMU", "LiDAR", "FusedInput"])
    for i in range(N):
        writer.writerow([i, imu_measurements[i], lidar_measurements[i], noisy_position[i]])
print(f"✅ CSV written to: {csv_path}")
# ----------------------------

# ----------------------------
# Export golden output for RTL testbench
mem_path = os.path.join(output_dir, "expected_output.mem")
with open(mem_path, 'w') as f:
    for val in kalman_output:
        fixed_val = int(val * (2 ** 8))  # Q8 fixed-point
        f.write(f"{fixed_val:016b}\n")
print(f"✅ Memory file written to: {mem_path}")
# ----------------------------

# ----------------------------
# Export float outputs for validation script
txt_path = os.path.join(output_dir, "python_kalman_output.txt")
with open(txt_path, 'w') as f:
    for val in kalman_output:
        f.write(f"{val:.6f}\n")
print(f"✅ Golden float output written to: {txt_path}")
# ----------------------------
