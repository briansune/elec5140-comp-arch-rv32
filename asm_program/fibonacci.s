addi x10 x0 -1000
addi x5 x0 0
addi x6 x0 1
sw x10 4(x0)
addi x11 x0 0
add x10 x0 x0
lb x10 4(x0)
addi x10 x0 15
sw x10 4(x0)
add x10 x0 x0
lw x10 4(x0)

loop:
sw x5 12(x0)
add x7 x6 x5
add x5 x6 x0
add x6 x7 x0
addi x11 x11 1
bne x11 x10 loop
nop
nop