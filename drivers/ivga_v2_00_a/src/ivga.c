//////////////////////////////////////////////////////////////////////////////
// Filename:          ivga.c
// Version:           1.00.a
// Description:       IVGA driver implementation
// Date:              2007/02/11
// Author:            Matthieu GUILLEMOT (g@npng.org)
//////////////////////////////////////////////////////////////////////////////

#include "ivga.h"
#include "xbasic_types.h"

// address blocks
#define IVGA_REGISTERS_BLOCK        0
#define IVGA_INSTANCES_BLOCK        (1 << 15)
#define IVGA_SPRITE_BLOCK           (1 << 16)

// registers
#define IVGA_BASE_ADDRESS_REG       0x00
#define IVGA_CONTROL_REG            0x04
#define IVGA_VALIDATE_INSTANCES_REG 0x08
#define IVGA_LAST_INSTANCE_REG      0x0C

// helper macros

#define ivga_write_control_reg(data) \
	XIo_Out32(ivga_base_add + IVGA_REGISTERS_BLOCK + IVGA_CONTROL_REG, data)

#define ivga_write_base_address(data) \
	XIo_Out32(ivga_base_add + IVGA_REGISTERS_BLOCK + IVGA_BASE_ADDRESS_REG, data)

#define ivga_write_validate_instances_reg(data) \
	XIo_Out32(ivga_base_add + IVGA_REGISTERS_BLOCK + IVGA_VALIDATE_INSTANCES_REG, data)

#define ivga_read_control_reg() \
	XIo_In32(ivga_base_add + IVGA_REGISTERS_BLOCK + IVGA_CONTROL_REG)

#define ivga_write_last_instance_reg(data) \
	XIo_Out32(ivga_base_add + IVGA_REGISTERS_BLOCK + IVGA_LAST_INSTANCE_REG, data)

#define ivga_read_base_address() \
	XIo_In32(ivga_base_add + IVGA_REGISTERS_BLOCK + IVGA_BASE_ADDRESS_REG)

// circuit base address

Xuint32 ivga_base_add;

void ivga_init(Xuint32 base_add)
{
  ivga_base_add = base_add;
}

// register access

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

Xuint32 ivga_get_framebuffer()
{
	return ivga_read_base_address();
}

void ivga_set_framebuffer(Xuint32 data)
{
	ivga_write_base_address(data);
}

void ivga_activate_instances()
{
	Xuint32 control = ivga_read_control_reg();
	control |= 0x00000008;
	ivga_write_control_reg(control);
}

void ivga_desactivate_instances()
{
	Xuint32 control = ivga_read_control_reg();
	control &= 0xfffffff7;
	ivga_write_control_reg(control);
}

void ivga_validate_instances()
{
	ivga_write_validate_instances_reg(1);
}

void ivga_last_instance(Xuint32 number)
{
	ivga_write_last_instance_reg(number);
}

// instances functions

void ivga_set_instance(Xuint32 instance, Xuint8 sprite, Xint16 x, Xint16 y)
{
	Xuint32 v = 0;
	v |= (sprite & 0x3f) << 20;
	v |= (x & 0x3ff) << 10;
	v |= (y & 0x3ff);
	Xuint32 addr = ivga_base_add + IVGA_INSTANCES_BLOCK;
	addr += (instance & 0xfff) << 2;
	XIo_Out32(addr, v);
}

// sprite data functions

void ivga_write_sprite_data(Xuint8 sprite, Xuint8 sx, Xuint8 sy, Xuint16 color)
{
	Xuint32 addr = ivga_base_add + IVGA_SPRITE_BLOCK;
	addr |= (sy & 0xf) << 2;
	addr |= (sx & 0xf) << 6;
	addr |= (sprite & 0x3f) << 10;
	XIo_Out16(addr, color);
}

// utility functions

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
