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

void init_vga(Xuint32 base_add)
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
