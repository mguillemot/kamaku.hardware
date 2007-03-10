/*
 * Yggdrasil Operating System
 * $Id: asm.S,v 1.1.1.1 2006-03-31 19:01:34 root Exp $
 */

/*
 * Assembly functions
 */


#include "ppc_asm.tmpl"


/*
 * Disable interrupts - like an 80x86
 *	cli()
 */
_GLOBAL(cli)
	mfmsr	r0		/* Get current interrupt state */
	rlwinm	r3,r0,16+1,32-1,31	/* Extract old value of 'EE' */
	li	r4,0		/* Need [unsigned] value of MSR_EE */
	ori	r4,r4,MSR_EE	/* Set to turn off bit */
	andc	r0,r0,r4	/* Clears bit in (r4) */
	sync			/* Some chip revs have problems here... */
	mtmsr	r0		/* Update machine state */
	blr			/* Done */
	
/*
 * Enable interrupts - like an 80x86
 *	sti()
 */
_GLOBAL(sti)
	mfmsr	r0		/* Get current state */
	ori	r0,r0,MSR_EE	/* Turn on 'EE' bit */
	sync			/* Some chip revs have problems here... */
	mtmsr	r0		/* Update machine state */
	blr



_GLOBAL(asm_idle)
	idle_loop:
	b idle_loop
	blr

