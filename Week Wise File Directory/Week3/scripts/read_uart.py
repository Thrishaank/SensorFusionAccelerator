import serial
import serial.tools.list_ports
import csv
import time

def find_uart_port():
    ports = serial.tools.list_ports.comports()
    for port in ports:
        if "USB" in port.description or "UART" in port.description or "CP210" in port.description:
            return port.device
    return None

def main():
    uart_port = find_uart_port()
    if not uart_port:
        print("❌ UART port not found. Is the ZedBoard connected via USB?")
        return

    print(f"✅ Using UART port: {uart_port}")

    try:
        ser = serial.Serial(uart_port, 115200, timeout=1)
        ser.flush()

        with open("results/uart_output_log.csv", "w", newline='') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(["Timestamp", "Fusion Output"])

            print("📡 Listening on UART... Press Ctrl+C to stop.")
            while True:
                if ser.in_waiting > 0:
                    line = ser.readline().decode('utf-8', errors='ignore').strip()
                    timestamp = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
                    writer.writerow([timestamp, line])
                    print(f"[{timestamp}] {line}")

    except serial.SerialException as e:
        print(f"⚠️  Serial Error: {e}")
    except KeyboardInterrupt:
        print("\n🛑 Stopped by user.")
    finally:
        if 'ser' in locals() and ser.is_open:
            ser.close()

if __name__ == "__main__":
    main()
