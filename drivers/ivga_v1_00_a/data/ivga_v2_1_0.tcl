##############################################################################
## Filename:          C:\IGAM\testing_system_vga/drivers/ivga_v1_00_a/data/ivga_v2_1_0.tcl
## Description:       Microprocess Driver Command (tcl)
## Date:              Fri Feb 02 14:50:13 2007 (by Create and Import Peripheral Wizard)
##############################################################################

#uses "xillib.tcl"

proc generate {drv_handle} {
  xdefine_include_file $drv_handle "xparameters.h" "ivga" "NUM_INSTANCES" "DEVICE_ID" "C_BASEADDR" "C_HIGHADDR" 
}
