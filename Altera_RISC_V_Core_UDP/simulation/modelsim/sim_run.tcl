restart

run 50ns

mem load -i E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/simulation/modelsim/instr_mem.mem /tb_rv32i_top/DUT/rv32i_icache_inst0/altsyncram_component/m_default/altsyncram_inst/mem_data

mem load -i E:/xilinx_cmp_arch/RISC_V/Altera_RISC_V_Core_UDP/simulation/modelsim/instr_mem.mem /tb_rv32i_top/DUT/rv32i_icache_inst0/altsyncram_component/m_default/altsyncram_inst/mem_data_b

#mem load -filltype value -filldata 0 -fillradix hexadecimal -skip 0 /tb_rv32i_core/DUT/rv32i_data_mem_inst0/altsyncram_component/m_default/altsyncram_inst/mem_data
#mem load -filltype value -filldata 0 -fillradix symbolic -skip 0 /tb_rv32i_core/DUT/rv32i_data_mem_inst0/altsyncram_component/m_default/altsyncram_inst/mem_data_b

run 260ns