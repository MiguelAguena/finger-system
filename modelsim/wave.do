onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /thumb_cpu_tb/DUT/clock
add wave -noupdate /thumb_cpu_tb/counter
add wave -noupdate -divider <NULL>
add wave -noupdate -expand /thumb_cpu_tb/DUT/REGS/regbank
add wave -noupdate -divider <NULL>
add wave -noupdate -radix binary /thumb_cpu_tb/DUT/s_inst_in
add wave -noupdate -radix binary /thumb_cpu_tb/DUT/s_sel_if
add wave -noupdate /thumb_cpu_tb/DUT/s_wr
add wave -noupdate /thumb_cpu_tb/DUT/s_regWrite
add wave -noupdate /thumb_cpu_tb/DUT/s_rr1
add wave -noupdate /thumb_cpu_tb/DUT/s_rr2
add wave -noupdate /thumb_cpu_tb/DUT/s_q1_if
add wave -noupdate /thumb_cpu_tb/DUT/s_q2_if
add wave -noupdate -divider <NULL>
add wave -noupdate -radix binary /thumb_cpu_tb/DUT/s_sel_ex
add wave -noupdate /thumb_cpu_tb/DUT/s_wr_ex
add wave -noupdate /thumb_cpu_tb/DUT/s_regWrite_ex_after_branch
add wave -noupdate /thumb_cpu_tb/DUT/s_rr1_ex
add wave -noupdate /thumb_cpu_tb/DUT/s_rr2_ex
add wave -noupdate /thumb_cpu_tb/DUT/s_q1_ex
add wave -noupdate /thumb_cpu_tb/DUT/s_q2_ex
add wave -noupdate /thumb_cpu_tb/DUT/s_alu_a
add wave -noupdate /thumb_cpu_tb/DUT/s_alu_b
add wave -noupdate /thumb_cpu_tb/DUT/s_alu_op_ex
add wave -noupdate /thumb_cpu_tb/DUT/s_alu_b_after_fwd
add wave -noupdate /thumb_cpu_tb/DUT/s_alu_res_ex
add wave -noupdate -divider <NULL>
add wave -noupdate -radix binary /thumb_cpu_tb/DUT/s_sel_wb
add wave -noupdate /thumb_cpu_tb/DUT/s_wr_wb
add wave -noupdate /thumb_cpu_tb/DUT/s_regWrite_wb
add wave -noupdate /thumb_cpu_tb/DUT/s_res_to_write
add wave -noupdate /thumb_cpu_tb/DUT/data_write
add wave -noupdate /thumb_cpu_tb/DUT/data_address
add wave -noupdate /thumb_cpu_tb/DUT/data_in
add wave -noupdate /thumb_cpu_tb/DUT/data_out
add wave -noupdate -divider <NULL>
add wave -noupdate /thumb_cpu_tb/DUT/interrupt
add wave -noupdate /thumb_cpu_tb/DUT/irq
add wave -noupdate /thumb_cpu_tb/DUT/s_interrupt_load_pc
add wave -noupdate /thumb_cpu_tb/DUT/s_interrupt_stalling
add wave -noupdate -divider <NULL>
add wave -noupdate /thumb_cpu_tb/MEM/data_addr
add wave -noupdate /thumb_cpu_tb/MEM/data_i
add wave -noupdate /thumb_cpu_tb/MEM/inst_addr
add wave -noupdate /thumb_cpu_tb/MEM/s_data_addr
add wave -noupdate /thumb_cpu_tb/MEM/s_data_i
add wave -noupdate /thumb_cpu_tb/MEM/s_data_o
add wave -noupdate /thumb_cpu_tb/MEM/s_inst_addr
add wave -noupdate /thumb_cpu_tb/MEM/s_inst_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 275
configure wave -valuecolwidth 125
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {136 ns}
