restart

run 10ns

mem load -filltype rand -filldata 0 -fillradix symbolic -skip 0 /tb_rv32i_ddr/sdram_model/Bank0
mem load -filltype rand -filldata 0 -fillradix symbolic -skip 0 /tb_rv32i_ddr/sdram_model/Bank1
mem load -filltype rand -filldata 0 -fillradix symbolic -skip 0 /tb_rv32i_ddr/sdram_model/Bank2
mem load -filltype rand -filldata 0 -fillradix symbolic -skip 0 /tb_rv32i_ddr/sdram_model/Bank3

run 84500ns

