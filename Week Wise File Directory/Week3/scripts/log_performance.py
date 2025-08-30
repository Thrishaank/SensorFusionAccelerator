import csv

input_file = 'results/uart_output_log.csv'
output_file = 'results/performance_metrics.csv'

with open(input_file, 'r') as infile, open(output_file, 'w', newline='') as outfile:
    reader = csv.reader(infile)
    writer = csv.writer(outfile)
    writer.writerow(["Timestamp", "Latency (us)", "Throughput (samples/sec)"])

    for row in reader:
        if row[0] == "Timestamp": continue
        ts, line = row
        if "Latency" in line:
            latency_us = int(line.split(":")[1].strip().split()[0])
            throughput = 1e6 / latency_us if latency_us else 0
            writer.writerow([ts, latency_us, throughput])
