//////////////////////////////////////////////////////////////////////////////
// Filename:          isuperdma.h
// Version:           1.00.a
// Description:       ISUPERDMA driver main header file
// Date:              2007/03/17
// Author:            Matthieu GUILLEMOT (g@npng.org)
//////////////////////////////////////////////////////////////////////////////

#ifndef ISUPERDMA_H
#define ISUPERDMA_H

#include "xbasic_types.h"

// Screen parameters

#define ISUPERDMA_SCREEN_WIDTH      320
#define ISUPERDMA_SCREEN_HEIGHT     240
#define ISUPERDMA_SCREEN_BPP        2

// Exported functions

#ifdef __cplusplus
extern "C" {
#endif

extern void isuperdma_init(Xuint32 baseaddr);

extern void isuperdma_blit(
	Xuint32 sprite_addr,
	Xuint16 sprite_w,
	Xuint16 section_x,
	Xuint16 section_y,
	Xuint16 section_w,
	Xuint16 section_h,
	Xuint32 framebuffer,
	Xuint16 x,
	Xuint16 y
);

#ifdef __cplusplus
}
#endif

#endif // ISUPERDMA_H
