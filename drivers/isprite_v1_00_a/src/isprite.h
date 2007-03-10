//////////////////////////////////////////////////////////////////////////////
// Filename:          isprite.h
// Version:           1.00.a
// Description:       Isprite driver main header file
// Date:              2007/02/24
// Author:            Matthieu GUILLEMOT (g@npng.org)
//////////////////////////////////////////////////////////////////////////////

#ifndef ISPRITE_H
#define ISPRITE_H

#include "xbasic_types.h"

#ifdef __cplusplus
extern "C" {
#endif

// Load designated sprite into isprite
extern void isprite_load_sprite(Xuint32 base, Xuint32 sprite_addr, Xuint16 sprite_w, Xuint16 sprite_h);

#ifdef __cplusplus
}
#endif

#endif // ISPRITE_H
