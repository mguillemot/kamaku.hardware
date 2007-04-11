//////////////////////////////////////////////////////////////////////////////
// Filename:          ivga.c
// Version:           1.00.a
// Description:       IVGA driver implementation
// Date:              2007/02/11
// Author:            Matthieu GUILLEMOT (g@npng.org)
//////////////////////////////////////////////////////////////////////////////

#include "ivga.h"
#include "xbasic_types.h"

#define IVGA_SLAVE_BASE_ADDRESS 0x00000000
#define IVGA_SLAVE_CONTROL_REG 0x00000008
#define IVGA_SLAVE_WORD_OFFSET 0x00000004

Xuint32 ivga_base_add;

void ivga_init(Xuint32 base_add)
{
  ivga_base_add = base_add;
}

void ivga_write_control_reg(Xuint32 data)
{
	XIo_Out32(ivga_base_add + IVGA_SLAVE_CONTROL_REG + IVGA_SLAVE_WORD_OFFSET, data);
}

void ivga_write_base_address(Xuint32 data)
{
	XIo_Out32(ivga_base_add + IVGA_SLAVE_BASE_ADDRESS + IVGA_SLAVE_WORD_OFFSET, data);
}

Xuint32 ivga_read_control_reg()
{
	return XIo_In32(ivga_base_add + IVGA_SLAVE_CONTROL_REG + IVGA_SLAVE_WORD_OFFSET);
}

Xuint32 ivga_read_base_address()
{
	return XIo_In32(ivga_base_add + IVGA_SLAVE_BASE_ADDRESS + IVGA_SLAVE_WORD_OFFSET);
}

void ivga_on()
{
	Xuint32 control = ivga_read_control_reg();
	control |= 0x00000001;
	ivga_write_control_reg(control);
}

void ivga_off()
{
	Xuint32 control = ivga_read_control_reg();
	control &= 0xfffffffe;
	ivga_write_control_reg(control);
}

void ivga_activate_interrupt()
{
	Xuint32 control = ivga_read_control_reg();
	control |= 0x00000002;
	ivga_write_control_reg(control);
}

void ivga_desactivate_interrupt()
{
	Xuint32 control = ivga_read_control_reg();
	control &= 0xfffffffd;
	ivga_write_control_reg(control);
}

void ivga_mode640()
{
	Xuint32 control = ivga_read_control_reg();
	control |= 0x00000004;
	ivga_write_control_reg(control);
}

void ivga_mode320()
{
	Xuint32 control = ivga_read_control_reg();
	control &= 0xfffffffb;
	ivga_write_control_reg(control);
}

Xuint16 ivga_create_color_from_rgb(Xuint8 r, Xuint8 g, Xuint8 b)
{
	Xuint16 color;
	r >>= 3;
	g >>= 2;
	b >>= 3;
	color = (r << 11) | (g << 5) | b;
	return color;
}

Xuint16 ivga_create_color_from_truecolor(Xuint32 truecolor)
{
	Xuint16 color;
	Xuint32 r = (truecolor >> 16) & 0xff;
	Xuint32 g = (truecolor >> 8) & 0xff;
	Xuint32 b = truecolor & 0xff;
	r >>= 3;
	g >>= 2;
	b >>= 3;
	color = (r << 11) | (g << 5) | b;
	return color;
}

void ivga_set_pixel(Xuint32 framebuffer, Xuint32 x, Xuint32 y, Xuint16 color)
{
	Xuint16* addr = (Xuint16*)framebuffer;
	addr += IVGA_SCREEN_WIDTH * y + x;
	*addr = color;
}

Xuint16 ivga_get_pixel(Xuint32 framebuffer, Xuint32 x, Xuint32 y)
{
	Xuint16* addr = (Xuint16*)framebuffer;
	addr += IVGA_SCREEN_WIDTH * y + x;
	return *addr;
}

void ivga_fill_screen(Xuint32 framebuffer, Xuint16 color)
{
	Xint32 x, y;
	for (y = 0; y < IVGA_SCREEN_HEIGHT; y++)
	{
		for (x = 0; x < IVGA_SCREEN_WIDTH; x++)
		{
			ivga_set_pixel(framebuffer, x, y, color);
		}
	}
}
