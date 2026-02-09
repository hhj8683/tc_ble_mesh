/********************************************************************************************************
 * @file	usb_bulk.c
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
#include "tl_common.h"

typedef void (*usb_bulk_out_callback_t)(u8 *p, int n, int offset);

void	usb_bulk_drv_init (void *p);	//initialization
int		usb_bulk_in (u8 *p, int n);		//send status
int		usb_bulk_proc ();				//called in main loop

/////////////////////////////////////////////////////
// write flash memory through swire
/////////////////////////////////////////////////////
#define			USB_ENDPOINT_BULK_IN			8
#define			USB_ENDPOINT_BULK_OUT			5
#define			USB_ENDPOINT_BULK_OUT_FLAG		(1 << (USB_ENDPOINT_BULK_OUT & 7))

usb_bulk_out_callback_t usb_p_bulkout_func = 0;

u32			usb_bi_offset = 0;
u32			usb_bo_tick = 0;
u8			usb_bo_buff[64] = {0};
u32			usb_bo_offset = 0;

static inline u32 usb_endpoint_busy(u32 ep) {
	write_reg8 (0x80013d, 0);
	return read_reg8 (0x800120 + (ep&7)) & 1;
}


void usb_bulk_drv_init (void *p)
{
	usb_p_bulkout_func = (usb_bulk_out_callback_t) p;

	write_reg8 (0x800120 + (USB_ENDPOINT_BULK_OUT & 7), 1);		//ACK
}

// 0: last packet; 72: max size packet; -1: busy
int usb_bulk_in_packet (u8 *p, int n)
{
	static u32 offset = 0;

	if( usb_endpoint_busy(USB_ENDPOINT_BULK_IN))
		return -1;

	int data_unfinish = 0;

	if (n <= 64)
	{
		offset = 0;
	}
	else
	{
		n -= offset;
		if (n > 64)
		{
			n = 64;
			data_unfinish = 1;  //data not over
		}
	}

	//reset pointer to 0
	write_reg8 (0x800110 + (USB_ENDPOINT_BULK_IN & 7), 0);
	for (int i=0; i<n; i++)
	{
		write_reg8 (0x800118 + (USB_ENDPOINT_BULK_IN & 7), p[offset + i]);
	}
	write_reg8 (0x800120 + (USB_ENDPOINT_BULK_IN & 7), 1);		//ACK

	offset = data_unfinish ? offset + 64 : 0;

	return offset;
}


int usb_bulk_proc ()
{
	if (read_reg8 (0x800139) & USB_ENDPOINT_BULK_OUT_FLAG)
	{
		//clear interrupt flag
		write_reg8 (0x800139, USB_ENDPOINT_BULK_OUT_FLAG);

		// read data
		int n = read_reg8 (0x800110 + (USB_ENDPOINT_BULK_OUT & 7));
		write_reg8 (0x800110 + (USB_ENDPOINT_BULK_OUT & 7), 0);
		for (int i=0; i<n; i++)
		{
			usb_bo_buff[i] = read_reg8 (0x800118 + (USB_ENDPOINT_BULK_OUT & 7));
		}
		write_reg8 (0x800120 + (USB_ENDPOINT_BULK_OUT & 7), 1);		//ACK

		if (!usb_bo_offset)
		{
			usb_bi_offset = 0;
		}

		if (usb_p_bulkout_func)
		{
			usb_p_bulkout_func (usb_bo_buff, n, usb_bo_offset);
		}
		usb_bo_offset += n;
		if (n < 64)
		{
			usb_bo_offset = 0;
		}
		return 1;
	}
	return 0;
}

int usb_bulk_out_get_data (u8 *p)
{
	if (read_reg8 (0x800139) & USB_ENDPOINT_BULK_OUT_FLAG)
	{
		//clear interrupt flag
		write_reg8 (0x800139, USB_ENDPOINT_BULK_OUT_FLAG);

		// read data
		int n = read_reg8 (0x800110 + (USB_ENDPOINT_BULK_OUT & 7));
		write_reg8 (0x800110 + (USB_ENDPOINT_BULK_OUT & 7), 0);
		for (int i=0; i<n; i++)
		{
			p[i] = read_reg8 (0x800118 + (USB_ENDPOINT_BULK_OUT & 7));
		}
		write_reg8 (0x800120 + (USB_ENDPOINT_BULK_OUT & 7), 1);		//ACK

		return n;
	}
	return 0;
}
