onerror {quit -f}
vlib work
vlog -work work HTM_CORE.vo
vlog -work work HTM_CORE.vt
vsim -novopt -c -t 1ps -L cycloneii_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.HTM_Core_vlg_vec_tst
vcd file -direction HTM_CORE.msim.vcd
vcd add -internal HTM_Core_vlg_vec_tst/*
vcd add -internal HTM_Core_vlg_vec_tst/i1/*
add wave /*
run -all
