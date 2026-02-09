/********************************************************************************************************
 * @file    ext_misc.c
 *
 * @brief   This is the source file for B85
 *
 * @author  Driver Group
 * @date    May 8,2018
 *
 * @par     Copyright (c) 2018, Telink Semiconductor (Shanghai) Co., Ltd. ("TELINK")
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
#include "drivers/TC321X/driver.h"
#include "ext_misc.h"
/*********************************************************** STIMER START********************************************/
_attribute_ram_code_ void systimer_set_irq_capture(unsigned int sys_timer_tick)//8278 for save time,need to place in ram.
{
	if( (unsigned int)( sys_timer_tick  - (reg_system_tick + 7*sys_tick_per_us )) > BIT(30) )//63us - 75us in flash / 3.5us in ram
	{
		reg_system_tick_irq = reg_system_tick + 12*sys_tick_per_us; ///320 = 0x140, so not &0xfffffff8
	}
	else{
		reg_system_tick_irq = sys_timer_tick & 0xfffffff8;
	}
}
/*********************************************************** STIMER END********************************************/

/******************************* compatible for BLE_SRC_TELINK_MESH_EN ******************************************************************/
#include "stack/ble/ble.h"

/**
 * @brief This function serves to adc module setting init.
 * @param[in]  none.
 * @return none.
 */
#if ADC_ENABLE
void adc_drv_init(void)
{	// take about 750us in 16MHz clock.
	adc_init();
	#if(ADC_MODE==ADC_BASE_MODE)
	adc_base_init(ADC_CHNM_ANA_INPUT);	
	#elif (ADC_MODE==ADC_VBAT_MODE)
	adc_vbat_init(ADC_CHNM_ANA_INPUT);
	#endif
	adc_set_ain_pre_scaler(ADC_PRESCALER);//ADC pre_scaling default value is ADC_PRESCALER_1F8, it can change after adc_base_init().
	adc_power_on_sar_adc(1);		//After setting the ADC parameters, turn on the ADC power supply control bit
#if (BATT_CHECK_ENABLE)
	adc_hw_initialized = 0;	// inform battery check to re-init.
#endif
}
#endif

//---------------uart
#if (HCI_ACCESS==HCI_USE_UART)
extern u8 uart_hw_tx_buf[];
extern my_fifo_t hci_rx_fifo;
static unsigned char *tx_buff = NULL;
volatile unsigned char uart0_tx_done_flag = 1;

void uart_drv_init(void)
{
    //note: dma addr must be set first before any other uart initialization! (confirmed by sihui)
	u8 *uart_rx_addr = hci_rx_fifo.p + (hci_rx_fifo.wptr & (hci_rx_fifo.num-1)) * hci_rx_fifo.size;
	uart_recbuff_init(UART0, uart_rx_addr, hci_rx_fifo.size);
	uart_gpio_set(UART0, UART_TX_PIN, UART_RX_PIN);

	uart_reset(UART0);  //will reset uart digital registers from 0x90 ~ 0x9f, so uart setting must set after this reset

	//baud rate: 115200
    uart_init_baudrate(UART0, 115200, CLOCK_SYS_CLOCK_HZ, PARITY_NONE, STOP_BIT_ONE);

	uart_dma_enable(UART0, 1, 1); 	//uart data in hardware buffer moved by dma, so we need enable them first

	irq_set_mask(FLD_IRQ_DMA_EN);
	dma_chn_irq_enable(FLD_DMA_CHN_UART_RX | FLD_DMA_CHN_UART_TX, 1);   	//uart Rx/Tx dma irq enable
    uart_mask_tx_done_irq_enable(UART0);

    tx_buff = uart_hw_tx_buf;
}

unsigned char uart_Send(unsigned char* data, unsigned int len)
{
    extern const u16 UART_TX_LEN_MAX;
    if(len > UART_TX_LEN_MAX){
        return 1;	// skip valid length data, avoid dead loop
    }

	if(tx_buff && uart0_tx_done_flag){
		memcpy(tx_buff, &len, 4);
	    memcpy(tx_buff + 4, data, len);
        uart_send_dma(UART0, tx_buff);
        uart0_tx_done_flag = 0;

		return 1;
	}
	return 0;

}

/**********************************************************
*	
*	@brief	clear error state of uart rx, maybe used when application detected UART not work
*
*   @param[in] none
*
*	@return	'1' RX error flag rose and cleard success; '0' RX error flag not rose 
*
*/
unsigned char uart_ErrorCLR(void)
{
	if(uart_is_parity_error(UART0)){
		uart_clear_parity_error(UART0);
		return 1;
	}

    if(uart_is_parity_error(UART1)){
		uart_clear_parity_error(UART1);
		return 1;
	}

    if(uart_is_parity_error(UART2)){
		uart_clear_parity_error(UART2);
		return 1;
	}
    
	return 0;
}
#endif

/**
 * @brief       This function server to init gpio interrupt
 * @param[io]   pin		- interrupt pin
 * @param[io]   up_down	- pin pull up/down
 * @param[io]   falling	- 0: falling edge trigger
 *                        1: rising edge trigger
 * @param[io]   irq_mask- interrupt mask to use
 * @return      none
 * @note        
 */
void gpio_set_interrupt_init(u32 pin, u32 up_down, u32 falling, u32 irq_mask)
{
	if(irq_mask&(~(FLD_IRQ_GPIO_RISC0_EN | FLD_IRQ_GPIO_RISC1_EN | FLD_IRQ_GPIO_RISC2_EN | FLD_IRQ_GPIO_RISC3_EN))){
		return;
	}

    /***step1. set pin as gpio and enable input********/
	gpio_set_func(pin, AS_GPIO);           //enable GPIO func
	gpio_set_input_en(pin, 1);             //enable input
	gpio_set_output_en(pin, 0);            //disable output
	
	/***step2. set open pullup ***/
	gpio_setup_up_down_resistor(pin, up_down);  //open pull up resistor
	
	/***step3.      set irq enable  ***/
	if(FLD_IRQ_GPIO_RISC0_EN == irq_mask){
		gpio_set_interrupt_risc0(pin, falling);
	}
	else if(FLD_IRQ_GPIO_RISC1_EN == irq_mask){
		gpio_set_interrupt_risc1(pin, falling);
	}
    else if(FLD_IRQ_GPIO_RISC2_EN == irq_mask){
		gpio_set_interrupt_risc2(pin, falling);
	}
    else if(FLD_IRQ_GPIO_RISC3_EN == irq_mask){
		gpio_set_interrupt_risc3(pin, falling);
	}
}

