from vcdvcd import VCDVCD
import matplotlib.pyplot as plt

# === CONFIG ===
vcd_file = "fusion_wave.vcd"
signal_prefix = "tb_fusion/dut/"
signal_0 = signal_prefix + "state_out_0"
signal_1 = signal_prefix + "state_out_1"
golden_file = "expected_output.mem"

# === PARSE VCD ===
print("[✓] Parsing VCD...")
vcd = VCDVCD(vcd_file, signals=[signal_0, signal_1], store_tvs=True)

# Extract values
rtl_out_0 = vcd[signal_0]['tv']
rtl_out_1 = vcd[signal_1]['tv']

# Reduce to sampled outputs only (where value changes)
times_0, values_0 = zip(*[(t, int(v, 2)) for t, v in rtl_out_0])
times_1, values_1 = zip(*[(t, int(v, 2)) for t, v in rtl_out_1])

# === LOAD GOLDEN OUTPUT ===
print("[✓] Loading expected_output.mem...")
golden_values = []
with open(golden_file, 'r') as f:
    for line in f:
        golden_values.append(int(line.strip(), 16))

# === PLOT ===
plt.figure(figsize=(10, 6))
plt.plot(times_0, values_0, label="RTL Output: state_out_0", marker='o')
plt.plot(range(len(golden_values)), golden_values, label="Golden Kalman Estimate", linestyle='--', marker='x')

plt.title("RTL vs Golden Kalman Output")
plt.xlabel("Time (ns) / Sample #")
plt.ylabel("Output Value")
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.savefig("rtl_vs_golden.png")
plt.show()
