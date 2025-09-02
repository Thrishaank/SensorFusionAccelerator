import csv
import random
import time

# Output CSV file
out_csv = "results/mock_uart_log.csv"

# Number of fusion events to simulate
NUM_EVENTS = 20

# Simulate timestamped UART messages
def simulate_uart_output():
    with open(out_csv, mode="w", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(["Timestamp", "AX", "AZ", "Fusion_Result"])

        timestamp = 0
        for _ in range(NUM_EVENTS):
            ax = random.randint(0, 65535)
            az = random.randint(0, 65535)
            fusion = (ax + az) >> 1  # Simple average as mock fusion logic

            writer.writerow([timestamp, ax, az, fusion])
            timestamp += random.randint(1, 5)  # Simulate delay between packets

    print(f"[✓] Mock UART log written to {out_csv}")

if __name__ == "__main__":
    simulate_uart_output()
