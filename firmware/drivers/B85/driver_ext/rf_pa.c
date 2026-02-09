/********************************************************************************************************
 * @file    rf_pa.c
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
#include "tl_common.h" // BLE_SRC_TELINK_MESH_EN
#include "rf_pa.h"
#include "gpio.h"
#include "compiler.h"

// BLE_SRC_TELINK_MESH_EN
#ifndef PA_ENABLE
#define PA_ENABLE                           0
#endif

#ifndef PA_TXEN_PIN
#define PA_TXEN_PIN                         GPIO_PB2
#endif

#ifndef PA_RXEN_PIN
#define PA_RXEN_PIN                         GPIO_PB3
#endif

_attribute_data_retention_	rf_pa_callback_t  blc_rf_pa_cb = 0;

#if(PA_ENABLE)

#define USE_SOFTWARE_PA     0 // BLE_SRC_TELINK_MESH_EN

    #if (0 == USE_SOFTWARE_PA)
STATIC_ASSERT(MCU_CORE_TYPE >= MCU_CORE_8258);
		#if ((MCU_CORE_TYPE == MCU_CORE_8258) || (MCU_CORE_TYPE == MCU_CORE_8278))
// if compile error here, please set USE_SOFTWARE_PA to 1.
STATIC_ASSERT(((u32)PA_RXEN_PIN==(u32)RFFE_RX_PB2)||((u32)PA_RXEN_PIN==(u32)RFFE_RX_PC6)||((u32)PA_RXEN_PIN==(u32)RFFE_RX_PD0));
STATIC_ASSERT(((u32)PA_TXEN_PIN==(u32)RFFE_TX_PB3)||((u32)PA_TXEN_PIN==(u32)RFFE_TX_PC7)||((u32)PA_TXEN_PIN==(u32)RFFE_TX_PD1));
		#endif
	#endif

#if USE_SOFTWARE_PA
_attribute_ram_code_
void app_rf_pa_handler(int type)
{
    u32 r = irq_disable();  // add irq disable should be better due to called in both main loop and irq. // BLE_SRC_TELINK_MESH_EN
	if(type == PA_TYPE_TX_ON){
	    gpio_write(PA_RXEN_PIN, 0);
	    gpio_write(PA_TXEN_PIN, 1);
	}
	else if(type == PA_TYPE_RX_ON){
	    gpio_write(PA_TXEN_PIN, 0);
	    gpio_write(PA_RXEN_PIN, 1);
	}
	else{
	    gpio_write(PA_RXEN_PIN, 0);
	    gpio_write(PA_TXEN_PIN, 0);
	}
    irq_restore(r); // BLE_SRC_TELINK_MESH_EN
}
#endif

/**
 * @brief	RF software PA initialization
 * @param	none
 * @return	none
 */
void rf_pa_init(void)
{
    //rf_set_power_level_index (RF_POWER_0dBm);
    gpio_set_func(PA_TXEN_PIN, AS_GPIO);
    gpio_set_output_en(PA_TXEN_PIN, 1);
    gpio_write(PA_TXEN_PIN, 0);

    gpio_set_func(PA_RXEN_PIN, AS_GPIO);
    gpio_set_output_en(PA_RXEN_PIN, 1);
    gpio_write(PA_RXEN_PIN, 0);

    blc_rf_pa_cb = app_rf_pa_handler;
}
#endif
