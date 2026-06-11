/********************************************************************************************************
 * @file	main.c
 *
 * @brief	主程序入口文件 - Mesh Provisioner(配网器)设备的主函数实现
 *
 * @author	telink
 * @date	Sep. 30, 2010
 *
 * @par     Copyright (c) 2017, Telink Semiconductor (Shanghai) Co., Ltd. ("TELINK")
 *          All rights reserved.
 *
 *          Licensed under the Apache License, Version 2.0 (the "License");
 *          you may not use this file except in compliance with the License.
 *          You may obtain a copy of the License at
 *
 *              http://www.apache.org/licenses/LICENSE-2.0
 *
 *          Unless required by applicable law or agreed to in writing, software
 *          distributed under the License is distributed on an "AS IS" BASIS,
 *          WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *          See the License for the specific language governing permissions and
 *          limitations under the License.
 *
 *******************************************************************************************************/
#include "tl_common.h"
#include "stack/ble/ble.h"
#include "drivers.h"
#include "vendor/common/mesh_common.h"

// 声明用户初始化函数，在 app.c 中实现
extern void user_init();
// 声明主循环函数，在 app.c 中实现
extern void main_loop ();

// 当使用 UART 作为 HCI 接口时的相关处理
#if (HCI_ACCESS==HCI_USE_UART)
extern my_fifo_t hci_rx_fifo;

u16 uart_tx_irq=0, uart_rx_irq=0;

/**
 * @brief   UART 中断处理函数（运行在 RAM 代码区）
 * @details 处理 UART 接收和发送完成的中断事件
 *          - 接收中断：将接收到的数据存入 HCI RX FIFO 缓冲区
 *          - 发送中断：计数发送完成次数
 */
_attribute_ram_code_ void irq_uart_handle()
{
	unsigned char irqS = reg_dma_rx_rdy0;
	if(irqS & FLD_DMA_CHN_UART_RX)	//rx 接收中断
	{
		uart_rx_irq++;  // 接收中断计数加1
		reg_dma_rx_rdy0 = FLD_DMA_CHN_UART_RX;  // 清除接收中断标志
		// 获取当前写指针位置的缓冲区地址
		u8* w = hci_rx_fifo.p + (hci_rx_fifo.wptr & (hci_rx_fifo.num-1)) * hci_rx_fifo.size;
		if(w[0]!=0)  // 如果接收到有效数据
		{
			my_fifo_next(&hci_rx_fifo);  // 移动写指针到下一个缓冲区
			u8* p = hci_rx_fifo.p + (hci_rx_fifo.wptr & (hci_rx_fifo.num-1)) * hci_rx_fifo.size;
			reg_dma0_addr = (u16)((u32)p);  // 更新 DMA 地址到新的缓冲区
		}
	}

	if(irqS & FLD_DMA_CHN_UART_TX)	//tx 发送中断
	{
		uart_tx_irq++;  // 发送中断计数加1
		reg_dma_rx_rdy0 = FLD_DMA_CHN_UART_TX;  // 清除发送中断标志
	}

    #if(MCU_CORE_TYPE == MCU_CORE_TC321X)
	// TC321x 芯片特殊处理：UART 发送完成标志
	if(reg_uart_status1(UART0) & FLD_UART_TX_DONE)
	{
		uart0_tx_done_flag = 1;  // 设置发送完成标志
		uart_clr_tx_done(UART0);  // 清除发送完成标志
	}
    #endif
}
#endif

/**
 * @brief   系统总中断处理函数（运行在 RAM 代码区）
 * @details 统一处理所有中断事件：
 *          1. BLE 协议栈中断处理
 *          2. UART 中断处理（如果启用）
 */
_attribute_ram_code_ void irq_handler(void)
{
	irq_blt_sdk_handler ();  // BLE 协议栈中断处理

#if (HCI_ACCESS==HCI_USE_UART)
	irq_uart_handle();  // UART 中断处理
#endif
}

// 定义 Flash 地址相关的变量
FLASH_ADDRESS_DEFINE;

/**
 * @brief   主函数 - 程序入口点
 * @details 系统上电或复位后首先执行的函数
 *          主要流程：
 *          1. 配置 OTA 固件大小和启动地址
 *          2. 选择电源管理方案（内部 32k 晶振）
 *          3. CPU 唤醒初始化
 *          4. 判断是否从深度睡眠唤醒
 *          5. RF 驱动初始化
 *          6. GPIO 初始化（非深度睡眠唤醒时）
 *          7. 时钟初始化
 *          8. 用户初始化（区分深度睡眠唤醒和普通启动）
 *          9. 使能全局中断
 *          10. 进入主循环
 * @note    如果启用深度睡眠保持功能，此函数必须运行在 RAM 中
 */
#if (PM_DEEPSLEEP_RETENTION_ENABLE)
_attribute_ram_code_
#endif
int main (void) // must run in ramcode if enable retention sleep - 如果启用深度睡眠保持功能，必须运行在 RAM 中
{
    // 步骤 1: 配置 OTA(空中升级)固件大小和启动地址
    // FW_SIZE_MAX_K: 最大固件大小 (单位 KB)
    // FLASH_ADR_UPDATE_NEW_FW: 新固件在 Flash 中的存储地址
    blc_ota_setFirmwareSizeAndBootAddress(FW_SIZE_MAX_K, FLASH_ADR_UPDATE_NEW_FW);
    
    // 步骤 2: 选择电源管理方案 - 使用内部 32k 晶振作为低功耗时钟源
    // 适用于需要低功耗睡眠的应用场景
    blc_pm_select_internal_32k_crystal();

    // 步骤 3: CPU 唤醒初始化
    // 根据不同芯片型号调用不同的初始化函数
#if(MCU_CORE_TYPE == MCU_CORE_825x)
    // TLSR825x 系列芯片：简单唤醒初始化
    cpu_wakeup_init();
#else
    // 其他芯片 (如 TLSR827x/TC321x): 指定 LDO 模式和外部 24M 晶振
    cpu_wakeup_init(LDO_MODE, INTERNAL_CAP_XTAL24M);
#endif

    // 步骤 4: 检查是否从深度睡眠保持模式唤醒
    // 如果是深度睡眠唤醒，可以跳过部分初始化以加快唤醒速度
    int deepRetWakeUp = pm_is_MCU_deepRetentionWakeup();  // MCU 深度保持唤醒标志

    // 步骤 5: RF 射频驱动初始化
    // 初始化蓝牙射频模块，必须在 GPIO 和时钟初始化之前调用
    rf_drv_ble_init();

    // 步骤 6: GPIO 初始化
    // 如果不是从深度睡眠唤醒，则需要重新初始化 GPIO
    // 深度睡眠模式下，模拟寄存器会保持状态，无需重复初始化
    gpio_init(!deepRetWakeUp );

    // 步骤 7: 系统时钟初始化
    // 使用预定义的系统时钟类型 (SYS_CLK_TYPE)
    clock_init(SYS_CLK_TYPE);

    // 步骤 8: 用户应用初始化
#if	(PM_DEEPSLEEP_RETENTION_ENABLE)
    if(deepRetWakeUp){
        // 如果是深度保持唤醒，调用快速恢复初始化
        // 只恢复必要的状态，跳过耗时的初始化过程
        user_init_deepRetn();
    }
    else
#endif
    {
        // 正常启动或普通唤醒，执行完整的用户初始化
        // 包括 BLE 协议栈初始化、Mesh 配置、GPIO 设置等
        user_init();
    }

    // 步骤 9: 使能全局中断
    // 允许响应所有已配置的中断事件
    irq_enable();

    // 步骤 10: 主循环
    // 持续执行应用程序逻辑，直到设备断电或复位
    while (1) {
#if (MODULE_WATCHDOG_ENABLE)
        // 如果启用了看门狗，需要定期喂狗防止系统复位
        wd_clear(); // clear watch dog - 清除看门狗计数器
#endif
        // 执行主循环任务
        // 包括：BLE 事件处理、Mesh 消息处理、UI 更新等
        main_loop();
    }
}

