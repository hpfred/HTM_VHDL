transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/Users/frepa/OneDrive/Documents/UFPel/Mestrado/Aluno-Especial_1/PTSD/Atividades/Projeto/VHDL/HTM_Core.vhd}
vcom -93 -work work {C:/Users/frepa/OneDrive/Documents/UFPel/Mestrado/Aluno-Especial_1/PTSD/Atividades/Projeto/VHDL/TM_Buffer.vhd}
vcom -93 -work work {C:/Users/frepa/OneDrive/Documents/UFPel/Mestrado/Aluno-Especial_1/PTSD/Atividades/Projeto/VHDL/Main_Memory.vhd}
vcom -93 -work work {C:/Users/frepa/OneDrive/Documents/UFPel/Mestrado/Aluno-Especial_1/PTSD/Atividades/Projeto/VHDL/Control_Unit.vhd}
vcom -93 -work work {C:/Users/frepa/OneDrive/Documents/UFPel/Mestrado/Aluno-Especial_1/PTSD/Atividades/Projeto/VHDL/Conflict_Buffer.vhd}
vcom -93 -work work {C:/Users/frepa/OneDrive/Documents/UFPel/Mestrado/Aluno-Especial_1/PTSD/Atividades/Projeto/VHDL/Address_Queue.vhd}

vcom -93 -work work {C:/Users/frepa/OneDrive/Documents/UFPel/Mestrado/Aluno-Especial_1/PTSD/Atividades/Projeto/VHDL/Testbench_HTM_Core.vhd}

#vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cycloneii -L rtl_work -L work -voptargs="+acc"  Testbench_HTM_Core
vsim -t 100ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cycloneii -L rtl_work -L work -voptargs="+acc"  Testbench_HTM_Core

#add wave * 
add wave -position insertpoint sim:/testbench_htm_core/Core/*         
add wave -position insertpoint sim:/testbench_htm_core/Core/CU/*
add wave -position insertpoint sim:/testbench_htm_core/Core/Buff/*
add wave -position insertpoint sim:/testbench_htm_core/Core/Commit/*
add wave -position insertpoint sim:/testbench_htm_core/Core/Abort/*
add wave -position insertpoint sim:/testbench_htm_core/Core/Memory/*

view structure
view signals
view variables

#run 290 ns
run 910 ns