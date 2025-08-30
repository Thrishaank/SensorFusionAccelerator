import csv
import os
from datetime import datetime

# Output directories
output_dir = "results"
os.makedirs(output_dir, exist_ok=True)

axi_log_path = os.path.join(output_dir, "system_test_log.md")
axi_csv_path = os.path.join(output_dir, "axi_sequence_log.csv")

# Test data generation (simulate AXI master writing to fusion input registers)
test_data = [
    {"time": 0, "address": "0x00", "value": 1000, "type": "WRITE", "desc": "Write AX = 1000"},
    {"time": 1, "address": "0x04", "value": 500,  "type": "WRITE", "desc": "Write AZ = 500"},
    {"time": 2, "address": "0x08", "value": 1,    "type": "WRITE", "desc": "Trigger VALID"},
    {"time": 3, "address": "0x0C", "value": None, "type": "READ",  "desc": "Read fusion result"},
    {"time": 4, "address": "0x10", "value": None, "type": "READ",  "desc": "Check fusion VALID"}
]

# Simulate results (this would ideally come from your simulation output or waveform analysis)
simulated_results = {
    "0x0C": 1234,  # Fusion result (AX + AZ for example)
    "0x10": 1      # Valid bit
}

# Generate CSV log
with open(axi_csv_path, "w", newline="") as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(["Cycle", "Type", "Address", "Value", "Result", "Description"])
    for entry in test_data:
        addr = entry["address"]
        val = entry["value"]
        typ = entry["type"]
        res = simulated_results.get(addr, "-") if typ == "READ" else "-"
        writer.writerow([entry["time"], typ, addr, val if val is not None else "-", res, entry["desc"]])

# Generate Markdown log
with open(axi_log_path, "w") as f:
    f.write(f"# System Test Log — AXI Sequence\n")
    f.write(f"Generated: {datetime.now().isoformat()}\n\n")
    f.write("| Cycle | Type  | Address | Value | Result | Description |\n")
    f.write("|-------|-------|---------|-------|--------|-------------|\n")
    for entry in test_data:
        addr = entry["address"]
        val = entry["value"]
        typ = entry["type"]
        res = simulated_results.get(addr, "-") if typ == "READ" else "-"
        f.write(f"| {entry['time']} | {typ} | {addr} | {val if val is not None else '-'} | {res} | {entry['desc']} |\n")

print(f"✅ AXI test sequence logs written to:\n→ {axi_csv_path}\n→ {axi_log_path}")
