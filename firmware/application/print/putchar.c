/********************************************************************************************************
 * @file    putchar.c
 *
 * @brief   This is the source file for B85
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
#ifndef WIN32

#include "tl_common.h"
#include "application/print/putchar.h"
#include "drivers.h"
#include "myprintf.h"

#ifndef USB_PRINT_DEBUG_ENABLE
#define USB_PRINT_DEBUG_ENABLE                    			0
#endif

#if (MCU_CORE_TYPE == CHIP_TYPE_TC321X && USB_PRINT_DEBUG_ENABLE)
	#error "CHIP TC321X doesn't support USB!"
#endif

#if (USB_PRINT_DEBUG_ENABLE)
#define USB_PRINT_TIMEOUT	 10		//  about 10us at 30MHz
#define USB_SWIRE_BUFF_SIZE  248	// 256 - 8

#define USB_EP_IN  		(USB_EDP_PRINTER_IN  & 0X07)	//  from the point of HOST 's view,  IN is the printf out
#define USB_EP_OUT  	(USB_EDP_PRINTER_OUT & 0X07)

int usb_putc(int c) {
	int i = 0;
	while(i ++ < USB_PRINT_TIMEOUT){
		if(!(reg_usb_ep8_fifo_mode & FLD_USB_ENP8_FULL_FLAG)){
			reg_usb_ep_dat(USB_EP_IN) = (unsigned char)c;
			return c;
		}
	}
	return -1;
}

static inline void swire_set_clock(unsigned char div){
	reg_swire_ctl2 = div;
}

static int swire_is_init = 0;
void swire_init(){
#if(USB_SOMATIC_ENABLE)
    //  when USB_SOMATIC_ENABLE, USB_EDP_PRINTER_OUT disable
#else
//	r_usb.ep_adr[USB_EP_IN] = r_usb.ep_adr[USB_EP_OUT] = 0;
	reg_usb_ep_ptr(USB_EP_IN) = reg_usb_ep_ptr(USB_EP_OUT) = 0;
	reg_usb_ep8_send_max = 64;				// 32 * 8 == 256

	//swire_set_clock(2);

#endif
}

int swire_putc(int c) {
#if(USB_SOMATIC_ENABLE)
    //  when USB_SOMATIC_ENABLE, USB_EDP_PRINTER_OUT disable
#else
	if(!swire_is_init){
		swire_init();
		swire_is_init = 1;
	}
	int i = 0;
	while(i ++ < USB_PRINT_TIMEOUT){
		if(reg_usb_ep_ptr(USB_EP_IN) - reg_usb_ep_ptr(USB_EP_OUT) <= USB_SWIRE_BUFF_SIZE){	//  not full
			reg_usb_ep_dat(USB_EP_IN) = (unsigned char)c;
			return c;
		}
	}
#endif
	return -1;
}
#endif

#if (UART_PRINT_DEBUG_ENABLE)
int uart_putc(char byte) //GPIO simulate uart print func
{
    uart_simu_send_bytes((u8 *)&byte, 1);

    return 0;
}
#endif

int putchar(int c){
#if (UART_PRINT_DEBUG_ENABLE)
	return uart_putc((char)c);
#elif (USB_PRINT_DEBUG_ENABLE)
	if(reg_usb_host_conn){
		swire_is_init = 0;		// should re-init swire if connect swire again
		return usb_putc((char)c);
	}else{
		return swire_putc((char)c);
	}
#else
	return c;
#endif
}

#endif

