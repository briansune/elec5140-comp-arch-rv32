transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_sys_clk {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_sys_clk/sys_pll.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/icache {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/icache/rv32i_icache.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/dcache {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/dcache/rv32i_dcache.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_udp {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_udp/rv32i_udp.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_udp {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_udp/rv32i_crc.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/db {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/db/sys_pll_altpll.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_top.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_core {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_core/rv32i_src_b_mux.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_core {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_core/rv32i_src_a_mux.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_core {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_core/rv32i_regfile.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_core {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_core/rv32i_pipeline.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_core {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_core/rv32i_PC_mux.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_core {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_core/rv32i_opcode_decode.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_core {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_core/rv32i_mul_div_ctrl.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_core {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_core/rv32i_mul_div.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_core {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_core/rv32i_imm_gen.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_core {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_core/rv32i_ctrl.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_core {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_core/rv32i_csr_file.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_core {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_core/rv32i_alu.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_core {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_core/rv32i_all_opcode_decode.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_udp {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_udp/rv32i_ipsend.v}
vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_udp {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/rtl/rv32i_udp/rv32i_iprecieve.v}
vlib rv32i_cken
vmap rv32i_cken rv32i_cken
vlog -vlog01compat -work rv32i_cken +incdir+e:/xilinx_cmp_arch/risc_v/altera_risc_v_core_udp/db/ip/rv32i_cken {e:/xilinx_cmp_arch/risc_v/altera_risc_v_core_udp/db/ip/rv32i_cken/rv32i_cken.v}
vlog -vlog01compat -work rv32i_cken +incdir+e:/xilinx_cmp_arch/risc_v/altera_risc_v_core_udp/db/ip/rv32i_cken/submodules {e:/xilinx_cmp_arch/risc_v/altera_risc_v_core_udp/db/ip/rv32i_cken/submodules/rv32i_cken_altclkctrl_0.v}

vlog -vlog01compat -work work +incdir+E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/sim {E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/sim/tb_rv32i_top.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -L rv32i_cken -voptargs="+acc"  tb_rv32i_top

add wave *
view structure
view signals
run 300 ns
