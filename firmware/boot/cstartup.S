/********************************************************************************************************
 * @file	cstartup_8258_RET_16K.S
 *
 * @brief	for TLSR chips
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
#if 1//MCU_STARTUP_8258
@.include "version.in"
#include "../vendor/common/version.h"
@********************************************************************************************************
@                                   SRAM CONFIGURATION
@********************************************************************************************************
#define SRAM_BASE_ADDR		(0x840000)
#define SRAM_32K      		(0x8000)	//32KSRAM
#define SRAM_48K      		(0xc000)	//48KSRAM
#define SRAM_64K      		(0x10000)	//64KSRAM

#ifndef RAM_SIZE_MAX
#define RAM_SIZE_MAX            (SRAM_64K)
#endif

#ifndef SRAM_SIZE
#define	SRAM_SIZE		(SRAM_BASE_ADDR + RAM_SIZE_MAX)
#endif

@********************************************************************************************************
@                                   BOOT FEATURE CONFIGURATION
@********************************************************************************************************

#define  FLL_STK_EN     	MCU_STACK_INIT_EN
#define  GPIO_DEBUG_EN          0

#ifndef __LOAD_RAM_SIZE__
#define	__LOAD_RAM_SIZE__		0xc
#endif


	.code	16

@********************************************************************************************************
@                                           MACROS AND DEFINIITIONS
@********************************************************************************************************

					@ Mode, correspords to bits 0-5 in CPSR
	.equ MODE_BITS,		0x1F	@ Bit mask for mode bits in CPSR
	.equ IRQ_MODE, 		0x12	@ Interrupt Request mode
	.equ SVC_MODE, 		0x13	@ Supervisor mode 

	.equ __LOAD_RAM, 	__LOAD_RAM_SIZE__
	.equ __RAM_START_ADDR, 	(SRAM_BASE_ADDR)
	.equ __RAM_SIZE_MAX, 	(RAM_SIZE_MAX)
	.equ __SRAM_SIZE,   SRAM_SIZE
	
@********************************************************************************************************
@                                            TC32 EXCEPTION VECTORS
@********************************************************************************************************

	.section	.vectors,"ax"
	.global		__reset
	.global	 	__irq
	.global 	__start
	.global		__LOAD_RAM
	.global		__RAM_START_ADDR 
	.global		__RAM_SIZE_MAX 
	.global		__SRAM_SIZE

__start:					@ MUST,  referenced by boot.link

	.extern irq_handler

	.extern  _ramcode_size_div_16_
	.extern  _ramcode_size_div_256_
	.extern  _ramcode_size_div_16_align_256_
	.extern  _ramcode_size_align_256_
	.extern  _ictag_start_
	.extern  _ictag_end_
	.extern  _code_size_div_256_
	.extern  _ramcode_size_div_256_compile_

	.org 0x0
	tj	__reset
	.word	(BUILD_VERSION)
	.org 0x8
	.word	(0x544c4e4b)
#if (MCU_RUN_SRAM_EN || MCU_RUN_SRAM_WITH_CACHE_EN)
	.word	(0x00880000 + _bin_size_div_16_)
#else
    #if (MCU_CORE_TYPE == MCU_CORE_TC321X)
    .word	(0x00880000 + _cstartup_ram_funcs_size_div_16_)
    #else
	.word	(0x00880000 + _ramcode_size_div_16_align_256_)	@must align 256, because of ic tag is 256 aligned
	#endif
@	.word	(0x00880000 + 0x400)
#endif

	.org 0x10
	tj		__irq
	.org 0x18
	.word	(_bin_size_)
@********************************************************************************************************
@                                   LOW-LEVEL INITIALIZATION
@********************************************************************************************************
	.extern  main
#if (MCU_CORE_TYPE == MCU_CORE_TC321X)
	.extern rf_sw_config
	.extern copy_ramcode
	.extern copy_bincode
#endif

	.org 0x20
	.align 4
#if ((MCU_CORE_TYPE == MCU_CORE_825x) || (MCU_CORE_TYPE == MCU_CORE_TC321X))
	.global start_suspend
	.thumb_func
	.type start_suspend, %function

start_suspend:
	tpush   {r2-r3}

    tmovs r2, #129    @0x81
    tloadr r3, __suspend_data      @0x80006f
    tstorerb r2, [r3, #0]  @*(volatile unsigned char *)0x80006f = 0x81

    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8

    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
	
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
	
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    tmov r8, r8
    
    tpop {r2-r3}
    tjex lr

__suspend_data:
	.word   (0x80006f)
#endif


__reset:

#if GPIO_DEBUG_EN
    #if (MCU_CORE_TYPE == MCU_CORE_TC321X)
	@ add debug, PB4 output 1
	tloadr     	r1, DEBUG_GPIO_OEN    @0x80050a  PB oen
	tmov		r0, #16		@0b 00010000
	tstorerb	r0, [r1, #0]

	tloadr     	r1, DEBUG_GPIO_OUTPUT
	tmov		r0, #16			@0b 00010000
	tstorerb	r0, [r1, #0]	@0x8005c4  PB output set
    #else
	@ add debug, PB4 output 1
	tloadr     	r1, DEBUG_GPIO    @0x80058a  PB oen
	tmov		r0, #239      @0b 11101111
	tstorerb	r0, [r1, #0]

	tmov		r0, #16			@0b 00010000
	tstorerb	r0, [r1, #1]	@0x800583  PB output
	#endif
#endif


@send flash cmd 0xab to wakeup flash;
FLASH_WAKEUP_BEGIN:
	tloadr      r0,FLASH_RECOVER + 0
	tmov		r1,#0
	tstorerb    r1,[r0,#1]
	tmov        r1,#171						@Flash deep cmd: 0xAB
	tstorerb    r1,[r0,#0]
	tmov		r2,#0
	tmov        r3,#6
TNOP:
	tadd        r2,#1
	tcmp        r2,r3
	tjle        TNOP
	tmov		r1,#1
	tstorerb    r1,[r0,#1]
FLASH_WAKEUP_END:

#if (MCU_CORE_TYPE == MCU_CORE_827x)
@ efuse load need delay about 18us
	tmov		r2,#0
	tmov        r3,#110
EFUSE_DELAY:
	tadd        r2,#1
	tcmp        r2,r3
	tjle        EFUSE_DELAY
EFUSE_DELAY_END:
#endif

#if __PROJECT_BOOTLOADER__
    @ bootloader copy code mode
	tloadr      r1, COPY_CODE_I
	tloadr      r2, COPY_CODE_I+4
	tloadr      r3, COPY_CODE_I+8
COPY_CODE:
	tcmp        r2, r3
	tjge        COPY_CODE_END
	tsub        r1, #4
	tsub        r3, #4
	tloadr      r0, [r1, #0]
	tstorer     r0, [r3, #0]
	tj          COPY_CODE
COPY_CODE_END:
#endif


	tloadr	r0, DAT0
	tmcsr	r0			
	tloadr	r0, DAT0 + 8
	tmov	r13, r0  

	tloadr	r0, DAT0 + 4
	tmcsr	r0	
	tloadr	r0, DAT0 + 12
	tmov	r13, r0  
@********************************************************************************************************
@                                    IC CACHE INITIALIZATION
@********************************************************************************************************
SETIC:
	tloadr     	r1, DAT0 + 24
#if (MCU_RUN_SRAM_EN)
	tmov		r0, #255;
	tstorerb	r0, [r1, #0]
	tstorerb	r0, [r1, #1]
#else
	tloadr      r0, DAT0 + 36					@ IC tag start
	tstorerb	r0, [r1, #0]
	tadd    	r0, #1							@ IC tag end
	tstorerb	r0, [r1, #1]
	@tmov		r0, #0;
	@tstorerb	r0, [r1, #2]
@********************************************************************************************************
@                                    IC TAG INITIALIZATION
@********************************************************************************************************	
    tmov        r0, #0
    tloadr      r1, DAT0 + 28
    tloadr      r2, DAT0 + 32

ZERO_TAG:    @no need init tag when wake up from deep retention, because tag is in retention too
    tcmp        r1, r2
    tjge        ZERO_TAG_END
    tstorer     r0, [r1, #0]
    tadd        r1, #4
    tj          ZERO_TAG
ZERO_TAG_END:
#endif

@********************************************************************************************************
@                                    BOOT FLAG INITIALIZATION
@********************************************************************************************************
SET_BOOT: @because no load ramcode when boot from retention, so must set boot area manually.
    #if(MCU_CORE_TYPE == MCU_CORE_825x)
	tmov        r2, #4
	tloadrb     r1, [r2]        @read form core_840004
	tmov        r0, #165    @A5
	tcmp        r0, r1
	tjne        SET_BOOT_END    @power up

	tmov        r2, #5
	tloadrb     r1, [r2]        @read form core_840005
	tloadr      r0, BOOT_SEL_D
	tstorerb    r1, [r0, #0]
	tj          COPY_DATA_END   @wake up from retention deep
    #elif((MCU_CORE_TYPE == MCU_CORE_827x) || (MCU_CORE_TYPE == MCU_CORE_TC321X))
    tmov        r2, #20
    tloadrb     r1, [r2]		@read form core_840014

    tmov     	r0, #90    @5A
    tcmp        r0, r1
    tjne		SET_BOOT_END

    tmov        r2, #21
    tloadrb     r1, [r2]		@read form core_840015

    tmov     	r0, #165    @A5
    tcmp        r0, r1
    tjne		SET_BOOT_END

    tmov        r2, #22
    tloadrb     r1, [r2]		@read form core_840016
    tloadrb		r0,	BOOT_SEL_D
    tstorerb	r1, [r0, #0]

    tmov        r2, #23
    tloadrb     r1, [r2]		@read form core_840017
    tstorerb	r1, [r0, #1]
    tj          COPY_DATA_END   @wake up from retention deep
    #endif
SET_BOOT_END:

#if (MCU_CORE_TYPE == MCU_CORE_TC321X)
COPY_RAMCODE_START:
    tjl         copy_ramcode
    tjl         rf_sw_config    @need 9.3k heap size to run
COPY_RAMCODE_END:
#endif

#if RUN_128K_IN_20000_EN // run 128K in 0x20000, default disable to save RAM code.
#if (MCU_CORE_TYPE == MCU_CORE_8278)
	tloadr      r0, BOOT_SEL_D
	tloadrh	    r1, [r0, #0]
	tcmp	    r1, #249
	tjne	    SET_OFFSET_END
	tadd        r1, #8			@ 128k
	tstorerh    r1, [r0, #0]
#else
	tloadr      r0, BOOT_SEL_D
	tloadrb	    r1, [r0, #0]
	tcmp	    r1, #125
	tjne	    SET_OFFSET_END
	tmovs	    r1, #129		@ 128k
	tstorerb    r1, [r0, #0]
#endif
SET_OFFSET_END:
#endif

@********************************************************************************************************
@                              fill system stack with 0xff
@********************************************************************************************************
#if FLL_STK_EN

	tloadr	r0, FLL_D     @r0 = 0xffffffff
	tloadr	r1, FLL_D+4   @r1 = default (SRAM_SIZE -3k)
	tloadr	r2, FLL_D+8   @r2 = SRAM_SIZE

FLL_STK:
	tcmp	r1, r2
	tjge	FLL_STK_END   @r1>=r2 jump to FLL_STK_END
	tstorer r0, [r1, #0]  @*(unsigned int*)(r1)=0xffffffff
	tadd    r1, #4        @r1 = r1+4
	tj		FLL_STK       @jump to FLL_STK
FLL_STK_END:

#endif

@********************************************************************************************************
@                                    BSS INITIALIZATION
@********************************************************************************************************
	tmov    	r0, #0
	tloadr  	r1, DAT0 + 16
	tloadr  	r2, DAT0 + 20

ZERO:
	tcmp    	r1, r2
	tjge    	ZERO_END
	tstorer 	r0, [r1, #0]
	tadd    	r1, #4
	tj      	ZERO
ZERO_END:

@********************************************************************************************************
@                                    DATA INITIALIZATION
@********************************************************************************************************
	tloadr		r1, DATA_I
	tloadr		r2, DATA_I+4
	tloadr		r3, DATA_I+8
COPY_DATA:
	tcmp		r2, r3
	tjge		COPY_DATA_END
	tloadr		r0, [r1, #0]
	tstorer 	r0, [r2, #0]
	tadd    	r1, #4
	tadd		r2, #4
	tj			COPY_DATA
COPY_DATA_END:

@********************************************************************************************************
@                                    NO RETENTION BSS INITIALIZATION
@********************************************************************************************************
@always load data or zero here
	tmov		r0, #0
	tloadr		r1, NO_RET_BSS_I + 0
	tloadr  	r2, NO_RET_BSS_I + 4

ZERO_NO_RET_BSS:
	tcmp    	r1, r2
	tjge    	ZERO_NO_RET_BSS_END
	tstorer 	r0, [r1, #0]
	tadd    	r1, #4
	tj      	ZERO_NO_RET_BSS
ZERO_NO_RET_BSS_END:

@********************************************************************************************************
@                                    NO RETENTION DATA INITIALIZATION
@********************************************************************************************************
#if 1   //      (_dstored_ + (_end_data_ -  _start_data_))
	tloadr		r1, DATA_I+0
	tloadr		r2, DATA_I+8
	tadd		r1, r1, r2
	tloadr		r2, DATA_I+4
	tsub		r1, r1, r2
#endif
	tloadr		r2, NO_RET_DATA_I+0
	tloadr		r3, NO_RET_DATA_I+4
COPY_NO_RET_DATA:
	tcmp		r2, r3
	tjge		COPY_NO_RET_DATA_END
	tloadr		r0, [r1, #0]
	tstorer 	r0, [r2, #0]
	tadd    	r1, #4
	tadd		r2, #4
	tj		COPY_NO_RET_DATA
COPY_NO_RET_DATA_END:

#if 0
SETSPISPEED:
	tloadr     	r1, DAT0 + 36
	tmov		r0, #0xbb		@0x0b for fast read; 0xbb for dual dat/adr
	tstorerb	r0, [r1, #0]
	tmov		r0, #3			@3 for dual dat/adr
	tstorerb	r0, [r1, #1]
#endif

	tjl	main
END:	tj	END

	.balign	4
DAT0:
	.word	0x12			    @IRQ    @0
	.word	0x13			    @SVC    @4
	.word	(irq_stk + __IRQ_STACK_SIZE__)
	.word	(SRAM_SIZE)		    @12  stack end
	.word	(_start_bss_)               @16
	.word	(_end_bss_)                 @20
	.word	(0x80060c)                  @24

	.word	_ictag_start_               @28
	.word	_ictag_end_	            	@32
	.word	_ramcode_size_div_256_      @36     @ IC tag u8 value

	.word	(_retention_size_)          @40

BOOT_LINK_NEED: 
	.word   _code_size_div_256_                 @ exclude data
	.word   _ramcode_size_div_256_compile_

DATA_I:	
#if __PROJECT_BOOTLOADER__
	.word   _dstored_bin_				@0
#else
	.word	_dstored_					@0
#endif
	.word	_start_data_				@4
	.word	_end_data_					@8
	
NO_RET_DATA_I: 
	.word   (_no_retention_data_start_) @0
	.word   (_no_retention_data_end_)   @4
	
NO_RET_BSS_I: 
	.word   (_no_retention_bss_start_)  @0
	.word   (_no_retention_bss_end_)    @4

#if __PROJECT_BOOTLOADER__
COPY_CODE_I:
    .word   (__RAM_START_ADDR + _code_size_)
    .word   (__RAM_START_ADDR + _ram_code_start_)
    .word   (__RAM_START_ADDR + _bootloader_ram_code_end_)
#endif

FLL_D:
	.word	0xffffffff
#if 0	// org
	.word	(_start_data_)
	@.word	(SRAM_SIZE)
	.word	(_start_data_ + 32)
#else
	#if FLL_STK_EN
		#if 0 // for debug mode
	.word   _no_retention_bss_end_    						@start address. initial all stack.
		#else
	.word   (SRAM_SIZE - 3*1024)    @start address. just clear 3k to decrease time. @(_end_bss_)
		#endif
	#else
	.word   (SRAM_SIZE - 4)			@start address. 
	#endif
	.word   (SRAM_SIZE)				@end address. 
#endif
	.word   (_rstored_)                 @24 // not use with FLL_D, just extern.
	@.word	(_ram_use_size_div_16_)         // not use with FLL_D, just extern.

#if GPIO_DEBUG_EN
#if (MCU_CORE_TYPE == MCU_CORE_TC321X)
DEBUG_GPIO_OEN:
	.word	(0x80050a)                  @  PBx oen

DEBUG_GPIO_OUTPUT:
	.word	(0x8005c4)                  @  PBx output set
#else
DEBUG_GPIO:
	.word	(0x80058a)                  @  PBx oen
#endif
#endif

BOOT_SEL_D:
	.word	(0x80063e)

FLASH_RECOVER:
	.word	(0x80000c)                  @0
	.word   _ram_code_start_    @ without this, compile would be error:"nonconstant expression for load base" when there is not text section.

	.align 4
__irq:
	tpush    	{r14}
	tpush    	{r0-r7}
	tmrss    	r0
	
	tmov		r1, r8
	tmov		r2, r9
	tmov		r3, r10
	tmov		r4, r11
	tmov		r5, r12
	tpush		{r0-r5}
	
	tjl      	irq_handler

	tpop		{r0-r5}
	tmov		r8, r1
	tmov		r9, r2
	tmov		r10,r3
	tmov		r11,r4
	tmov		r12,r5

	tmssr    	r0
	tpop		{r0-r7}
	treti    	{r15}

ASMEND:

	.section .bss
	.align 4
	@.lcomm irq_stk, __IRQ_STACK_SIZE__ @ define in mesh_common.c
	.end

#endif
