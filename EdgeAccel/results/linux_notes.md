# Linux Setup Notes — ZedBoard

## PetaLinux Environment
- Tool: PetaLinux 2022.2
- Board: Zynq ZedBoard (xc7z020clg484-1)
- Boot medium: SD Card

## AXI Peripheral Integration
- Custom IP: fusion_top
- Address mapped via Vivado Address Editor

## UART Settings
- Baud Rate: 115200
- Port: /dev/ttyPS0 (or external USB-UART)

## Deployment
1. Copy `BOOT.BIN`, `image.ub`, `rootfs.cpio` to SD card
2. Insert into ZedBoard and power on
3. Connect USB-UART and open terminal
4. Run:
   ```bash
   cat /dev/ttyPS0 > uart_log.txt
