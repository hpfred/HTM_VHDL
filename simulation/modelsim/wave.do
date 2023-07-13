onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench_htm_core/Core/Action
add wave -noupdate /testbench_htm_core/Core/MemAddress
add wave -noupdate /testbench_htm_core/Core/Data
add wave -noupdate /testbench_htm_core/Core/ProcID
add wave -noupdate /testbench_htm_core/Core/TransactionID
add wave -noupdate /testbench_htm_core/Core/TransactionStatus
add wave -noupdate /testbench_htm_core/Core/Reset
add wave -noupdate /testbench_htm_core/Core/Clock
add wave -noupdate /testbench_htm_core/Core/IntAbortStatus
add wave -noupdate /testbench_htm_core/Core/ConfBufMode
add wave -noupdate /testbench_htm_core/Core/ConfBufTrID
add wave -noupdate /testbench_htm_core/Core/ConfBufStatus
add wave -noupdate /testbench_htm_core/Core/QueueStatus
add wave -noupdate /testbench_htm_core/Core/QueueMode
add wave -noupdate /testbench_htm_core/Core/CUStatus
add wave -noupdate /testbench_htm_core/Core/BuffStatus
add wave -noupdate /testbench_htm_core/Core/QueueReturn
add wave -noupdate /testbench_htm_core/Core/MemoryAddr
add wave -noupdate /testbench_htm_core/Core/MemoryData
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 239
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ps} {928 ps}
