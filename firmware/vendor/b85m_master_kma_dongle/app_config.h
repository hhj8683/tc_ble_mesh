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
#include  "application/audio/audio_common.h"



/////////////////// MODULE /////////////////////////////////
#define BLE_HOST_SMP_ENABLE				    1  //Master SMP strongly recommended enabled
#define ACL_CENTRAL_SIMPLE_SDP_ENABLE		1  //simple service discovery


#define BLE_MASTER_OTA_ENABLE			    1  //slave ota test
#define AUDIO_SDM_ENABLE					0  //if using sdm playback, should better disable USB MIC

#define SIG_MESH_GATT_ENABLE                1

/* Flash Protection:
 * 1. Flash protection is enabled by default in SDK. User must enable this function on their final mass production application.
 * 2. User should use "Unlock" command in Telink BDT tool for Flash access during development and debugging phase.
 * 3. Flash protection demonstration in SDK is a reference design based on sample code. Considering that user's final application may
 *    different from sample code, for example, user's final firmware size is bigger, or user have a different OTA design, or user need
 *    store more data in some other area of Flash, all these differences imply that Flash protection reference design in SDK can not
 *    be directly used on user's mass production application without any change. User should refer to sample code, understand the
 *    principles and methods, then change and implement a more appropriate mechanism according to their application if needed.
 */
#define APP_FLASH_PROTECTION_ENABLE			1


///////////////////////// DEBUG  Configuration ////////////////////////////////////////////////
#define DEBUG_GPIO_ENABLE							0
#ifndef HCI_LOG_FW_EN
#define HCI_LOG_FW_EN                       		(0 || DEBUG_LOG_SETTING_DEVELOP_MODE_EN) // enable simulated uart log
#define UART_PRINT_DEBUG_ENABLE						HCI_LOG_FW_EN
#define PRINT_DEBUG_INFO                            HCI_LOG_FW_EN
#endif

#define APP_LOG_EN									1
#define APP_FLASH_INIT_LOG_EN						1

/////////////////////// Master Dongle Board Select Configuration ///////////////////////////////
#define BOARD_825X_C1T139A3_V2_0			1 // 8258 dongle board
#define BOARD_827X_C1T201A3_V1_0			2 // 8278 dongle board

#if (MCU_CORE_TYPE == MCU_CORE_825x)
	#define BOARD_SELECT					BOARD_825X_C1T139A3_V2_0
#elif (MCU_CORE_TYPE == MCU_CORE_827x)
	#define BOARD_SELECT					BOARD_827X_C1T201A3_V1_0
#endif


/////////////////////HCI ACCESS OPTIONS///////////////////////////////////////
#define HCI_USE_NONE	0
#define HCI_USE_UART	1
#define HCI_USE_USB		2

#if GATT_RP_EN
#define HCI_ACCESS		HCI_USE_UART
#else
#define HCI_ACCESS		HCI_USE_USB
#endif


#if (HCI_ACCESS==HCI_USE_UART)
#define UART_TX_PIN		UART_TX_PD7
#define UART_RX_PIN		UART_RX_PA0
#endif

///////////////////////// UI Configuration ////////////////////////////////////////////////////
#define UI_BUTTON_ENABLE							1
#define UI_LED_ENABLE								1
#define UI_AUDIO_ENABLE								1

#if (UI_BUTTON_ENABLE)
	/* 825X Dongle and 827X Dongle use same GPIO for Button: PD5/PD6 */
	#define	SW1_GPIO				GPIO_PD5
	#define	SW2_GPIO				GPIO_PD6
	#define PD5_FUNC				AS_GPIO
	#define PD6_FUNC				AS_GPIO
	#define PD5_INPUT_ENABLE		1
	#define PD6_INPUT_ENABLE		1
	#define PULL_WAKEUP_SRC_PD5     PM_PIN_PULLUP_10K
	#define PULL_WAKEUP_SRC_PD6     PM_PIN_PULLUP_10K
#endif

#if (UI_LED_ENABLE)
	/* 825X Dongle and 827X Dongle use same GPIO for LED: PA3/PB1/PA2/PB0/PA4 */
	#define	GPIO_LED_RED			GPIO_PA3
	#define	GPIO_LED_WHITE			GPIO_PB1
	#define	GPIO_LED_GREEN			GPIO_PA2
	#define	GPIO_LED_BLUE			GPIO_PB0
	#define	GPIO_LED_YELLOW			GPIO_PA4

	#define PA3_FUNC				AS_GPIO
	#define PB1_FUNC				AS_GPIO
	#define PA2_FUNC				AS_GPIO
	#define PB0_FUNC				AS_GPIO
	#define PA4_FUNC				AS_GPIO

	#define	PA3_OUTPUT_ENABLE		1
	#define	PB1_OUTPUT_ENABLE		1
	#define PA2_OUTPUT_ENABLE		1
	#define	PB0_OUTPUT_ENABLE		1
	#define	PA4_OUTPUT_ENABLE		1

	#define LED_ON_LEVEL 			1 		//gpio output high voltage to turn on led
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

//////////////////// Audio /////////////////////////////////////
#define MIC_RESOLUTION_BIT		16
#define MIC_SAMPLE_RATE			16000
#define MIC_CHANNEL_COUNT		1
#define	MIC_ENCODER_ENABLE		0

#if (UI_AUDIO_ENABLE)//Audio enable

	#define BLE_DMIC_ENABLE					0  //0: Amic   1: Dmic

	/* Dongle Audio MODE:
	 * TL_AUDIO_DONGLE_ADPCM_GATT_TELINK
	 * TL_AUDIO_DONGLE_ADPCM_GATT_GOOGLE
	 * TL_AUDIO_DONGLE_ADPCM_HID
	 * TL_AUDIO_DONGLE_SBC_HID
	 * TL_AUDIO_DONGLE_ADPCM_HID_DONGLE_TO_STB
	 * TL_AUDIO_DONGLE_SBC_HID_DONGLE_TO_STB
	 * TL_AUDIO_DONGLE_MSBC_HID
	 */
	#define TL_AUDIO_MODE  			TL_AUDIO_DONGLE_ADPCM_GATT_TELINK

	#if (TL_AUDIO_MODE == TL_AUDIO_DONGLE_ADPCM_GATT_GOOGLE)
		#define GOOGLE_VERSION_0_4  0
		#define GOOGLE_VERSION_1_0  1
		#define GOOGLE_VOICE_OVER_BLE_SPCE_VERSION  GOOGLE_VERSION_1_0
		#if (GOOGLE_VOICE_OVER_BLE_SPCE_VERSION == GOOGLE_VERSION_1_0)
			#define GOOGLE_VOICE_MODE	0x00	//	0x00: On-request; 0x01:PTT;	0x03:HTT
		#endif
	#endif



#endif

#define APPLICATION_DONGLE							1
#if(APPLICATION_DONGLE)
	#define PA5_FUNC				AS_USB
	#define PA6_FUNC				AS_USB
	#define PA5_INPUT_ENABLE		1
	#define PA6_INPUT_ENABLE		1

	#define	USB_PRINTER_ENABLE 		1
	#define	USB_SPEAKER_ENABLE 		0

	#if ((TL_AUDIO_MODE & TL_AUDIO_MASK_HID_SERVICE_CHANNEL) && (TL_AUDIO_MODE & TL_AUDIO_MASK_DONGLE_TO_STB))//HIDdongle to STB
	#define	USB_MIC_ENABLE 			0
	#define AUDIO_HOGP				1	//Audio HID Over GATT Profile
	#else
	#define AUDIO_HOGP				0	//Audio HID Over GATT Profile
	#define	USB_MIC_ENABLE 			1
	#endif

	#define	USB_MOUSE_ENABLE 		1
	#define	USB_KEYBOARD_ENABLE 	1
	#define	USB_SOMATIC_ENABLE      0   //  when USB_SOMATIC_ENABLE, USB_EDP_PRINTER_OUT disable
	#define USB_CUSTOM_HID_REPORT	1

	#define USB_CDC_ENABLE			0
#endif



#if ((TL_AUDIO_MODE & TL_AUDIO_MASK_HID_SERVICE_CHANNEL) && (TL_AUDIO_MODE & TL_AUDIO_MASK_DONGLE_TO_STB))//HIDdongle to STB
//////////// product  Information  //////////////////////////////
#define ID_VENDOR				0x1d5a//0x248a			// for report
#define ID_PRODUCT_BASE			0xc080//0x880C//AUDIO_HOGP
#define STRING_VENDOR			L"Telink"
#define STRING_PRODUCT			L"BLE Remote KMA Dongle"
#define STRING_SERIAL			L"TLSR8278"
#else
//////////// product  Information  //////////////////////////////
#define ID_VENDOR				0x248a			// for report
#define ID_PRODUCT_BASE			0x880C//AUDIO_HOGP
#define STRING_VENDOR			L"Telink"
#define STRING_PRODUCT			L"BLE Remote KMA Dongle"
#define STRING_SERIAL			L"TLSR8278"
#endif








///////////////////////// System Clock  Configuration /////////////////////////////////////////
#if (TL_AUDIO_MODE & (TL_AUDIO_MASK_SBC_MODE|TL_AUDIO_MASK_MSBC_MODE))
#define CLOCK_SYS_CLOCK_HZ  								48000000
#else
#define CLOCK_SYS_CLOCK_HZ  								32000000
#endif


/////////////////// watchdog  //////////////////////////////
#define MODULE_WATCHDOG_ENABLE		0
#define WATCHDOG_INIT_TIMEOUT		500  //ms





/////////////////////////////////////// PRINT DEBUG INFO ///////////////////////////////////////
#if (UART_PRINT_DEBUG_ENABLE)
	#define DEBUG_INFO_TX_PIN           					GPIO_PB5
	#define PULL_WAKEUP_SRC_PB5         					PM_PIN_PULLUP_10K
	#define PB5_OUTPUT_ENABLE         						1
	#define PB5_DATA_OUT                                    1 //must
#endif



/////////////////// set default   ////////////////

#include "vendor/common/default_config.h"
