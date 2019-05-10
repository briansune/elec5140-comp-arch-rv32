onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_rv32i_all_opcode_decode/clk
add wave -noupdate /tb_rv32i_all_opcode_decode/cmp_true
add wave -noupdate -radix binary /tb_rv32i_all_opcode_decode/inst_DX
add wave -noupdate /tb_rv32i_all_opcode_decode/prv
add wave -noupdate /tb_rv32i_all_opcode_decode/alu_op
add wave -noupdate /tb_rv32i_all_opcode_decode/illegal_instruction
add wave -noupdate /tb_rv32i_all_opcode_decode/ecall
add wave -noupdate /tb_rv32i_all_opcode_decode/eret_unkilled
add wave -noupdate /tb_rv32i_all_opcode_decode/ebreak
add wave -noupdate /tb_rv32i_all_opcode_decode/csr_cmd_unkilled
add wave -noupdate /tb_rv32i_all_opcode_decode/csr_imm_sel
add wave -noupdate /tb_rv32i_all_opcode_decode/fence_i
add wave -noupdate /tb_rv32i_all_opcode_decode/branch_taken_unkilled
add wave -noupdate /tb_rv32i_all_opcode_decode/jal_unkilled
add wave -noupdate /tb_rv32i_all_opcode_decode/jalr_unkilled
add wave -noupdate /tb_rv32i_all_opcode_decode/uses_rs1
add wave -noupdate /tb_rv32i_all_opcode_decode/uses_rs2
add wave -noupdate /tb_rv32i_all_opcode_decode/imm_type
add wave -noupdate /tb_rv32i_all_opcode_decode/src_a_sel
add wave -noupdate /tb_rv32i_all_opcode_decode/src_b_sel
add wave -noupdate /tb_rv32i_all_opcode_decode/dmem_en_unkilled
add wave -noupdate /tb_rv32i_all_opcode_decode/dmem_wen_unkilled
add wave -noupdate /tb_rv32i_all_opcode_decode/wr_reg_unkilled_DX
add wave -noupdate /tb_rv32i_all_opcode_decode/wb_src_sel_DX
add wave -noupdate /tb_rv32i_all_opcode_decode/uses_md_unkilled
add wave -noupdate /tb_rv32i_all_opcode_decode/wfi_unkilled_DX
add wave -noupdate -radix unsigned /tb_rv32i_all_opcode_decode/DUT/opcode
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {110 ps} 0}
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
WaveRestoreZoom {0 ps} {431 ps}
