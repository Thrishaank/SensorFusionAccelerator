import random
import csv

# Configuration
NUM_SAMPLES = 16
IMU_MEAN = 100
LIDAR_MEAN = 200
STD_DEV = 5               # Standard deviation for Gaussian noise
SEED = 42                 # For reproducibility

# Kalman filter configuration
A = 1.0      # State transition
H = 1.0      # Measurement function
Q = 1.0      # Process noise
R = 4.0      # Measurement noise
P = 1.0      # Initial estimation error
x = 0.0      # Initial state estimate

# Set random seed
random.seed(SEED)

# Output file names
imu_hex_file = "imu_data.mem"
lidar_hex_file = "lidar_data.mem"
csv_file = "imu_lidar_data.csv"
expected_file = "expected_output.mem"

imu_vals = []
lidar_vals = []
kf_outputs = []

# Generate data and apply Kalman filtering
with open(imu_hex_file, 'w') as imu_out, \
     open(lidar_hex_file, 'w') as lidar_out, \
     open(expected_file, 'w') as expected_out, \
     open(csv_file, 'w', newline='') as csv_out:

    csv_writer = csv.writer(csv_out)
    csv_writer.writerow(["sample", "imu", "lidar", "kalman_estimate"])

    for i in range(NUM_SAMPLES):
        imu = int(random.gauss(IMU_MEAN, STD_DEV))
        lidar = int(random.gauss(LIDAR_MEAN, STD_DEV))
        measurement = imu * lidar  # emulate matrix_mult.sv

        # Kalman filter equations (scalar)
        global P, x
        K = P * H / (H * P * H + R)
        x = x + K * (measurement - H * x)
        P = (1 - K * H) * P + Q

        # Store results
        imu_vals.append(imu)
        lidar_vals.append(lidar)
        kf_outputs.append(int(round(x)))

        # Write to hex mem files
        imu_out.write(f"{imu & 0xFFFF:04x}\n")
        lidar_out.write(f"{lidar & 0xFFFF:04x}\n")
        expected_out.write(f"{int(round(x)) & 0xFFFF:04x}\n")

        # CSV log
        csv_writer.writerow([i, imu, lidar, round(x)])

print(f"[✓] Generated {NUM_SAMPLES} samples with Gaussian noise.")
print(f"[✓] Exported: imu_data.mem, lidar_data.mem, expected_output.mem, imu_lidar_data.csv")
