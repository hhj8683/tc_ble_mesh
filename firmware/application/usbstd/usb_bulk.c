/********************************************************************************************************
 * @file     usb.c 
 *
 * @brief    for TLSR chips
 *
 * @author	 BLE Group
 * @date     Sep. 18, 2015
 *
 * @par      Copyright (c) Telink Semiconductor (Shanghai) Co., Ltd.
 *           All rights reserved.
 *           
 *			 The information contained herein is confidential and proprietary property of Telink 
 * 		     Semiconductor (Shanghai) Co., Ltd. and is available under the terms 
 *			 of Commercial License Agreement between Telink Semiconductor (Shanghai) 
 *			 Co., Ltd. and the licensee in separate contract or the terms described here-in. 
 *           This heading MUST NOT be removed from this file.
 *
 * 			 Licensees are granted free, non-transferable use of the information in this 
 *			 file under Mutual Non-Disclosure Agreement. NO WARRENTY of ANY KIND is provided. 
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
