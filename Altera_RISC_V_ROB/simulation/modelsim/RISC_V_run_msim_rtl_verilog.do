transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_ROB {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_ROB/rv32i_rob.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_ROB {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_ROB/simple_dual_port_ram_dual_clock.v}

vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_ROB {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_ROB/tb_rv32i_rob.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  tb_rv32i_rob

add wave *
view structure
view signals
run -all
