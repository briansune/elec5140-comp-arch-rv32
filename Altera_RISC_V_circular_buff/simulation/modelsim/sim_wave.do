onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_rv32i_cirbuff/clk
add wave -noupdate /tb_rv32i_cirbuff/nrst
add wave -noupdate /tb_rv32i_cirbuff/wr_req_signal
add wave -noupdate /tb_rv32i_cirbuff/DUT/wr_en_reg
add wave -noupdate /tb_rv32i_cirbuff/rd_req_signal
add wave -noupdate /tb_rv32i_cirbuff/DUT/rd_en_reg
add wave -noupdate /tb_rv32i_cirbuff/buff_empty_signal
add wave -noupdate /tb_rv32i_cirbuff/buff_full_signal
add wave -noupdate -radix hexadecimal /tb_rv32i_cirbuff/wr_data
add wave -noupdate -radix hexadecimal /tb_rv32i_cirbuff/rd_data
add wave -noupdate -radix unsigned /tb_rv32i_cirbuff/DUT/address_tail_ram
add wave -noupdate -radix unsigned /tb_rv32i_cirbuff/DUT/address_tail
add wave -noupdate -radix unsigned /tb_rv32i_cirbuff/DUT/address_head
add wave -noupdate -radix unsigned /tb_rv32i_cirbuff/DUT/addr_tail_chk_tail_f
add wave -noupdate -radix unsigned /tb_rv32i_cirbuff/DUT/addr_tail_chk_head_e
add wave -noupdate -radix unsigned /tb_rv32i_cirbuff/DUT/addr_head_chk_tail_f
add wave -noupdate -radix unsigned /tb_rv32i_cirbuff/DUT/addr_head_chk_head_e
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3565000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 165
configure wave -valuecolwidth 49
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
WaveRestoreZoom {0 ps} {2072832 ps}
