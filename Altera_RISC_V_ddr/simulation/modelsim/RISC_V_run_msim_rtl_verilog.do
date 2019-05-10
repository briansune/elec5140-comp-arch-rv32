transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_ddr/src {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_ddr/src/top.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_ddr/src {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_ddr/src/sdram_ctrl.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_ddr/src {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_ddr/src/bidirectional_io.v}

vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_ddr/sim {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_ddr/sim/tb_rv32i_ddr.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_ddr/sim {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_ddr/sim/sdr.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  tb_rv32i_ddr

add wave *
view structure
view signals
run -all
