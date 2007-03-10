//////////////////////////////////////////////////////////////////////////////
// Filename:          /home/teixeiro/igam/ConsoleVlin/drivers/Zoga_v1_00_a/src/Zoga.h
// Version:           1.00.a
// Description:       Zoga Driver Header File
// Date:              Sun Apr 23 20:59:48 2006 (by Create and Import Peripheral Wizard)
//////////////////////////////////////////////////////////////////////////////

#ifndef IDMA_H
#define IDMA_H

/***************************** Include Files *******************************/

#include "xbasic_types.h"
#include "xstatus.h"
#include "xio.h"
/************************** Constant Definitions ***************************/


/**
 * User Logic Slave Space Offsets
 * -- SLAVE_REG0 : user logic slave module register 0
 * -- SLAVE_REG1 : user logic slave module register 1
 * -- SLAVE_REG2 : user logic slave module register 2
 * -- SLAVE_REG3 : user logic slave module register 3
 */
#define IDMA_SLAVE_CONTROL_REG 0x00000000
#define IDMA_SLAVE_SA_REG 0x00000008
#define IDMA_SLAVE_LENGTH_REG 0x00000010
#define IDMA_SLAVE_DA_REG 0x00000018
#define IDMA_SLAVE_WORD_OFFSET 0x00000004

#define IDMA_READY 0xABCDEF00

#define IDMA_REQ 0x00000001
#define IDMA_REQ_INT 0x00000003
#define IDMA_ACK_INT 0x12345678


extern Xuint32 idma_base_add;

extern void init_dma(Xuint32 base_add);

extern void idma_write_control_reg(Xuint32 data);
extern void idma_write_sa_reg(Xuint32 data);
extern void idma_write_length_reg(Xuint32 data);
extern void idma_write_da_reg(Xuint32 data);

extern Xuint32 idma_read_control_reg();
extern Xuint32 idma_read_sa_reg();
extern Xuint32 idma_read_length_reg();
extern Xuint32 idma_read_da_reg();


extern Xuint32 idma_is_ready();

extern Xuint32 idma_asynchrone_request(void * sa, void * da, Xuint32 length);
extern Xuint32 idma_synchrone_request(void * sa, void * da, Xuint32 length);

extern void idma_ack_interrupt();



#endif // IDMA_H
