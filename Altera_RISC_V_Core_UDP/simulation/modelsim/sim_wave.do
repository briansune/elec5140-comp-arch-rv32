onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_rv32i_top/clk
add wave -noupdate /tb_rv32i_top/rst
add wave -noupdate /tb_rv32i_top/eth_rxc
add wave -noupdate /tb_rv32i_top/eth_txc
add wave -noupdate -radix hexadecimal /tb_rv32i_top/DUT/rv32i_dcache_inst0/wren
add wave -noupdate -radix unsigned /tb_rv32i_top/DUT/rv32i_dcache_inst0/wraddress
add wave -noupdate -radix unsigned /tb_rv32i_top/DUT/rv32i_dcache_inst0/rdaddress
add wave -noupdate -radix decimal /tb_rv32i_top/DUT/rv32i_dcache_inst0/q
add wave -noupdate -radix hexadecimal /tb_rv32i_top/DUT/rv32i_dcache_inst0/enable
add wave -noupdate -radix decimal /tb_rv32i_top/DUT/rv32i_dcache_inst0/data
add wave -noupdate -radix hexadecimal /tb_rv32i_top/DUT/rv32i_dcache_inst0/clock
add wave -noupdate -radix hexadecimal /tb_rv32i_top/DUT/rv32i_dcache_inst0/byteena_a
add wave -noupdate /tb_rv32i_top/DUT/global_rst
add wave -noupdate /tb_rv32i_top/DUT/global_nrst
add wave -noupdate /tb_rv32i_top/DUT/global_clk
add wave -noupdate /tb_rv32i_top/DUT/rv32i_core_run
add wave -noupdate /tb_rv32i_top/DUT/rv32i_core_rst
add wave -noupdate /tb_rv32i_top/DUT/rv32i_core_rst_delay
add wave -noupdate /tb_rv32i_top/DUT/rv32i_core_hld
add wave -noupdate /tb_rv32i_top/DUT/rv32i_global_clk
add wave -noupdate -radix hexadecimal /tb_rv32i_top/DUT/icache_rd_addr
add wave -noupdate -radix hexadecimal /tb_rv32i_top/DUT/icache_rd_end
add wave -noupdate -radix hexadecimal /tb_rv32i_top/DUT/icache_wr_addr
add wave -noupdate -radix hexadecimal /tb_rv32i_top/DUT/icache_wr_data
add wave -noupdate -radix hexadecimal /tb_rv32i_top/DUT/icache_wr_en
add wave -noupdate -radix hexadecimal /tb_rv32i_top/DUT/imem_rdata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {314618 ps} 0}
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
WaveRestoreZoom {0 ps} {1375500 ps}
