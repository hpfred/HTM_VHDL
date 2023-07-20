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

vsim -t 100ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cycloneii -L rtl_work -L work -voptargs="+acc"  Testbench_HTM_Core

add wave -noupdate /testbench_htm_core/Core/Reset
add wave -noupdate /testbench_htm_core/Core/Clock
add wave -noupdate -expand -group HTM_Core /testbench_htm_core/Core/Action
add wave -noupdate -expand -group HTM_Core -radix unsigned /testbench_htm_core/Core/MemAddress
add wave -noupdate -expand -group HTM_Core -radix unsigned /testbench_htm_core/Core/Data
add wave -noupdate -expand -group HTM_Core -radix unsigned /testbench_htm_core/Core/ProcID
add wave -noupdate -expand -group HTM_Core -radix unsigned /testbench_htm_core/Core/TransactionID
add wave -noupdate -expand -group HTM_Core /testbench_htm_core/Core/TransactionStatus
add wave -noupdate -expand -group HTM_Core /testbench_htm_core/Core/HTMCUStatus
add wave -noupdate -expand -group Control_Unit /testbench_htm_core/Core/CU/IntAbortStatus
add wave -noupdate -expand -group Control_Unit /testbench_htm_core/Core/CU/BuffStatus
add wave -noupdate -expand -group Control_Unit /testbench_htm_core/Core/CU/CUStatus
add wave -noupdate -expand -group Control_Unit /testbench_htm_core/Core/CU/CurrStateIs
add wave -noupdate -group TM_Buffer -radix unsigned /testbench_htm_core/Core/Buff/MemAddress
add wave -noupdate -group TM_Buffer -radix unsigned /testbench_htm_core/Core/Buff/Data
add wave -noupdate -group TM_Buffer -radix unsigned /testbench_htm_core/Core/Buff/ProcID
add wave -noupdate -group TM_Buffer -radix unsigned /testbench_htm_core/Core/Buff/TransactionID
add wave -noupdate -group TM_Buffer /testbench_htm_core/Core/Buff/CUStatus
add wave -noupdate -group TM_Buffer /testbench_htm_core/Core/Buff/ConfBufMode
add wave -noupdate -group TM_Buffer -radix unsigned /testbench_htm_core/Core/Buff/ConfBufTrID
add wave -noupdate -group TM_Buffer /testbench_htm_core/Core/Buff/ConfBufStatus
add wave -noupdate -group TM_Buffer /testbench_htm_core/Core/Buff/CBProcStatus
add wave -noupdate -group TM_Buffer /testbench_htm_core/Core/Buff/QueueMode
add wave -noupdate -group TM_Buffer /testbench_htm_core/Core/Buff/QueueStatus
add wave -noupdate -group TM_Buffer /testbench_htm_core/Core/Buff/QueueReturn
add wave -noupdate -group TM_Buffer -radix unsigned /testbench_htm_core/Core/Buff/MemoryAddr
add wave -noupdate -group TM_Buffer -radix unsigned /testbench_htm_core/Core/Buff/MemoryData
add wave -noupdate -group TM_Buffer /testbench_htm_core/Core/Buff/BuffStatus
add wave -noupdate -group TM_Buffer /testbench_htm_core/Core/Buff/MemBuffer
add wave -noupdate -expand -group Queue /testbench_htm_core/Core/Commit/Mode
add wave -noupdate -expand -group Queue /testbench_htm_core/Core/Commit/Addr
add wave -noupdate -expand -group Queue /testbench_htm_core/Core/Commit/TrID
add wave -noupdate -expand -group Queue /testbench_htm_core/Core/Commit/FIFOStatus
add wave -noupdate -expand -group Queue /testbench_htm_core/Core/Commit/Ret
add wave -noupdate -expand -group Queue -childformat {{/testbench_htm_core/Core/Commit/MemStorage(3) -radix unsigned -childformat {{/testbench_htm_core/Core/Commit/MemStorage(3)(9) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(3)(8) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(3)(7) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(3)(6) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(3)(5) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(3)(4) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(3)(3) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(3)(2) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(3)(1) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(3)(0) -radix unsigned}}} {/testbench_htm_core/Core/Commit/MemStorage(2) -radix unsigned -childformat {{/testbench_htm_core/Core/Commit/MemStorage(2)(9) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(2)(8) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(2)(7) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(2)(6) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(2)(5) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(2)(4) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(2)(3) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(2)(2) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(2)(1) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(2)(0) -radix unsigned}}} {/testbench_htm_core/Core/Commit/MemStorage(1) -radix unsigned -childformat {{/testbench_htm_core/Core/Commit/MemStorage(1)(9) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(1)(8) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(1)(7) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(1)(6) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(1)(5) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(1)(4) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(1)(3) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(1)(2) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(1)(1) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(1)(0) -radix unsigned}}} {/testbench_htm_core/Core/Commit/MemStorage(0) -radix unsigned -childformat {{/testbench_htm_core/Core/Commit/MemStorage(0)(9) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(0)(8) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(0)(7) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(0)(6) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(0)(5) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(0)(4) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(0)(3) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(0)(2) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(0)(1) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(0)(0) -radix unsigned}}}} -expand -subitemconfig {/testbench_htm_core/Core/Commit/MemStorage(3) {-radix unsigned -childformat {{/testbench_htm_core/Core/Commit/MemStorage(3)(9) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(3)(8) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(3)(7) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(3)(6) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(3)(5) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(3)(4) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(3)(3) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(3)(2) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(3)(1) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(3)(0) -radix unsigned}}} /testbench_htm_core/Core/Commit/MemStorage(3)(9) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(3)(8) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(3)(7) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(3)(6) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(3)(5) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(3)(4) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(3)(3) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(3)(2) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(3)(1) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(3)(0) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(2) {-radix unsigned -childformat {{/testbench_htm_core/Core/Commit/MemStorage(2)(9) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(2)(8) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(2)(7) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(2)(6) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(2)(5) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(2)(4) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(2)(3) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(2)(2) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(2)(1) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(2)(0) -radix unsigned}} -expand} /testbench_htm_core/Core/Commit/MemStorage(2)(9) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(2)(8) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(2)(7) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(2)(6) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(2)(5) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(2)(4) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(2)(3) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(2)(2) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(2)(1) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(2)(0) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(1) {-radix unsigned -childformat {{/testbench_htm_core/Core/Commit/MemStorage(1)(9) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(1)(8) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(1)(7) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(1)(6) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(1)(5) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(1)(4) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(1)(3) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(1)(2) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(1)(1) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(1)(0) -radix unsigned}}} /testbench_htm_core/Core/Commit/MemStorage(1)(9) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(1)(8) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(1)(7) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(1)(6) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(1)(5) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(1)(4) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(1)(3) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(1)(2) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(1)(1) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(1)(0) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(0) {-radix unsigned -childformat {{/testbench_htm_core/Core/Commit/MemStorage(0)(9) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(0)(8) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(0)(7) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(0)(6) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(0)(5) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(0)(4) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(0)(3) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(0)(2) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(0)(1) -radix unsigned} {/testbench_htm_core/Core/Commit/MemStorage(0)(0) -radix unsigned}}} /testbench_htm_core/Core/Commit/MemStorage(0)(9) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(0)(8) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(0)(7) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(0)(6) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(0)(5) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(0)(4) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(0)(3) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(0)(2) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(0)(1) {-radix unsigned} /testbench_htm_core/Core/Commit/MemStorage(0)(0) {-radix unsigned}} /testbench_htm_core/Core/Commit/MemStorage
add wave -noupdate -group Conflict_Buffer -radix unsigned /testbench_htm_core/Core/Abort/TrID
add wave -noupdate -group Conflict_Buffer /testbench_htm_core/Core/Abort/Mode
add wave -noupdate -group Conflict_Buffer /testbench_htm_core/Core/Abort/Status
add wave -noupdate -group Conflict_Buffer /testbench_htm_core/Core/Abort/ProcStatus
add wave -noupdate -group Conflict_Buffer /testbench_htm_core/Core/Abort/IntAbortStatus
add wave -noupdate -group Conflict_Buffer /testbench_htm_core/Core/Abort/ConflictFlag
add wave -noupdate -group Main_Memory -radix unsigned /testbench_htm_core/Core/Memory/Addr
add wave -noupdate -group Main_Memory -radix unsigned /testbench_htm_core/Core/Memory/Data
add wave -noupdate -group Main_Memory -radix unsigned /testbench_htm_core/Core/Memory/Mem
TreeUpdate [SetDefaultTree]
configure wave -namecolwidth 150
configure wave -valuecolwidth 66
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ns} {400 ns}

view structure
view signals
view variables

run 1400 ns

