import numpy as np

# Fixed-point Q8.8 helpers
FRACTION_BITS = 8
FIX_SCALE = 1 << FRACTION_BITS
def to_fixed(x): return int(round(x * FIX_SCALE))
def from_fixed(x): return x / FIX_SCALE

# Kalman parameters (Q8.8 format)
P = to_fixed(1.0)        # initial estimation error
Q = to_fixed(0.039)      # process noise
R = to_fixed(0.25)       # measurement noise
x_hat = 0                # initial state estimate (Q8.8)

# Load IMU/LiDAR
def load_mem(filename):
    with open(filename, 'r') as f:
        return [int(line.strip(), 16) for line in f.readlines()]

imu = load_mem("imu_data.mem")
lidar = load_mem("lidar_data.mem")

# RTL expected output
expected_rtl = load_mem("expected_output.mem")

# Track values
outputs = []

print(f"{'Sample':<8}{'Meas':<8}{'Kalman Est':<12}{'Expected':<10}{'Match?'}")
print("-" * 50)

for i, (a, b) in enumerate(zip(imu, lidar)):
    # Convert to signed Q8.8
    a_signed = np.int16(a)
    b_signed = np.int16(b)
    
    # Measurement z = a * b (Q8.8 * Q8.8 = Q16.16 >> 8 = Q8.8)
    z_full = a_signed * b_signed
    z = z_full >> FRACTION_BITS

    # K = P / (P + R), scaled for fixed point
    K_fp = (P << FRACTION_BITS) // (P + R)
    K = K_fp

    # residual = z - x_hat
    residual = z - x_hat

    # update = K * residual >> 8
    update = (K * residual) >> FRACTION_BITS
    x_hat = x_hat + update

    # Update P
    one = 1 << FRACTION_BITS
    P = ((one - K) * P) >> FRACTION_BITS
    P = P + Q

    # Save output and compare
    rtl_val = np.int16(expected_rtl[i])
    match = ("YES" if x_hat == rtl_val else "NO ")
    outputs.append(x_hat)

    print(f"{i:<8}{z:<8}{x_hat:<12}{rtl_val:<10}{match}")

# Optional: Save output
with open("kalman_computed.mem", 'w') as out:
    for val in outputs:
        out.write(f"{val & 0xFFFF:04x}\n")

print("\n[✓] Validation complete.")
