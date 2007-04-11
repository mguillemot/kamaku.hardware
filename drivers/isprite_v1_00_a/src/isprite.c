//////////////////////////////////////////////////////////////////////////////
// Filename:          isprite.c
// Version:           1.00.a
// Description:       Isprite driver implementation
// Date:              2007/03/27
// Author:            Matthieu GUILLEMOT (g@npng.org)
//////////////////////////////////////////////////////////////////////////////

#include <xio.h>
#include "isprite.h"

#define ISPRITE_SLAVE_CONTROL      0x00
#define ISPRITE_SLAVE_SOURCE       0x08
#define ISPRITE_SLAVE_FRAMEBUFFER  0x10
#define ISPRITE_SLAVE_SPRITE_SIZE  0x18
#define ISPRITE_SLAVE_SPRITE_COORD 0x20
#define ISPRITE_SLAVE_WORD_OFFSET  0x04

Xuint32 isprite_baseaddr;

// Helper functions

#define isprite_write_control(base, data) \
	XIo_Out32(base + ISPRITE_SLAVE_CONTROL + ISPRITE_SLAVE_WORD_OFFSET, data);

#define isprite_read_control(base) \
	XIo_In32(base + ISPRITE_SLAVE_CONTROL + ISPRITE_SLAVE_WORD_OFFSET);

#define isprite_write_source(base, data) \
	XIo_Out32(base + ISPRITE_SLAVE_SOURCE + ISPRITE_SLAVE_WORD_OFFSET, data);

#define isprite_read_source(base) \
	XIo_In32(base + ISPRITE_SLAVE_SOURCE + ISPRITE_SLAVE_WORD_OFFSET);

#define isprite_write_framebuffer(base, data) \
	XIo_Out32(base + ISPRITE_SLAVE_FRAMEBUFFER + ISPRITE_SLAVE_WORD_OFFSET, data);

#define isprite_read_framebuffer(base) \
	XIo_In32(base + ISPRITE_SLAVE_FRAMEBUFFER + ISPRITE_SLAVE_WORD_OFFSET);

#define isprite_write_sprite_coord(base, data) \
	XIo_Out32(base + ISPRITE_SLAVE_SPRITE_COORD + ISPRITE_SLAVE_WORD_OFFSET, data);

#define isprite_read_sprite_coord(base) \
	XIo_In32(base + ISPRITE_SLAVE_SPRITE_COORD + ISPRITE_SLAVE_WORD_OFFSET);

#define isprite_write_sprite_size(base, data) \
	XIo_Out32(base + ISPRITE_SLAVE_SPRITE_SIZE + ISPRITE_SLAVE_WORD_OFFSET, data);

#define isprite_read_sprite_size(base) \
	XIo_In32(base + ISPRITE_SLAVE_SPRITE_SIZE + ISPRITE_SLAVE_WORD_OFFSET);

// Exported functions

void isprite_init(Xuint32 base)
{
	isprite_baseaddr = base;
}

void isprite_load_sprite(Xuint32 sprite_addr, Xuint16 sprite_w, Xuint16 sprite_h)
{
	Xuint32 sprite_size = (sprite_w << 16) | sprite_h;
	isprite_write_source(isprite_baseaddr, sprite_addr);
	isprite_write_sprite_size(isprite_baseaddr, sprite_size);
	isprite_write_control(isprite_baseaddr, 0x1);
}

void isprite_blit_sprite(Xuint32 framebuffer, Xint16 x, Xint16 y)
{
	Xuint32 sprite_coord = ((Xuint16)x << 16) | (Xuint16)y;
	isprite_write_framebuffer(isprite_baseaddr, framebuffer);
	isprite_write_sprite_coord(isprite_baseaddr, sprite_coord);
	isprite_write_control(isprite_baseaddr, 0x2);
}
