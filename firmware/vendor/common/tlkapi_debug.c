/********************************************************************************************************
 * @file    tlkapi_debug.c
 *
 * @brief   This is the source file for BLE SDK
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
#include "tl_common.h"
#include "drivers.h"

#include <stdarg.h>

_attribute_ble_data_retention_ tlk_dbg_t tlkDbgCtl;
extern int u_printf(const char *format, ...);


#include "tlkapi_debug.h"
void tlkapi_debug_init(void)
{
	tlkDbgCtl.dbg_en = 1;
}

/**
 * @brief   	Send debug log to log FIFO, printf mode
 *				attention: here just send log to FIFO, can not output immediately, wait for "tlkapi debug_handler" to output log.
 * @param[in]	format - the string will be printed
 * @return
 */

int tlk_printf(const char *format, ...)
{
	#if(UART_PRINT_DEBUG_ENABLE)
//		if(tlkDbgCtl.dbg_en)
        {
			va_list args;
			va_start( args, format );
			print(0, format, args);
			va_end( args );
		}
	#endif
	return 0;
}

/**
 * @brief   Send debug log to log FIFO, character string and data mixed mode.
 *			attention: here just send log to FIFO, can not output immediately, wait for "tlkapi debug_handler" to output log.
 * @param[in]	str - character string
 * @param[in]	pData - pointer of data
 * @param[in]	len - length of data
 * @return		none
 */

void tlkapi_send_str_data (char *str, u8 *pData, u32 data_len)
{
	#if(UART_PRINT_DEBUG_ENABLE)
//		if(tlkDbgCtl.dbg_en)
        {

			/* user can change this size if "data_len" bigger than 32 */
			#define TLKAPI_DEBUG_DATA_MAX_LEN    32
			unsigned char hex[] = "0123456789abcdef";
			unsigned char temp_str[TLKAPI_DEBUG_DATA_MAX_LEN * 3 + 4];
			const u8 *b = pData;
			u8 i;

			u8 len = min(data_len, TLKAPI_DEBUG_DATA_MAX_LEN);
            int ind         = 0;
            temp_str[ind++] = ':';
			for (i = 0; i < len; i++) {
				temp_str[ind++] = ' ';
				temp_str[ind++] = hex[b[i] >> 4];
				temp_str[ind++] =  hex[b[i] & 0xf];
			}

            temp_str[ind++] = '\r';
            temp_str[ind++] = '\n';
			temp_str[ind] = '\0';

			my_printf("%s%s", str, temp_str);
		}
	#endif
}
