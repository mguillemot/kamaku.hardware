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

#define IVGA_SCREEN_WIDTH  320
#define IVGA_SCREEN_HEIGHT 240

#ifdef __cplusplus
extern "C" {
#endif

// Init function to be called before everything else
extern void ivga_init(Xuint32 base_add);

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

// Utility functions
extern Xuint16 ivga_create_color_from_rgb(Xuint8 r, Xuint8 g, Xuint8 b);
extern Xuint16 ivga_create_color_from_truecolor(Xuint32 truecolor);
extern void ivga_set_pixel(Xuint32 framebuffer, Xuint32 x, Xuint32 y, Xuint16 color);
extern Xuint16 ivga_get_pixel(Xuint32 framebuffer, Xuint32 x, Xuint32 y);
extern void ivga_fill_screen(Xuint32 framebuffer, Xuint16 color);

#ifdef __cplusplus
}
#endif

#endif // IVGA_H
