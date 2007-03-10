#include "xparameters.h"
#include "xbasic_types.h"
#include "xcache_l.h"
#include "xintc_l.h"
#include "xexception_l.h"
#include "xio_dcr.h"
#include "asm.h"

#define WIDTH 320
#define HEIGHT 240

void set_pixel(Xuint32 x, Xuint32 y, Xuint8 r, Xuint8 g, Xuint8 b)
{
	Xuint16 color;
	r >>= 3;
	g >>= 2;
	b >>= 3;
	color = (r << 11) | (g << 5) | b;
	Xuint16* addr = (Xuint16*)0x00140000;
	addr += WIDTH * y + x;
	*addr = color;
}

void Interrupted(void* param)
{
	//xil_printf("!");
}

void EndOfIsprite(void *param)
{
	//xil_printf("isprite OK\r\n");
}

#define ISPRITE_SLAVE_CONTROL 0x00000000
#define ISPRITE_SLAVE_SOURCE 0x00000008
#define ISPRITE_SLAVE_DESTINATION 0x00000010
#define ISPRITE_SLAVE_SPRITE_SIZE 0x00000018
#define ISPRITE_SLAVE_WORD_OFFSET 0x00000004

// Helper functions

#define isprite_write_control(base, data) \
	XIo_Out32(base + ISPRITE_SLAVE_CONTROL + ISPRITE_SLAVE_WORD_OFFSET, data);

#define isprite_read_control(base) \
	XIo_In32(base + ISPRITE_SLAVE_CONTROL + ISPRITE_SLAVE_WORD_OFFSET);

#define isprite_write_source(base, data) \
	XIo_Out32(base + ISPRITE_SLAVE_SOURCE + ISPRITE_SLAVE_WORD_OFFSET, data);

#define isprite_read_source(base) \
	XIo_In32(base + ISPRITE_SLAVE_SOURCE + ISPRITE_SLAVE_WORD_OFFSET);

#define isprite_write_destination(base, data) \
	XIo_Out32(base + ISPRITE_SLAVE_DESTINATION + ISPRITE_SLAVE_WORD_OFFSET, data);

#define isprite_read_destination(base) \
	XIo_In32(base + ISPRITE_SLAVE_DESTINATION + ISPRITE_SLAVE_WORD_OFFSET);

#define isprite_write_sprite_size(base, data) \
	XIo_Out32(base + ISPRITE_SLAVE_SPRITE_SIZE + ISPRITE_SLAVE_WORD_OFFSET, data);

#define isprite_read_sprite_size(base) \
	XIo_In32(base + ISPRITE_SLAVE_SPRITE_SIZE + ISPRITE_SLAVE_WORD_OFFSET);

int main()
{
	XCache_DisableDCache();
	/*
	xil_printf("pre DCM access\r\n");
	XIo_DcrOut(XPAR_ISPRITE_0_DCR_BASEADDR, 0x1234);//XPAR_ISPRITE_0_DCR_BASEADDR, 0x12345678);
	xil_printf("DCM access done\r\n");
	while(1);
	*/
	
	init_vga(XPAR_IVGA_0_BASEADDR);
	//ivga_off();
	ivga_mode640();
	
	/*
	cli();
	XExc_Init();
	XExc_RegisterHandler(XEXC_ID_NON_CRITICAL_INT, (XExceptionHandler)XIntc_DeviceInterruptHandler, (void *)XPAR_OPB_INTC_0_DEVICE_ID);
	XIntc_RegisterHandler(
	    XPAR_OPB_INTC_0_BASEADDR,
	    XPAR_OPB_INTC_0_IVGA_0_VGA_INTERRUPT_INTR,
	    (XInterruptHandler)Interrupted,
	    NULL
    );
	XIntc_RegisterHandler(
	    XPAR_OPB_INTC_0_BASEADDR,
	    XPAR_OPB_INTC_0_ISPRITE_0_ISPRITE_INTERRUPT_INTR,
	    (XInterruptHandler)EndOfIsprite,
	    NULL
    );
	ivga_activate_interrupt();
   XIntc_mMasterEnable(XPAR_OPB_INTC_0_BASEADDR);
	//XIntc_mEnableIntr(XPAR_OPB_INTC_0_BASEADDR, XPAR_ISPRITE_0_ISPRITE_INTERRUPT_MASK);
	XIntc_mEnableIntr(XPAR_OPB_INTC_0_BASEADDR, XPAR_IVGA_0_VGA_INTERRUPT_MASK);
	XExc_mEnableExceptions(XEXC_NON_CRITICAL);
	xil_printf("interruptions enabled\r\n");
	sti();
	*/

	ivga_on();	
	
	Xuint32* beurre;
	Xuint32 w, pipo;
	Xuint16 sprite_w = 64;
	Xuint16 sprite_h = 64;
	Xuint32 sprite_size = (sprite_w << 16) | sprite_h;
	Xuint32 source = 0x00100000;
	Xuint32 destination = 0x00140000;
	Xuint32 reference = 0x001C0000;
	Xuint32 i, xx, yy, loop;
	Xuint16 *pix, *referix;
	Xuint16 *verif, *verif2;
	Xuint16 expected;
	ivga_write_base_address(destination);
	for (loop = 0; loop < 42; loop++)
	{
		pix = (Xuint16 *)source;
		verif = (Xuint16 *)destination;
		verif2 = (Xuint16 *)reference;
		beurre = (Xuint32*)0x00180000;
	
		i = 0;
		for (yy = 0; yy < sprite_h; yy++)
		{
			for (xx = 0; xx < sprite_w; xx++)
			{
				/*
				if (yy == 1)
				{
					*(pix + i) = 0xF81F;
				}
				else if (yy == 2 || yy == sprite_h - 1)
				{
					if (xx == sprite_w - 1)
					{
						*(pix + i) = 0xF81F;
					}
					else
					{
						*(pix + i) = i;
					}
				}
				else if (yy == 3 || yy == 0)
				{
					if (xx == 0)
					{
						*(pix + i) = 0xF81F;
					}
					else
					{
						*(pix + i) = i;
					}
				}
				else if (yy == 4)
				{
					if (xx >= 2 && xx < sprite_w - 3)
					{
						*(pix + i) = i;
					}
					else
					{
						*(pix + i) = 0xF81F;
					}
				}
				else if (yy == 5)
				{
					if (xx == 7)
					{
						*(pix + i) = 0xF81F;
					}
					else
					{
						*(pix + i) = i;
					}
				}
				else
				{
					if (xx % 2 == 0 && yy % 2 != 0)
					{
						*(pix + i) = 0xF81F;
					}
					else
					{
						*(pix + i) = i;
					}
					if (yy % 4 == 0)
					{
						*(pix + i) = 0xF81F;
					}
				}*/
				//if (xx != yy)
				//{
				//	*(pix + i) = 0xF81F;
				//}
				//else
				//{
					*(pix + i) = i;
				//}
				if (xx == 0 || xx == (sprite_w - 1) || yy == 0 || yy == (sprite_h - 1))
				{
					*(pix + i) = 0xffff;
				}
				if (xx <= yy)
				{
					*(pix + i) = 0xF81F;
				}
				i++;
			}
		}
		for (yy = 0; yy < 240; yy++)
		{
			for (xx = 0; xx < 320; xx++)
			{
				*(verif++) = ((yy+xx) % 0x1f) << 11;
				*(verif2++) = ((yy+xx) % 0x1f) << 11;
			}
		}
		
		XIo_Out32(XPAR_ISPRITE_0_BASEADDR + ISPRITE_SLAVE_SPRITE_SIZE + ISPRITE_SLAVE_WORD_OFFSET, sprite_size);
		XIo_Out32(XPAR_ISPRITE_0_BASEADDR + ISPRITE_SLAVE_SOURCE + ISPRITE_SLAVE_WORD_OFFSET, source);
		XIo_Out32(XPAR_ISPRITE_0_BASEADDR + ISPRITE_SLAVE_CONTROL + ISPRITE_SLAVE_WORD_OFFSET, 1);
		/*
		for (w = 0; w < 1000000; w++)
		{
			*(beurre + (w >> 12)) = w;
			pipo = *(beurre + (w >> 12));
		}
		*/
		
		sleep(1);
		Xuint16 posx = 0;//rand() % (320-64);
		Xuint16 posy = 0;//rand() % (240-64);
		XIo_Out32(XPAR_ISPRITE_0_BASEADDR + ISPRITE_SLAVE_DESTINATION + ISPRITE_SLAVE_WORD_OFFSET, destination + posy * 320 * 2 + posx * 2);
		XIo_Out32(XPAR_ISPRITE_0_BASEADDR + ISPRITE_SLAVE_CONTROL + ISPRITE_SLAVE_WORD_OFFSET, 2);	
		/*
		for (w = 0; w < 1000000; w++)
		{
			*(beurre + (w >> 12)) = w;
			pipo = *(beurre + (w >> 12));
		}
		*/
		sleep(1);
		
		
		i = 0;
		for (yy = 0; yy < sprite_h; yy++)
		{
			verif = (Xuint16 *)(destination + posy * 320 * 2 + posx * 2);
			verif += yy * 320;
			referix = (Xuint16 *)(reference + posy * 320 * 2 + posx * 2);
			referix += yy * 320;
			for (xx = 0; xx < sprite_w; xx++)
			{
				//expected = *(pix + i);
				expected = (*(pix + i) == 0xF81F) ? *referix : *(pix + i);
				if (*verif != expected)
				{
					if (*(pix + i) == 0xF81F)
					{
						xil_printf("transparent ");
					}
					xil_printf("x=%d y=%d read=%04x expected=%04x @%08x\r\n", xx, yy, *verif, expected, (Xuint32)verif);
				}
				verif++;
				referix++;
				i++;
			}
		}
		
		xil_printf("loop %d done\r\n", loop);
	}
	
	while(1);
	
	Xuint16* ptr = (Xuint16*)0x00140000;
	Xuint16 j;
	for (j = 0; j < WIDTH; j++)
	{
		*ptr = j;
		ptr++;
	}
	Xuint32 x, y;
	ptr = (Xuint16*)0x00140000;
	Xuint16 data;
	for (y = 0; y < HEIGHT; y++)
	{
		for (x = 0; x < WIDTH; x++)
		{
			data = ((x & 0xff) << 8) | (y & 0xff);
			*ptr = data;
			ptr++;
		}
	}
	
	init_vga(XPAR_IVGA_0_BASEADDR);
	Xuint32 ba = ivga_read_base_address();
	Xuint32 cont = ivga_read_control_reg();
	xil_printf("base adress=%08x\r\n", ba);
	xil_printf("control reg=%08x\r\n", cont);
	ivga_write_base_address(0x00140000);
	ba = ivga_read_base_address();
	cont = ivga_read_control_reg();
	xil_printf("base adress=%08x\r\n", ba);
	xil_printf("control reg=%08x\r\n", cont);
	ivga_mode640();
	ivga_on();
	//ivga_activate_interrupt();
	cont = ivga_read_control_reg();
	xil_printf("control reg=%08x\r\n", cont);
	//ivga_on();
	
	
	for (x = 0; x < WIDTH; x++)
	{
		set_pixel(x, 0, 0xff, 0, 0);
		set_pixel(x, HEIGHT-1, 0, 0xff, 0);
	}
	for (x = 0; x < HEIGHT; x++)
	{
		set_pixel(0, x, 0, 0, 0xff);
		set_pixel(WIDTH-1, x, 0xff, 0xff, 0xff);
	}
	
	
	xil_printf("End init of graphic buffer.\r\n");

	xil_printf("Ca marche toujours (on croise les doigts...)\r\n");
	while(1)
	{
	}
}
