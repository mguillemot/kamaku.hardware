//////////////////////////////////////////////////////////////////////////////
// Filename:          ivga.c
// Version:           1.00.a
// Description:       IVGA driver implementation
// Date:              2007/02/11
// Author:            Matthieu GUILLEMOT (g@npng.org)
//////////////////////////////////////////////////////////////////////////////

#include "isprite.h"
#include "xbasic_types.h"

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

// Exported functions

void isprite_load_sprite(Xuint32 base, Xuint32 sprite_addr, Xuint16 sprite_w, Xuint16 sprite_h)
{
	Xuint32 sprite_size = (sprite_w << 16) | sprite_h;
	isprite_write_source(base, sprite_addr);
	isprite_write_sprite_size(base, sprite_size);
	isprite_write_control(base, 0x00000001);
}
