/*
 * Yggdrasil Operating System
 * $Id: asm.h,v 1.1.1.1 2006-03-31 19:01:34 root Exp $
 */

/*
 * Assembly constants, macros and functions
 */

#ifndef ASM /* prevent circular inclusions */
#define ASM /* by using protection macros */


/** include xilinx's macros */
#include "xpseudo_asm_gcc.h"



#define mfcr(rn)    __asm__ __volatile__(\
                          "mfcr " stringify(rn) "\n"\
                        )

#define mtcr(rn)    __asm__ __volatile__(\
                          "mtcr " stringify(rn) "\n"\
                        )
#define mfsrr0(rn)    __asm__ __volatile__(\
                          "mfsrr0 " stringify(rn) "\n"\
                        )
#define mtsrr0(rn)    __asm__ __volatile__(\
                          "mtsrr0 " stringify(rn) "\n"\
                        )
#define mfsrr1(rn)    __asm__ __volatile__(\
                          "mfsrr1 " stringify(rn) "\n"\
                        )
#define mtsrr1(rn)    __asm__ __volatile__(\
                          "mtsrr1 " stringify(rn) "\n"\
                        )
#define mfesr(rn)    __asm__ __volatile__(\
                          "mfesr " stringify(rn) "\n"\
                        )






#endif            /* end of protection macro */
