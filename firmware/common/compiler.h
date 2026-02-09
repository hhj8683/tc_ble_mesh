/********************************************************************************************************
 * @file    compiler.h
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
#pragma once

#ifdef __GNUC__
/*
 * section name is generated base on filename and line number to ensure uniqueness
 * IDE will not link unused ramecode function in files due to the different section name
 */
#define _STRINGIFY_ATTR(x)                  #x
#define STRINGIFY_ATTR(x)                   __FILE__ _STRINGIFY_ATTR(x)
#define _attribute_func_ram_code_sec_       __attribute__((section(".ram_code." STRINGIFY_ATTR(__LINE__))))

#define _attribute_packed_				__attribute__((packed))
#define _attribute_aligned_(s)			__attribute__((aligned(s)))
#define _attribute_session_(s)			__attribute__((section(s)))
#define _attribute_ram_code_  			_attribute_func_ram_code_sec_ __attribute__((noinline))
#define _attribute_ram_code_noinline_	_attribute_func_ram_code_sec_ __attribute__((noinline))
#define _attribute_custom_code_  		_attribute_session_(".custom") volatile
#define _attribute_no_inline_   		__attribute__((noinline))
#define _inline_ 						inline
#define __WEAK                          __attribute__((weak))   // user can define their own function

#define _attribute_ram_code_sec_      		_attribute_func_ram_code_sec_
#define _attribute_ram_code_sec_noinline_	_attribute_func_ram_code_sec_ __attribute__((noinline))

/**
 *  _always_inline needs to be added in the following two cases:
 * 1. The subfunctions in the pm_sleep_wakeup function need to use _always_inline and _attribute_ram_code_sec_noinline_, as detailed in the internal comments of pm_sleep_wakeup.
 */
#define _always_inline                      inline __attribute__((always_inline))

/*
 * _align_4_: for eclipse, can save code size and ramcode size,
 *            if add align when extern global variable with struct, because other file will take this global variable as not align.
 *            no need to add align for u32/u26, because eclipse has already taken it as 16/32 bit align.
 */
#define _align_4_				__attribute__((aligned(4)))

#ifndef	BLC_PM_DEEP_RETENTION_MODE_EN
#define	BLC_PM_DEEP_RETENTION_MODE_EN		1
#endif

#if (BLC_PM_DEEP_RETENTION_MODE_EN)
//  #define _attribute_data_retention_sec_	__attribute__((section(".retention_data")))
//  #define _attribute_data_retention_   	__attribute__((section(".retention_data")))
//  #define _attribute_ble_data_retention_  __attribute__((section(".retention_data")))
	#define _attribute_data_no_init_   		__attribute__((section(".data_no_init")))    //save retention ram size
    #if (!__PROJECT_BOOTLOADER__) // if bootloader use this section, it need to fix AT(no_ret_data) and copy position from flash in cstartup.
    #define _attribute_no_retention_data_   __attribute__((section(".no_ret_data")))
    #endif
    #define _attribute_no_retention_bss_   __attribute__((section(".no_ret_bss")))
#endif
#else
	#define _attribute_data_retention_sec_
    #define _attribute_data_retention_
	#define _attribute_ble_data_retention_
	#define _attribute_data_no_init_
#endif

#ifndef _attribute_data_retention_sec_
#define _attribute_data_retention_sec_
#endif
#ifndef _attribute_data_retention_
#define _attribute_data_retention_
#endif
#ifndef _attribute_bss_retention_
#define _attribute_bss_retention_       //
#endif
#ifndef _attribute_ble_data_retention_
#define _attribute_ble_data_retention_
#endif
#ifndef _attribute_data_no_init_
#define _attribute_data_no_init_
#endif
#ifndef _attribute_no_retention_data_
#define _attribute_no_retention_data_
#endif
#ifndef _attribute_no_retention_bss_
#define _attribute_no_retention_bss_    //
#endif
#ifndef _attribute_bss_big_size__
#define _attribute_bss_big_size__       //
#endif
#ifndef _attribute_data_dlm_
#define _attribute_data_dlm_
#endif
#ifndef _attribute_bss_dlm_
#define _attribute_bss_dlm_
#endif
#ifndef _align_4_
#define _align_4_						
#endif

#ifndef __WEAK
#define __WEAK                          //
#endif

#if WIN32
#define __UNUSED
#else
#define __UNUSED						__attribute__((unused))		// no compile warning with "set but not used [-Wunused-but-set-variable]"
#endif

#define _align_type_4_					_align_4_	// must make sure all pointers of the struct are 4 bytes aligned when used

#define _USER_CAN_REDEFINE_             __WEAK // user can re-define function in user_app.c

#define COMPILE_PRINT_MACRO_HELPER(x)	#x
#define COMPILE_PRINT_MACRO(x)			#x"="COMPILE_PRINT_MACRO_HELPER(x)
/* 
 * func: get value of MACRO when compile.
 * COMPILE_PRINT_MACRO sample:
#pragma message(COMPILE_PRINT_MACRO(BLC_PM_DEEP_RETENTION_MODE_EN))
*/

// #define COMPILE_PRINT_SIZEOF(x) 		char __size_of_##x##_is[sizeof(x) + 1] = {[sizeof(x)] = ""} // only support in RISC-V compiler now.

/* COMPILE_PRINT_SIZEOF_ECLIPSE: find variable name as compile_size_var in lst file, and will get the size, such as. 
   00846e40 <compile_size_var>:
	 846e40:   00000008 (size of (compile_size_var) is 8)
*/
#define COMPILE_PRINT_SIZEOF_ECLIPSE(x)	volatile __attribute__((section(".sdk_version"))) const unsigned int compile_size_var = sizeof(x) // for B85m
