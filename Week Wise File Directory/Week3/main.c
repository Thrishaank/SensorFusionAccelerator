#include "xparameters.h"
#include <stdio.h>
#include <stdint.h>

// Base address of AXI IP (check in Vivado Address Editor!)
#define FUSION_BASE     0x43C00000

#define REG_CTRL        (*(volatile uint32_t*)(FUSION_BASE + 0x00))
#define REG_STATUS      (*(volatile uint32_t*)(FUSION_BASE + 0x04))
#define REG_IMU_IN      (*(volatile uint32_t*)(FUSION_BASE + 0x10))
#define REG_LIDAR_IN    (*(volatile uint32_t*)(FUSION_BASE + 0x14))
#define REG_FUSED_OUT   (*(volatile uint32_t*)(FUSION_BASE + 0x18))
#define REG_VALID_IN    (*(volatile uint32_t*)(FUSION_BASE + 0x1C))
#define REG_VALID_OUT   (*(volatile uint32_t*)(FUSION_BASE + 0x20))

void fusion_send_data(uint16_t imu_data, uint16_t lidar_data) {
    REG_IMU_IN = imu_data;
    REG_LIDAR_IN = lidar_data;
    REG_VALID_IN = 0x3; // Both IMU and LiDAR valid
    REG_CTRL = 0x1;     // Start operation
}

int main() {
    uint16_t imu_sample = 0x1234;
    uint16_t lidar_sample = 0x5678;

    fusion_send_data(imu_sample, lidar_sample);

    // Wait until processing is done
    while ((REG_STATUS & 0x1) == 0);

    uint16_t fused = REG_FUSED_OUT;
    uint8_t valid = REG_VALID_OUT;

    printf("Fused Pos = 0x%04X, Valid = %d\n", fused, valid);

    return 0;
}
