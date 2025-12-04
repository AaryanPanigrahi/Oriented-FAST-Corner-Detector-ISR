onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group Sync -label clk /tb_sram_model/clk
add wave -noupdate -expand -group Input -label wen -radix binary -radixshowbase 0 /tb_sram_model/wen
add wave -noupdate -expand -group Input -label ren -radix binary -radixshowbase 0 /tb_sram_model/ren
add wave -noupdate -expand -group Input -label q /tb_sram_model/q
add wave -noupdate -expand -group Input -label addr -radix unsigned -radixshowbase 0 /tb_sram_model/addr
add wave -noupdate -expand -group Output -label wdat /tb_sram_model/wdat
add wave -noupdate -expand -group Output -label rdat /tb_sram_model/rdat
add wave -noupdate -expand -group Memory -label ram -expand /tb_sram_model/DUT/ram
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {88715 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 101
configure wave -valuecolwidth 85
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
WaveRestoreZoom {0 ps} {719256 ps}
