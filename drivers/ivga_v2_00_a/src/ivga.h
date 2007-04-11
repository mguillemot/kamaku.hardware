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
extern Xuint32 ivga_get_framebuffer();
extern void    ivga_set_framebuffer(Xuint32 data);

// Turn IVGA on/off
extern void ivga_on();
extern void ivga_off(); // (default)

// Turn IVGA interrupt at the end of frame on/off
extern void ivga_activate_interrupt();
extern void ivga_desactivate_interrupt(); // (default)

// Turn instances calculation on/off
extern void ivga_activate_instances();
extern void ivga_desactivate_instances(); // (default)

// Validate the written instances
extern void ivga_validate_instances();

// Set the number of valid instances
extern void ivga_last_instance(Xuint32 number);

// Write instance data into VGA
extern void ivga_set_instance(Xuint32 instance, Xuint8 sprite, Xint16 x, Xint16 y);

// Write sprite data into VGA
extern void ivga_write_sprite_data(Xuint8 sprite, Xuint8 sx, Xuint8 sy, Xuint16 color);

// Utility functions
extern Xuint16 ivga_create_color_from_rgb(Xuint8 r, Xuint8 g, Xuint8 b);
extern Xuint16 ivga_create_color_from_truecolor(Xuint32 truecolor);
extern void    ivga_set_pixel(Xuint32 framebuffer, Xuint32 x, Xuint32 y, Xuint16 color);
extern Xuint16 ivga_get_pixel(Xuint32 framebuffer, Xuint32 x, Xuint32 y);
extern void    ivga_fill_screen(Xuint32 framebuffer, Xuint16 color);

#ifdef __cplusplus
}
#endif

#endif // IVGA_H
