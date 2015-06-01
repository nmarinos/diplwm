#Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
	set Page0 [ ipgui::add_page $IPINST  -name "Page 0" -layout vertical]
	set Component_Name [ ipgui::add_param  $IPINST  -parent  $Page0  -name Component_Name ]
	set USE_FRAME [ipgui::add_param $IPINST -parent $Page0 -name USE_FRAME]
	set FREQ_DIV_BITS [ipgui::add_param $IPINST -parent $Page0 -name FREQ_DIV_BITS ]
	set DATA_NUM_BITS [ipgui::add_param $IPINST -parent $Page0 -name DATA_NUM_BITS ]
	set OFFSET_BITS [ipgui::add_param $IPINST -parent $Page0 -name OFFSET_BITS ]
	set PATTERN_BITS [ipgui::add_param $IPINST -parent $Page0 -name PATTERN_BITS ]
	set CHANNELS [ipgui::add_param $IPINST -parent $Page0 -name CHANNELS ]
}

proc update_PARAM_VALUE.USE_FRAME { PARAM_VALUE.USE_FRAME } {
	# Procedure called to update USE_FRAME when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.USE_FRAME { PARAM_VALUE.USE_FRAME } {
	# Procedure called to validate USE_FRAME
	return true
}

proc update_PARAM_VALUE.FREQ_DIV_BITS { PARAM_VALUE.FREQ_DIV_BITS } {
	# Procedure called to update FREQ_DIV_BITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FREQ_DIV_BITS { PARAM_VALUE.FREQ_DIV_BITS } {
	# Procedure called to validate FREQ_DIV_BITS
	return true
}

proc update_PARAM_VALUE.DATA_NUM_BITS { PARAM_VALUE.DATA_NUM_BITS } {
	# Procedure called to update DATA_NUM_BITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_NUM_BITS { PARAM_VALUE.DATA_NUM_BITS } {
	# Procedure called to validate DATA_NUM_BITS
	return true
}

proc update_PARAM_VALUE.OFFSET_BITS { PARAM_VALUE.OFFSET_BITS } {
	# Procedure called to update OFFSET_BITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OFFSET_BITS { PARAM_VALUE.OFFSET_BITS } {
	# Procedure called to validate OFFSET_BITS
	return true
}

proc update_PARAM_VALUE.PATTERN_BITS { PARAM_VALUE.PATTERN_BITS } {
	# Procedure called to update PATTERN_BITS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PATTERN_BITS { PARAM_VALUE.PATTERN_BITS } {
	# Procedure called to validate PATTERN_BITS
	return true
}

proc update_PARAM_VALUE.CHANNELS { PARAM_VALUE.CHANNELS } {
	# Procedure called to update CHANNELS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CHANNELS { PARAM_VALUE.CHANNELS } {
	# Procedure called to validate CHANNELS
	return true
}


proc update_MODELPARAM_VALUE.CHANNELS { MODELPARAM_VALUE.CHANNELS PARAM_VALUE.CHANNELS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CHANNELS}] ${MODELPARAM_VALUE.CHANNELS}
}

proc update_MODELPARAM_VALUE.PATTERN_BITS { MODELPARAM_VALUE.PATTERN_BITS PARAM_VALUE.PATTERN_BITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PATTERN_BITS}] ${MODELPARAM_VALUE.PATTERN_BITS}
}

proc update_MODELPARAM_VALUE.OFFSET_BITS { MODELPARAM_VALUE.OFFSET_BITS PARAM_VALUE.OFFSET_BITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OFFSET_BITS}] ${MODELPARAM_VALUE.OFFSET_BITS}
}

proc update_MODELPARAM_VALUE.DATA_NUM_BITS { MODELPARAM_VALUE.DATA_NUM_BITS PARAM_VALUE.DATA_NUM_BITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_NUM_BITS}] ${MODELPARAM_VALUE.DATA_NUM_BITS}
}

proc update_MODELPARAM_VALUE.FREQ_DIV_BITS { MODELPARAM_VALUE.FREQ_DIV_BITS PARAM_VALUE.FREQ_DIV_BITS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FREQ_DIV_BITS}] ${MODELPARAM_VALUE.FREQ_DIV_BITS}
}

proc update_MODELPARAM_VALUE.USE_FRAME { MODELPARAM_VALUE.USE_FRAME PARAM_VALUE.USE_FRAME } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.USE_FRAME}] ${MODELPARAM_VALUE.USE_FRAME}
}

