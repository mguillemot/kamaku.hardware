//////////////////////////////////////////////////////////////////////////////
// Filename:          ivga.h
// Version:           1.00.a
// Description:       IVGA driver main header file
// Date:              2007/02/11
// Author:            Matthieu GUILLEMOT (g@npng.org)
//////////////////////////////////////////////////////////////////////////////

#ifndef IVGA_H
#define IVGA_H

#include "xbasic_types.h"

extern Xuint32 ivga_base_add;

// Init function to be called before everything else
extern void init_vga(Xuint32 base_add);

// Get/Set framebuffer base address
extern Xuint32 ivga_read_base_address();
extern void ivga_write_base_address(Xuint32 data);

// Turn IVGA on/off
extern void ivga_on();
extern void ivga_off(); // (default)

// Turn IVGA interrupt at the end of frame on/off
extern void ivga_activate_interrupt();
extern void ivga_desactivate_interrupt(); // (default)

// Turn CGA emulation on VGA on/off
extern void ivga_mode640();
extern void ivga_mode320(); // (default)

#endif // IVGA_H
