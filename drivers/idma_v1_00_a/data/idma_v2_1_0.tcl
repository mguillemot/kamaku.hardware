##############################################################################
## Filename:          /home/teixeiro/igam/Asgard/drivers/idma_v1_00_a/data/idma_v2_1_0.tcl
## Description:       Microprocess Driver Command (tcl)
## Date:              Mon May 29 16:13:39 2006 (by Create and Import Peripheral Wizard)
##############################################################################

#uses "xillib.tcl"

proc generate {drv_handle} {
  xdefine_include_file $drv_handle "xparameters.h" "idma" "NUM_INSTANCES" "DEVICE_ID" "C_BASEADDR" "C_HIGHADDR" 
}
