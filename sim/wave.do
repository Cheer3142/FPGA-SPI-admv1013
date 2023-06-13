onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tbspi/TM
add wave -noupdate /tbspi/u_SPICom/rState
add wave -noupdate /tbspi/u_RdAddrLst/rState
add wave -noupdate /tbspi/RstB
add wave -noupdate /tbspi/Clk
add wave -noupdate /tbspi/Address
add wave -noupdate /tbspi/RdWr
add wave -noupdate /tbspi/RdDataEn
add wave -noupdate -radix hexadecimal /tbspi/RdData
add wave -noupdate /tbspi/Parload
add wave -noupdate /tbspi/Busy
add wave -noupdate /tbspi/SClk
add wave -noupdate -radix unsigned /tbspi/u_SPICom/rBuadCnt
add wave -noupdate /tbspi/MOSI
add wave -noupdate /tbspi/MISO
add wave -noupdate /tbspi/CsInB
add wave -noupdate /tbspi/CsOutB
add wave -noupdate /tbspi/u_SPICom/rData
add wave -noupdate -radix unsigned /tbspi/u_SPICom/rDataCnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {428275700 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 187
configure wave -valuecolwidth 168
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1008842100 ps}
