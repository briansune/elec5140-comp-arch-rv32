onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb_rv32i_cirbuff/DUT/nrst
add wave -noupdate -radix hexadecimal /tb_rv32i_cirbuff/DUT/clk
add wave -noupdate -radix hexadecimal /tb_rv32i_cirbuff/DUT/buff_full
add wave -noupdate -radix hexadecimal /tb_rv32i_cirbuff/DUT/buff_empty
add wave -noupdate -radix hexadecimal /tb_rv32i_cirbuff/DUT/address_tail_ram
add wave -noupdate -radix hexadecimal /tb_rv32i_cirbuff/DUT/address_tail
add wave -noupdate -radix hexadecimal /tb_rv32i_cirbuff/DUT/address_head
add wave -noupdate -radix hexadecimal /tb_rv32i_cirbuff/DUT/ADDR_WIDTH
add wave -noupdate -radix unsigned /tb_rv32i_cirbuff/DUT/addr_tail_chk_tail_f
add wave -noupdate -radix unsigned /tb_rv32i_cirbuff/DUT/addr_tail_chk_head_e
add wave -noupdate -radix unsigned /tb_rv32i_cirbuff/DUT/addr_head_chk_tail_f
add wave -noupdate -radix unsigned /tb_rv32i_cirbuff/DUT/addr_head_chk_head_e
add wave -noupdate -radix hexadecimal /tb_rv32i_cirbuff/DUT/head_empty
add wave -noupdate -radix hexadecimal /tb_rv32i_cirbuff/DUT/DATA_WIDTH
add wave -noupdate -radix hexadecimal /tb_rv32i_cirbuff/DUT/DATA_DEPTH
add wave -noupdate -radix hexadecimal /tb_rv32i_cirbuff/DUT/wr_trigger
add wave -noupdate -radix hexadecimal /tb_rv32i_cirbuff/DUT/wr_req
add wave -noupdate -radix hexadecimal /tb_rv32i_cirbuff/DUT/wr_en_reg
add wave -noupdate -radix hexadecimal /tb_rv32i_cirbuff/DUT/tail_full
add wave -noupdate -radix hexadecimal /tb_rv32i_cirbuff/DUT/rd_trigger
add wave -noupdate -radix hexadecimal /tb_rv32i_cirbuff/DUT/rd_req
add wave -noupdate -radix hexadecimal /tb_rv32i_cirbuff/DUT/rd_en_reg
add wave -noupdate -radix unsigned /tb_rv32i_cirbuff/DUT/wr_data
add wave -noupdate -radix unsigned /tb_rv32i_cirbuff/DUT/rd_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7490138 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 196
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {9612750 ps}
