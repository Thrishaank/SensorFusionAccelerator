import csv
import random
import time

# Output file for logging latency
latency_log = "results/axi_latency_trace.csv"

# Configuration
BURST_LENGTH = 16      # Number of words per burst
NUM_BURSTS = 20        # Total number of bursts to send
AXI_WRITE_ADDR = 0x80000000

# Simulate FIFO/AXI write
def mock_axi_write(address, data_words):
    # Simulate hardware delay
    simulated_latency = random.uniform(0.2, 1.0)  # ms
    time.sleep(simulated_latency / 1000)  # Convert to seconds
    return simulated_latency

# Main test logic
def perform_axi_burst_test():
    with open(latency_log, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["Burst_ID", "Start_Addr", "Latency_ms"])

        for i in range(NUM_BURSTS):
            burst_data = [random.randint(0, 65535) for _ in range(BURST_LENGTH)]
            latency = mock_axi_write(AXI_WRITE_ADDR + i * BURST_LENGTH * 4, burst_data)
            writer.writerow([i, hex(AXI_WRITE_ADDR + i * BURST_LENGTH * 4), f"{latency:.3f}"])
            print(f"[✓] Burst {i} completed in {latency:.3f} ms")

    print(f"\n[✓] AXI Burst Stress Test Log written to: {latency_log}")

if __name__ == "__main__":
    perform_axi_burst_test()
