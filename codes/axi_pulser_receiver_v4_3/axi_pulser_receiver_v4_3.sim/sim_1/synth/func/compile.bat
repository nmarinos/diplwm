@echo off
rem  Vivado(TM)
rem  compile.bat: a Vivado-generated XSim simulation Script
rem  Copyright 1986-1999, 2001-2013 Xilinx, Inc. All Rights Reserved.

set PATH=%XILINX%\lib\%PLATFORM%;%XILINX%\bin\%PLATFORM%;C:/Xilinx/SDK/2013.3/bin/nt64;C:/Xilinx/Vivado/2013.3/ids_lite/EDK/bin/nt64;C:/Xilinx/Vivado/2013.3/ids_lite/EDK/lib/nt64;C:/Xilinx/Vivado/2013.3/ids_lite/ISE/bin/nt64;C:/Xilinx/Vivado/2013.3/ids_lite/ISE/lib/nt64;C:/Xilinx/Vivado/2013.3/bin;%PATH%
set XILINX_PLANAHEAD=C:/Xilinx/Vivado/2013.3

xelab -m64 --debug typical --relax -L work -L secureip --snapshot tb_top_lvl_func_synth --prj C:/Users/nikolaos.marinos/xil_IP_projects/axi_pulser_receiver_v4/axi_pulser_receiver_v4.sim/sim_1/synth/func/tb_top_lvl.prj   work.tb_top_lvl
if errorlevel 1 (
   cmd /c exit /b %errorlevel%
)
