//////////////////////////////////////////////////////////////////////////////
// Filename:          isuperdma.c
// Version:           1.00.a
// Description:       ISUPERDMA driver implementation
// Date:              2007/03/17
// Author:            Matthieu GUILLEMOT (g@npng.org)
//////////////////////////////////////////////////////////////////////////////

#include <xio.h>
#include "isuperdma.h"

Xuint32 isuperdma_baseaddr;

#define ISUPERDMA_CONTROL_SKIP      0x00
#define ISUPERDMA_SOURCE            0x08
#define ISUPERDMA_DESTINATION       0x10
#define ISUPERDMA_SIZE              0x18
#define ISUPERDMA_SLAVE_WORD_OFFSET 0x04

#define isuperdma_write_control_skip(base, data) \
	XIo_Out32(base + ISUPERDMA_CONTROL_SKIP + ISUPERDMA_SLAVE_WORD_OFFSET, data)

#define isuperdma_read_control_skip(base) \
	XIo_In32(base + ISUPERDMA_CONTROL_SKIP + ISUPERDMA_SLAVE_WORD_OFFSET)

#define isuperdma_write_source(base, data) \
	XIo_Out32(base + ISUPERDMA_SOURCE + ISUPERDMA_SLAVE_WORD_OFFSET, data)

#define isuperdma_read_source(base) \
	XIo_In32(base + ISUPERDMA_SOURCE + ISUPERDMA_SLAVE_WORD_OFFSET)

#define isuperdma_write_destination(base, data) \
	XIo_Out32(base + ISUPERDMA_DESTINATION + ISUPERDMA_SLAVE_WORD_OFFSET, data)

#define isuperdma_read_destination(base) \
	XIo_In32(base + ISUPERDMA_DESTINATION + ISUPERDMA_SLAVE_WORD_OFFSET)

#define isuperdma_write_size(base, data) \
	XIo_Out32(base + ISUPERDMA_SIZE + ISUPERDMA_SLAVE_WORD_OFFSET, data)

#define isuperdma_read_size(base) \
	XIo_In32(base + ISUPERDMA_SIZE + ISUPERDMA_SLAVE_WORD_OFFSET)

void isuperdma_init(Xuint32 baseaddr)
{
	isuperdma_baseaddr = baseaddr;
}

void isuperdma_blit(Xuint32 sprite_addr, Xuint16 sprite_w, Xuint16 section_x, Xuint16 section_y, Xuint16 section_w, Xuint16 section_h, Xuint32 framebuffer, Xuint16 x, Xuint16 y)
{
	Xuint32 source = sprite_addr;
	source += ISUPERDMA_SCREEN_BPP * section_x;
	source += ISUPERDMA_SCREEN_BPP * sprite_w * section_y;
	Xuint32 destination = framebuffer;
	destination += ISUPERDMA_SCREEN_BPP * x;
	destination += ISUPERDMA_SCREEN_BPP * ISUPERDMA_SCREEN_WIDTH * y;
	Xuint32 size = (section_w << 16) | section_h;
	Xuint32 control = (sprite_w << 16) | 1;
	isuperdma_write_source(isuperdma_baseaddr, source);
	isuperdma_write_destination(isuperdma_baseaddr, destination);
	isuperdma_write_size(isuperdma_baseaddr, size);
	isuperdma_write_control_skip(isuperdma_baseaddr, control);
}

