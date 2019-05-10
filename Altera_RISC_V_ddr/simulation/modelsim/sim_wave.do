onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_rv32i_ddr/clk
add wave -noupdate /tb_rv32i_ddr/rst_n
add wave -noupdate /tb_rv32i_ddr/sdram_clk
add wave -noupdate -radix hexadecimal /tb_rv32i_ddr/sdram_addr
add wave -noupdate /tb_rv32i_ddr/sdram_ba
add wave -noupdate /tb_rv32i_ddr/sdram_cs_n
add wave -noupdate /tb_rv32i_ddr/sdram_cke
add wave -noupdate /tb_rv32i_ddr/sdram_cas_n
add wave -noupdate /tb_rv32i_ddr/sdram_ras_n
add wave -noupdate /tb_rv32i_ddr/sdram_we_n
add wave -noupdate /tb_rv32i_ddr/sdram_dqm
add wave -noupdate -radix decimal /tb_rv32i_ddr/sdram_dq
add wave -noupdate /tb_rv32i_ddr/DUT/startup
add wave -noupdate /tb_rv32i_ddr/DUT/startup_inc
add wave -noupdate /tb_rv32i_ddr/DUT/hold_steady
add wave -noupdate /tb_rv32i_ddr/DUT/sdram_ctrl_inst0/busy
add wave -noupdate /tb_rv32i_ddr/DUT/sdram_ctrl_inst0/rd_ready
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {82810000 ps} 0}
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
WaveRestoreZoom {81995769 ps} {83384231 ps}
