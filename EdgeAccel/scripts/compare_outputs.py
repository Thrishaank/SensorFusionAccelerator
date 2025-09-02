import csv
import numpy as np

# Paths (edit if needed)
rtl_output_path = "results/rtl_output.csv"       # from simulation dump
golden_output_path = "results/golden_output.csv" # from python model
diff_output_path = "results/fusion_output_diff.csv"
summary_md_path = "results/bit_accuracy.md"

# Load data
rtl_data = np.loadtxt(rtl_output_path, delimiter=",", dtype=int)
golden_data = np.loadtxt(golden_output_path, delimiter=",", dtype=int)

# Ensure same length
min_len = min(len(rtl_data), len(golden_data))
rtl_data = rtl_data[:min_len]
golden_data = golden_data[:min_len]

# Bit-accurate comparison
mismatches = []
for i in range(min_len):
    if rtl_data[i] != golden_data[i]:
        mismatches.append((i, golden_data[i], rtl_data[i], golden_data[i] - rtl_data[i]))

# Write diff CSV
with open(diff_output_path, "w", newline='') as f:
    writer = csv.writer(f)
    writer.writerow(["Index", "Golden", "RTL", "Difference"])
    writer.writerows(mismatches)

# Write summary MD
total = min_len
match = total - len(mismatches)
accuracy = (match / total) * 100

with open(summary_md_path, "w") as f:
    f.write("# Bit-Accuracy Validation Summary\n\n")
    f.write(f"- Total samples compared: **{total}**\n")
    f.write(f"- Matching samples: **{match}**\n")
    f.write(f"- Mismatches: **{len(mismatches)}**\n")
    f.write(f"- Accuracy: **{accuracy:.2f}%**\n\n")
    if mismatches:
        f.write("## First 5 Mismatches\n")
        f.write("| Index | Golden | RTL | Difference |\n|-------|--------|-----|------------|\n")
        for m in mismatches[:5]:
            f.write(f"| {m[0]} | {m[1]} | {m[2]} | {m[3]} |\n")

print("✅ Bit-accuracy check complete.")
