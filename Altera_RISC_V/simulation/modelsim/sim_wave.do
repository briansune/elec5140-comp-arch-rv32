onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_rv32i_core/clk
add wave -noupdate /tb_rv32i_core/reset
add wave -noupdate /tb_rv32i_core/htif_pcr_req_valid
add wave -noupdate /tb_rv32i_core/htif_pcr_req_rw
add wave -noupdate -radix hexadecimal /tb_rv32i_core/htif_pcr_req_addr
add wave -noupdate -radix hexadecimal /tb_rv32i_core/htif_pcr_req_data
add wave -noupdate /tb_rv32i_core/htif_pcr_resp_ready
add wave -noupdate /tb_rv32i_core/htif_pcr_req_ready
add wave -noupdate /tb_rv32i_core/htif_pcr_resp_valid
add wave -noupdate -radix hexadecimal /tb_rv32i_core/htif_pcr_resp_data
add wave -noupdate -divider instr_mem
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/imem_wait
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/imem_badmem_e
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/imem_addr
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/imem_rdata
add wave -noupdate -divider data_mem
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/dmem_wait
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/dmem_size
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/pipeline_inst0/dmem_type_WB
add wave -noupdate -radix unsigned /tb_rv32i_core/DUT/dmem_addr
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/dmem_wen
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/dmem_en
add wave -noupdate /tb_rv32i_core/DUT/dmem_en_reg
add wave -noupdate /tb_rv32i_core/DUT/dmem_wen_reg
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/dmem_badmem_e
add wave -noupdate -color Cyan -radix unsigned /tb_rv32i_core/DUT/dmem_waddr_reg
add wave -noupdate -color Violet -radix decimal /tb_rv32i_core/DUT/dmem_wdata_delayed
add wave -noupdate -color Yellow -radix decimal /tb_rv32i_core/DUT/dmem_rdata
add wave -noupdate -divider ALU
add wave -noupdate -radix decimal /tb_rv32i_core/DUT/pipeline_inst0/alu_out_WB
add wave -noupdate -radix decimal /tb_rv32i_core/DUT/pipeline_inst0/alu_out
add wave -noupdate -radix decimal /tb_rv32i_core/DUT/pipeline_inst0/store_data_WB
add wave -noupdate /tb_rv32i_core/DUT/pipeline_inst0/wb_src_sel_WB
add wave -noupdate -radix decimal /tb_rv32i_core/DUT/pipeline_inst0/load_data_WB
add wave -noupdate -radix decimal /tb_rv32i_core/DUT/pipeline_inst0/wb_data_WB
add wave -noupdate -divider data_ram
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/pipeline_inst0/load_data/addr
add wave -noupdate -radix decimal /tb_rv32i_core/DUT/pipeline_inst0/load_data/shifted_data
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/pipeline_inst0/load_data/mem_type
add wave -noupdate -radix decimal /tb_rv32i_core/DUT/pipeline_inst0/load_data/load_data
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/pipeline_inst0/load_data/h_extend
add wave -noupdate -radix unsigned /tb_rv32i_core/DUT/pipeline_inst0/load_data/data
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/pipeline_inst0/load_data/b_extend
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/rv32i_data_mem_inst0/clock
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/rv32i_data_mem_inst0/enable
add wave -noupdate /tb_rv32i_core/DUT/rv32i_data_mem_inst0/wren
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/rv32i_data_mem_inst0/wraddress
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/rv32i_data_mem_inst0/data
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/rv32i_data_mem_inst0/rdaddress
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/rv32i_data_mem_inst0/byteena_a
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/rv32i_data_mem_inst0/q
add wave -noupdate -divider PC_ctrl
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/pipeline_inst0/PCmux/rs1_data
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/pipeline_inst0/PCmux/offset
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/pipeline_inst0/PCmux/jalr_offset
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/pipeline_inst0/PCmux/jal_offset
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/pipeline_inst0/PCmux/inst_DX
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/pipeline_inst0/PCmux/imm_b
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/pipeline_inst0/PCmux/handler_PC
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/pipeline_inst0/PCmux/epc
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/pipeline_inst0/PCmux/base
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/pipeline_inst0/PCmux/PC_src_sel
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/pipeline_inst0/PCmux/PC_PIF
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/pipeline_inst0/PCmux/PC_IF
add wave -noupdate -radix hexadecimal /tb_rv32i_core/DUT/pipeline_inst0/PCmux/PC_DX
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {327429 ps} 0}
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
WaveRestoreZoom {0 ps} {1890 ns}
