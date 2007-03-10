//////////////////////////////////////////////////////////////////////////////
// Filename:          /home/teixeiro/igam/ConsoleVlin/drivers/Zoga_v1_00_a/src/Zoga.c
// Version:           1.00.a
// Description:       Zoga Driver Source File
// Date:              Sun Apr 23 20:59:48 2006 (by Create and Import Peripheral Wizard)
//////////////////////////////////////////////////////////////////////////////


/***************************** Include Files *******************************/

#include "idma.h"

/************************** Function Definitions ***************************/


Xuint32 idma_base_add;

void init_dma(Xuint32 base_add){
  idma_base_add = base_add;
}

void idma_write_control_reg(Xuint32 data) {
  XIo_Out32(idma_base_add + IDMA_SLAVE_CONTROL_REG + IDMA_SLAVE_WORD_OFFSET,data);
}

void idma_write_sa_reg(Xuint32 data){
  XIo_Out32(idma_base_add + IDMA_SLAVE_SA_REG + IDMA_SLAVE_WORD_OFFSET,data);
}

void idma_write_length_reg(Xuint32 data){
  XIo_Out32(idma_base_add + IDMA_SLAVE_LENGTH_REG + IDMA_SLAVE_WORD_OFFSET,data);
}

void idma_write_da_reg(Xuint32 data){
  XIo_Out32(idma_base_add + IDMA_SLAVE_DA_REG + IDMA_SLAVE_WORD_OFFSET,data);
}

Xuint32 idma_read_control_reg(){
  return  XIo_In32(idma_base_add +  IDMA_SLAVE_CONTROL_REG + IDMA_SLAVE_WORD_OFFSET);
}

Xuint32 idma_read_sa_reg(){
  return  XIo_In32(idma_base_add +  IDMA_SLAVE_SA_REG + IDMA_SLAVE_WORD_OFFSET);
}

Xuint32 idma_read_length_reg(){
  return  XIo_In32(idma_base_add +  IDMA_SLAVE_LENGTH_REG + IDMA_SLAVE_WORD_OFFSET);
}

Xuint32 idma_read_da_reg(){
  return  XIo_In32(idma_base_add +  IDMA_SLAVE_DA_REG + IDMA_SLAVE_WORD_OFFSET);
}


Xuint32 idma_is_ready(){
  return (idma_read_control_reg() == IDMA_READY);
}

Xuint32 idma_asynchrone_request(void * sa, void * da, Xuint32 length){

  Xuint32 i;

  if (!idma_is_ready())
    return -1;

  if( ((Xuint32)sa % 4) || ((Xuint32)da % 4))
    return -1;

  if((Xuint32)sa % 8){
    if ((Xuint32)da % 8) {
      *(Xuint32*)da = *(Xuint32*)sa;
      sa+=4;
      da+=4;
    }
    else
      return -1;
  }
  else if((Xuint32)da % 8)
    return -3;

  for(i = length; i > (length + (length % 8));i++) {
    *((Xuint8*)da+i) = *((Xuint8*)sa+i);
  }
  length -= length % 8;

  idma_write_sa_reg((Xuint32)sa);
  idma_write_da_reg((Xuint32)da);
  idma_write_length_reg((Xuint32)length);
  idma_write_control_reg((Xuint32)IDMA_REQ_INT);

  return 0;
}

Xuint32 idma_synchrone_request(void * sa, void * da, Xuint32 length){

  Xuint32 i;


  if (!idma_is_ready())
    return -1;

  if(((Xuint32)sa % 4) || ((Xuint32)da % 4))
    return -1;

  if((Xuint32)sa % 8){
    if ((Xuint32)da % 8) {
      *(Xuint32*)da = *(Xuint32*)sa;
      sa+=4;
      da+=4;
    }
    else
      return -2;
  }
  else if((Xuint32)da % 8)
    return -3;

  for(i = length; i > (length + (length % 8));i++) {
    *((Xuint8 *)da+i) = *((Xuint8*)sa+i);
  }
  length -= length % 8;

  idma_write_sa_reg((Xuint32)sa);
  idma_write_da_reg((Xuint32)da);
  idma_write_length_reg((Xuint32)length);
  idma_write_control_reg((Xuint32)IDMA_REQ_INT);

  while(!idma_is_ready());
  //sleep(5);
  return 0;
}

void idma_ack_interrupt() {
  idma_write_control_reg((Xuint32)IDMA_ACK_INT);
}
