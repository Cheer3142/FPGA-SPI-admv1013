##
quit -sim
vlib work

#--------------------------------#
#--      Compile Source        --#
#--------------------------------#
vcom -work work ../hdl/SPICom.vhd
vcom -work work ../hdl/RdAddrLst.vhd
vcom -work work ../hdl/PortMapModule.vhd

#--------------------------------#
#--     Compile Test Bench     --#
#--------------------------------#
vcom -work work ../Testbench/TbSPI_RdAddr.vhd

vsim -t 100ps -novopt work.TbSPI
view wave

do wave.do

view structure
view signals

run 5000 us	

