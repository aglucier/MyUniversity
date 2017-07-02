#SETUP_PIN.tcl
 # Setup pin setting
 set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"
 set_global_assignment -name ENABLE_INIT_DONE_OUTPUT OFF
 #
   set_location_assignment PIN_A12 -to clk
	set_location_assignment PIN_D19 -to txd[7]
	set_location_assignment PIN_A20 -to txd[6]
	set_location_assignment PIN_G16 -to txd[5]
	set_location_assignment PIN_B19 -to txd[4]
	set_location_assignment PIN_B20 -to txd[3]
	set_location_assignment PIN_A19 -to txd[2]
	set_location_assignment PIN_C19 -to txd[1]
	set_location_assignment PIN_A18 -to txd[0]
	set_location_assignment PIN_B17 -to gtx_clk
	set_location_assignment PIN_C17 -to tx_en
	set_location_assignment PIN_B18 -to tx_er 

