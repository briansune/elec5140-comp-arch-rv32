onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_rv32i_regfile/clk
add wave -noupdate -radix unsigned /tb_rv32i_regfile/ra1_reg
add wave -noupdate -radix unsigned /tb_rv32i_regfile/ra2_reg
add wave -noupdate /tb_rv32i_regfile/wen_reg
add wave -noupdate -radix unsigned /tb_rv32i_regfile/wa_reg
add wave -noupdate -radix unsigned /tb_rv32i_regfile/wd_reg
add wave -noupdate -radix unsigned /tb_rv32i_regfile/rd1
add wave -noupdate -radix unsigned /tb_rv32i_regfile/rd2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {562 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ps} {998 ps}
