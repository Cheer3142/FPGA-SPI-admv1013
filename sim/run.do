##
quit -sim
vlib work

#--------------------------------#
#--      Compile Source        --#
#--------------------------------#
vcom -work work ../hdl/SPICom.vhd

#--------------------------------#
#--     Compile Test Bench     --#
#--------------------------------#
vcom -work work ../Testbench/TbSPI.vhd

vsim -t 100ps -novopt work.TbSPI
view wave

do wave.do

view structure
view signals

run 500 us	

