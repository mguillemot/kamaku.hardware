//////////////////////////////////////////////////////////////////////////////
// Filename:          isprite.h
// Version:           1.00.a
// Description:       Isprite driver main header file
// Date:              2007/03/27
// Author:            Matthieu GUILLEMOT (g@npng.org)
//////////////////////////////////////////////////////////////////////////////

#ifndef ISPRITE_H
#define ISPRITE_H

#include "xbasic_types.h"

#ifdef __cplusplus
extern "C" {
#endif

// Exported functions

extern void isprite_init(Xuint32 base);

extern void isprite_load_sprite(Xuint32 sprite_addr, Xuint16 sprite_w, Xuint16 sprite_h);

extern void isprite_blit_sprite(Xuint32 framebuffer, Xint16 x, Xint16 y);

#ifdef __cplusplus
}
#endif

#endif // ISPRITE_H
