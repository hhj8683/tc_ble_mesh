/********************************************************************************************************
 * @file    ext_misc.h
 *
 * @brief   This is the header file for B85
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
#ifndef DRIVERS_8258_EXT_MISC_H_
#define DRIVERS_8258_EXT_MISC_H_






/******************************* rf start **********************************************************************/
/**
 * @brief     This function serves to set BLE mode of RF.
 * @return	  none.
 */
void rf_drv_ble_init();

void rf_2_4g_state_reset(void);

#define		RF_POWER_P3dBm					RF_POWER_P3p01dBm
#define		RF_POWER_P0dBm					RF_POWER_P0p04dBm
/******************************* rf end  **********************************************************************/



/******************************* watchdog_start ***********************************************************************/

#define WATCHDOG_TIMEOUT_COEFF	18		//  check register definition, 0x622

#define WATCHDOG_DISABLE	( reg_tmr_ctrl &= ~FLD_TMR_WD_EN )

/******************************** watchdog_end  **********************************************************************/



/******************************* stimer_start ******************************************************************/

/**
 * @brief   system Timer : 16Mhz, Constant
 */
enum{
	SYSTEM_TIMER_TICK_1US 		= 16,
	SYSTEM_TIMER_TICK_1MS 		= 16000,
	SYSTEM_TIMER_TICK_1S 		= 16000000,

	SYSTEM_TIMER_TICK_625US  	= 10000,  //625*16
	SYSTEM_TIMER_TICK_1250US 	= 20000,  //1250*16
};

/******************************* stimer_end ********************************************************************/




/******************************* ext_clock begin ******************************************************************/

/**
 * @brief     This function is used to check if system clock is 16m
 * @param[in] none
 * @return	  1: system clock is 16m
 *            0: system clock is not 16m
 */
static inline unsigned char clock_is_system_clock_16m(void)
{
	extern unsigned char system_clk_type;
	return (system_clk_type == SYS_CLK_16M_Crystal);
}

/******************************* ext_clock end ********************************************************************/



/******************************* dma_start ******************************************************************/

/**
 * @brief	ACL RX Data buffer length = maxRxOct + 21, then 16 Byte align
 *			maxRxOct + 21 = 4(DMA_len) + 2(BLE header) + maxRxOct + 4(MIC) + 3(CRC) + 8(ExtraInfo)
			RX buffer size must be be 16*n, due to MCU design
 */
//actually +21.The purpose of +22 is to deal with extreme situations. Due to DMA design,at least one byte buffer can not be unusable.

#define		TLK_RF_RX_EXT_LEN		(22)	//4(DMA_len) + 2(BLE header) + ISORxOct + 4(MIC) + 3(CRC) + 8(ExtraInfo)
#define 	CAL_LL_ACL_RX_BUF_SIZE(maxRxOct)	(((maxRxOct + TLK_RF_RX_EXT_LEN) + 15) / 16 *16)


/**
 * @brief	ACL TX Data buffer length = maxTxOct + 10, then 4 Byte align
 *			maxTxOct + 10 = 4(DMA_len) + 2(BLE header) + maxTxOct + 4(MIC)
			TX buffer size must be be 4*n, due to MCU design
 */

#define     TLK_RF_TX_EXT_LEN		(10)	//10 = 4(DMA_len) + 2(BLE header) + 4(MIC)
#define 	CAL_LL_ACL_TX_BUF_SIZE(maxTxOct)	(((maxTxOct + TLK_RF_TX_EXT_LEN) + 3) / 4 *4)

/******************************* dma_end ******************************************************************/


/******************************* compatible for BLE_SRC_TELINK_MESH_EN ******************************************************************/

#define GET_PWMID(gpio, func)     ((gpio==GPIO_PA0) ? 0 : (  \
                     (gpio==GPIO_PA2) ? 0 : (  \
                     (gpio==GPIO_PA3) ? 1 : (  \
                     (gpio==GPIO_PA4) ? 2 : (  \
                     (gpio==GPIO_PB0) ? 3 : (  \
                     (gpio==GPIO_PB1) ? 4 : (  \
                     (gpio==GPIO_PB2) ? 5 : (  \
                     (gpio==GPIO_PB3) ? 0 : (  \
                     (gpio==GPIO_PB4) ? 4 : (  \
                     (gpio==GPIO_PB5) ? 5 : (  \
                     (gpio==GPIO_PC0) ? 4 : (  \
                     (gpio==GPIO_PC1) ? ((func==AS_PWM_SECOND) ? 1 : 0) : (  \
                     (gpio==GPIO_PC2) ? 0 : (  \
                     (gpio==GPIO_PC3) ? 1 : (  \
                     (gpio==GPIO_PC4) ? ((func==AS_PWM_SECOND) ? 0 : 2) : (  \
                     (gpio==GPIO_PC5) ? 3 : (  \
                     (gpio==GPIO_PC6) ? 4 : (  \
                     (gpio==GPIO_PC7) ? 5 : (  \
                     (gpio==GPIO_PD2) ? 3 : (  \
                     (gpio==GPIO_PD3) ? 1 : (  \
                     (gpio==GPIO_PD4) ? 2 : (  \
                     (gpio==GPIO_PD5) ? 0 : 0  \
                    ))))))))))))))))))))))

#define GET_PWM_INVERT_VAL(gpio, func)     ((gpio==GPIO_PA0) ||    \
                     (gpio==GPIO_PB3) ||        \
                     (gpio==GPIO_PC0) ||        \
                     (((gpio==GPIO_PC1) && (func==AS_PWM_SECOND))) ||        \
                     (((gpio==GPIO_PC4) && (func==AS_PWM_SECOND))) ||        \
                     (gpio==GPIO_PC5) ||        \
                     (gpio==GPIO_PC6) ||        \
                     (gpio==GPIO_PC7) ||        \
                     (gpio==GPIO_PD3) ||        \
                     (gpio==GPIO_PD4) ||        \
                     ((gpio==GPIO_PD5) && (func==AS_PWM_SECOND)))

#define pwm_set(a, b, c)	(pwm_set_cycle_and_duty(a, b, c))

typedef struct{
	unsigned int len;
	unsigned char data[1];
}uart_data_t;

static inline void dma_channel_enable_all(){
	reg_dma_chn_en = 0xff;
}

static inline void dma_channel_disable_all(){
	reg_dma_chn_en = 0;
}

void sys_clock_init(SYS_CLK_TypeDef SYS_CLK);

/**
 * @brief This function serves to adc module setting init.
 * @param[in]  none.
 * @return none.
 */
void adc_drv_init(void);
unsigned char uart_ErrorCLR(void);
unsigned char uart_Send(unsigned char* data, unsigned int len);

void gpio_set_interrupt_init(u32 pin, u32 up_down, u32 falling, u32 irq_mask);

#endif
