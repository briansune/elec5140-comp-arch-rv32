transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/ip_verilog {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/ip_verilog/rv32i_instr_mem.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/ip_verilog {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/ip_verilog/rv32i_data_mem.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog/rv32i_ctrl.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog/rv32i_src_b_mux.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog/rv32i_src_a_mux.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog/rv32i_regfile.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog/rv32i_PC_mux.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog/rv32i_opcode_decode.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog/rv32i_mul_div.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog/rv32i_imm_gen.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog/rv32i_alu.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog/rv32i_mul_div_ctrl.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog/rv32i_core.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog/rv32i_pipeline.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog/rv32i_all_opcode_decode.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog/rv32i_csr_file.v}

vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V/verilog/tb_rv32i_core.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  tb_rv32i_core

add wave *
view structure
view signals
run -all
