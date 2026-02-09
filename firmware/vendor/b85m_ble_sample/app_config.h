/********************************************************************************************************
 * @file    app_config.h
 *
 * @brief   This is the header file for BLE SDK
 *
 * @author  BLE GROUP
 * @date    06,2020
 *
 * @par     Copyright (c) 2020, Telink Semiconductor (Shanghai) Co., Ltd. ("TELINK")
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
#pragma once

#include "vendor/common/version.h"    // include mesh_config.h inside.

///////////////////////// Feature Configuration////////////////////////////////////////////////
#define BLE_APP_PM_ENABLE								1
#define PM_DEEPSLEEP_RETENTION_ENABLE					1
#define TEST_CONN_CURRENT_ENABLE            			0 	//test connection current, disable UI to have a pure power
#define BLE_APP_SECURITY_ENABLE      					1	//ACL Slave device SMP, strongly recommended enabled
#define BLE_REMOTE_SECURITY_ENABLE                      BLE_APP_SECURITY_ENABLE
#define BLE_OTA_SERVER_ENABLE							0

/////////////////////// DLE mode Configuration ///////////////////////////////
#if EXTENDED_ADV_ENABLE
#define MESH_DLE_MODE               MESH_DLE_MODE_EXTEND_BEAR
#define DLE_LEN_MAX_RX              (MAX_OCTETS_DATA_LEN_EXTENSION) // must MAX_OCTETS_DATA_LEN_EXTENSION
#define DLE_LEN_MAX_TX              (40)
#else
#define MESH_DLE_MODE               MESH_DLE_MODE_GATT
#define DLE_LEN_MAX_RX              (56)
#define DLE_LEN_MAX_TX              (40)
#endif

/* Flash Protection:
 * 1. Flash protection is enabled by default in SDK. User must enable this function on their final mass production application.
 * 2. User should use "Unlock" command in Telink BDT tool for Flash access during development and debugging phase.
 * 3. Flash protection demonstration in SDK is a reference design based on sample code. Considering that user's final application may
 *    different from sample code, for example, user's final firmware size is bigger, or user have a different OTA design, or user need
 *    store more data in some other area of Flash, all these differences imply that Flash protection reference design in SDK can not
 *    be directly used on user's mass production application without any change. User should refer to sample code, understand the
 *    principles and methods, then change and implement a more appropriate mechanism according to their application if needed.
 */
#define APP_FLASH_PROTECTION_ENABLE						0

/* User must check battery voltage on mass production application to prevent abnormal writing or erasing Flash at a low voltage !!! */
#define APP_BATT_CHECK_ENABLE							0
#if (APP_BATT_CHECK_ENABLE)
//telink device: you must choose one gpio with adc function to output high level(voltage will equal to vbat), then use adc to measure high level voltage
    #if(MCU_CORE_TYPE == MCU_CORE_TC321X)
    //use PB1 output high level, then adc measure this high level voltage
	#define GPIO_VBAT_DETECT				SD_ADC_GPIO_PB5P // corresponding sd_adc_p_input_pin_def_e
    #else
    //use PC5 output high level, then adc measure this high level voltage
	#define GPIO_VBAT_DETECT				GPIO_PC5
	#define PC5_FUNC						AS_GPIO
	#define PC5_INPUT_ENABLE				0
	#define ADC_INPUT_PCHN					C5P    //corresponding  ADC_InputPchTypeDef in adc.h
    #endif
#endif

///////////////////////// DEBUG  Configuration ////////////////////////////////////////////////
#define DEBUG_GPIO_ENABLE					0
#ifndef HCI_LOG_FW_EN
#define HCI_LOG_FW_EN                       (0 || DEBUG_LOG_SETTING_DEVELOP_MODE_EN) // enable simulated uart log
#define UART_PRINT_DEBUG_ENABLE				HCI_LOG_FW_EN
#endif
#define APP_LOG_EN							1
#define APP_SMP_LOG_EN						0
#define APP_KEY_LOG_EN						1
#define APP_CONTR_EVENT_LOG_EN				1  //controller event log
#define APP_HOST_EVENT_LOG_EN				1  //host event log
#define APP_OTA_LOG_EN						1
#define APP_FLASH_INIT_LOG_EN				1
#define APP_FLASH_PROT_LOG_EN				1
#define APP_BATT_CHECK_LOG_EN				1

/////////////////////// Sample Board Select Configuration ///////////////////////////////
#define BOARD_825X_C1T139A3_V2_0			1 // 8258 dongle board
#define BOARD_827X_C1T201A3_V1_0			2 // 8278 dongle board
#define BOARD_TC321X_EVK_C1T357A20			3

#if (MCU_CORE_TYPE == MCU_CORE_825x)
	#define BOARD_SELECT					BOARD_825X_C1T139A3_V2_0
#elif (MCU_CORE_TYPE == MCU_CORE_827x)
	#define BOARD_SELECT					BOARD_827X_C1T201A3_V1_0
#elif (MCU_CORE_TYPE == MCU_CORE_TC321X)
	#define BOARD_SELECT					BOARD_TC321X_EVK_C1T357A20
#endif


/////////////////////HCI ACCESS OPTIONS///////////////////////////////////////
#define HCI_USE_NONE	0
#define HCI_USE_UART	1
#define HCI_USE_USB		2

#ifndef HCI_ACCESS
#if (WIN32 || PTS_TEST_EN || TESTCASE_FLAG_ENABLE)
#define HCI_ACCESS		HCI_USE_USB
#elif MESH_MONITOR_EN
#define HCI_ACCESS		HCI_USE_UART
#else
	#if GATT_RP_EN
#define HCI_ACCESS		HCI_USE_UART
	#else
#define HCI_ACCESS		HCI_USE_NONE
	#endif
#endif 

#if (HCI_ACCESS==HCI_USE_UART)
#define UART_TX_PIN		UART_TX_PD7
#define UART_RX_PIN		UART_RX_PA0
#endif
#endif

///////////////////////// UI Configuration ////////////////////////////////////////////////////
#ifndef UI_KEYBOARD_ENABLE
#define UI_KEYBOARD_ENABLE				0
#endif

#if UI_KEYBOARD_ENABLE
#define	MATRIX_ROW_PULL					PM_PIN_PULLDOWN_100K // drive pin pull
#define	MATRIX_COL_PULL					PM_PIN_PULLUP_10K    // scan pin pull
    
#define	KB_LINE_HIGH_VALID				0   // dirve pin output 0 when keyscan(no drive pin in KB_LINE_MODE=1), scanpin read 0 is valid
#define DEEPBACK_FAST_KEYSCAN_ENABLE	1   //proc fast scan when deepsleep back triggered by key press, in case key loss
#define KEYSCAN_IRQ_TRIGGER_MODE		0
#define LONG_PRESS_KEY_POWER_OPTIMIZE	1   //lower power when pressing key without release
    
#define	KB_MAP_NUM				KB_MAP_NORMAL
#define	KB_MAP_FN				KB_MAP_NORMAL
    
#if 1 //(PCBA_8258_SEL == PCBA_8258_DONGLE_48PIN)
    // key mode, KB_LINE_MODE default 0(key matrix), set to 1 in button mode.
#define KB_LINE_MODE			1 			
    
    // keymap
#define KEY_SW1		1
#define KEY_SW2		2
#define KB_MAP_NORMAL			{{KEY_SW1},	{KEY_SW2}}
    
#define KB_DRIVE_PINS			{GPIO_PD6} 	// make no sense, just for compile, not driver pin in KB_LINE_MODE=1.
#define KB_SCAN_PINS			{GPIO_PD6, GPIO_PD5}
    
#define	SW1_GPIO				GPIO_PD6
#define	SW2_GPIO				GPIO_PD5
    
    // scan pin as gpio
#define PD5_FUNC				AS_GPIO
#define PD6_FUNC				AS_GPIO
    
    //scan  pin pullup
#define PULL_WAKEUP_SRC_PD6     PM_PIN_PULLUP_1M	//btn
#define PULL_WAKEUP_SRC_PD5     PM_PIN_PULLUP_1M	//btn
    
    //scan pin open input to read gpio level
#define PD6_INPUT_ENABLE		1
#define PD5_INPUT_ENABLE		1
#endif
#endif

#define PWM_R       GPIO_PA3		//red
#define PWM_G       GPIO_PA2		//green
#define PWM_B       GPIO_PB0		//blue
#define PWM_W       GPIO_PB1		//white

#if(MCU_CORE_TYPE == MCU_CORE_TC321X)
#define PWM_FUNC_R  PWM0
#define PWM_FUNC_G  PWM1
#define PWM_FUNC_B  PWM2
#define PWM_FUNC_W  PWM3

#define PWMID_R     PWM0_ID
#define PWMID_G     PWM1_ID
#define PWMID_B     PWM2_ID
#define PWMID_W     PWM3_ID
                    
#define PWM_INV_R   0
#define PWM_INV_G   0
#define PWM_INV_B   0
#define PWM_INV_W   0
#else
#define PWM_FUNC_R  AS_PWM  // AS_PWM_SECOND
#define PWM_FUNC_G  AS_PWM  // AS_PWM_SECOND
#define PWM_FUNC_B  AS_PWM  // AS_PWM_SECOND
#define PWM_FUNC_W  AS_PWM  // AS_PWM_SECOND

#define PWMID_R     (GET_PWMID(PWM_R, PWM_FUNC_R))
#define PWMID_G     (GET_PWMID(PWM_G, PWM_FUNC_G))
#define PWMID_B     (GET_PWMID(PWM_B, PWM_FUNC_B))
#define PWMID_W     (GET_PWMID(PWM_W, PWM_FUNC_W))
                    
#define PWM_INV_R   (GET_PWM_INVERT_VAL(PWM_R, PWM_FUNC_R))
#define PWM_INV_G   (GET_PWM_INVERT_VAL(PWM_G, PWM_FUNC_G))
#define PWM_INV_B   (GET_PWM_INVERT_VAL(PWM_B, PWM_FUNC_B))
#define PWM_INV_W   (GET_PWM_INVERT_VAL(PWM_W, PWM_FUNC_W))
#endif

#ifndef GPIO_LED
#define GPIO_LED	PWM_R
#endif

#define TRANSITION_TIME_DEFAULT_VAL (0)

/////////////////// DEEP SAVE FLG //////////////////////////////////
#if (MCU_CORE_TYPE == MCU_CORE_TC321X)
	#define USED_DEEP_ANA_REG				PM_ANA_REG_WD_CLR_BUF1
#else
	#define USED_DEEP_ANA_REG               DEEP_ANA_REG0 //u8,can save 8 bit info when deep
#endif
#define	LOW_BATT_FLG					    BIT(0) //if 1: low battery
#define CONN_DEEP_FLG	                    BIT(4) //if 1: conn deep, 0: ADV deep



///////////////////////// System Clock  Configuration /////////////////////////////////////////
#define CLOCK_SYS_CLOCK_HZ  								16000000


/////////////////// watchdog  //////////////////////////////
#define MODULE_WATCHDOG_ENABLE		0
#define WATCHDOG_INIT_TIMEOUT		500  //ms


/////////////////////////////////////// PRINT DEBUG INFO ///////////////////////////////////////
#if (UART_PRINT_DEBUG_ENABLE)
    #define PRINT_DEBUG_INFO                1
	#define DEBUG_INFO_TX_PIN           	GPIO_PB2
	#define PULL_WAKEUP_SRC_PB2         	PM_PIN_PULLUP_10K
	#define PB2_OUTPUT_ENABLE         		1
	#define PB2_DATA_OUT                    1    
#endif

#if TEST_CONN_CURRENT_ENABLE
	#if DEBUG_GPIO_ENABLE || UART_PRINT_DEBUG_ENABLE || UI_KEYBOARD_ENABLE || UI_LED_ENABLE || UI_BUTTON_ENABLE
		#error "If testing current, the above definitions must be disable!!!"
	#endif
#endif


#include "vendor/common/default_config.h"
